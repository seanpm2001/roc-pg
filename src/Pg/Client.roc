interface Pg.Client
    exposes [
        withConnect,
        command,
        batch,
        prepare,
        Error,
        errorToStr,
    ]
    imports [
        Protocol.Backend,
        Protocol.Frontend,
        Bytes.Encode,
        Bytes.Decode.{ decode },
        Pg.Result.{ CmdResult },
        Pg.Cmd.{ Cmd },
        Pg.Batch.{ Batch },
        pf.Task.{ Task, await },
        pf.Tcp,
        Cmd,
        Batch,
    ]

Client := {
    stream : Tcp.Stream,
    backendKey : Result Protocol.Backend.KeyData [Pending],
}

withConnect :
    {
        host : Str,
        port : U16,
        user : Str,
        auth ? [None, Password Str],
        database : Str,
    },
    (Client -> Task {} _)
    -> Task {} _
withConnect = \{ host, port, database, auth ? None, user }, callback ->
    stream <- Tcp.withConnect host port

    _ <- Protocol.Frontend.startup { user, database } |> send stream

    msg, state <- messageLoop stream {
            parameters: Dict.empty {},
            backendKey: Err Pending,
        }

    when msg is
        AuthOk ->
            next state

        AuthCleartextPassword ->
            when auth is
                None ->
                    Task.err PasswordRequired

                Password pwd ->
                    _ <- Protocol.Frontend.passwordMessage pwd |> send stream

                    next state

        AuthUnsupported ->
            Task.err UnsupportedAuth

        BackendKeyData backendKey ->
            next { state & backendKey: Ok backendKey }

        ReadyForQuery _ ->
            result <-
                @Client {
                    stream,
                    backendKey: state.backendKey,
                }
                |> callback
                |> await

            _ <- Protocol.Frontend.terminate |> send stream

            return result

        _ ->
            unexpected msg

# Single command

command : Cmd a err,
    Client
    -> Task
        a
        [
            PgExpectErr err,
            PgErr Error,
            PgProtoErr _,
            TcpReadErr _,
            TcpUnexpectedEOF,
            TcpWriteErr _,
        ]
command = \cmd, @Client { stream } ->
    { kind, limit, bindings } = Cmd.params cmd
    { formatCodes, paramValues } = Cmd.encodeBindings bindings

    init =
        when kind is
            SqlCmd sql ->
                {
                    messages: Bytes.Encode.sequence [
                        Protocol.Frontend.parse { sql },
                        Protocol.Frontend.bind { formatCodes, paramValues },
                        Protocol.Frontend.describePortal {},
                        Protocol.Frontend.execute { limit },
                    ],
                    fields: [],
                }

            PreparedCmd prepared ->
                {
                    messages: Bytes.Encode.sequence [
                        Protocol.Frontend.bind {
                            formatCodes,
                            paramValues,
                            preparedStatement: prepared.name,
                        },
                        Protocol.Frontend.execute { limit },
                    ],
                    fields: prepared.fields,
                }

    _ <- sendWithSync init.messages stream

    result <- readCmdResult init.fields stream |> await

    decoded <- Cmd.decode result cmd
        |> Result.mapErr PgExpectErr
        |> Task.fromResult
        |> await

    _ <- readReadyForQuery stream |> await

    Task.ok decoded

# Batches

batch : Batch a err,
    Client
    -> Task
        a
        [
            PgExpectErr err,
            PgErr Error,
            PgProtoErr _,
            TcpReadErr _,
            TcpUnexpectedEOF,
            TcpWriteErr _,
        ]
batch = \cmdBatch, @Client { stream } ->
    { commands, seenSql, decode: batchDecode } = Batch.params cmdBatch

    reusedIndexes =
        seenSql
        |> Dict.walk (Set.empty {}) \set, _, { index, reused } ->
            if reused then
                set |> Set.insert index
            else
                set

    inits =
        commands
        |> List.mapWithIndex (\cmd, ix -> initBatchedCmd reusedIndexes cmd ix)

    commandMessages =
        inits
        |> List.map .messages
        |> Bytes.Encode.sequence

    closeMessages =
        reusedIndexes
        |> Set.toList
        |> List.map \ix ->
            Protocol.Frontend.closeStatement { name: Batch.reuseName ix }
        |> Bytes.Encode.sequence

    messages = commandMessages |> List.concat closeMessages
    _ <- sendWithSync messages stream

    Task.loop
        {
            remaining: inits,
            results: List.withCapacity (List.len commands),
        }
        (\state -> batchReadStep batchDecode stream state)

initBatchedCmd : Set Nat,
    Batch.BatchedCmd,
    Nat
    -> {
        messages : List U8,
        fields : [
            Describe,
            ReuseFrom Nat,
            Known (List Pg.Result.RowField),
        ],
    }
initBatchedCmd = \reusedIndexes, cmd, cmdIndex ->
    { formatCodes, paramValues } = Cmd.encodeBindings cmd.bindings

    when cmd.kind is
        SqlCmd sql ->
            name =
                if Set.contains reusedIndexes cmdIndex then
                    Batch.reuseName cmdIndex
                else
                    ""

            {
                messages: Bytes.Encode.sequence [
                    Protocol.Frontend.parse { sql, name },
                    Protocol.Frontend.bind {
                        formatCodes,
                        paramValues,
                        preparedStatement: name,
                    },
                    Protocol.Frontend.describePortal {},
                    Protocol.Frontend.execute { limit: cmd.limit },
                ],
                fields: Describe,
            }

        ReuseSql index ->
            {
                messages: Bytes.Encode.sequence [
                    Protocol.Frontend.bind {
                        formatCodes,
                        paramValues,
                        preparedStatement: Batch.reuseName index,
                    },
                    Protocol.Frontend.execute { limit: cmd.limit },
                ],
                fields: ReuseFrom index,
            }

        PreparedCmd prepared ->
            {
                messages: Bytes.Encode.sequence [
                    Protocol.Frontend.bind {
                        formatCodes,
                        paramValues,
                        preparedStatement: prepared.name,
                    },
                    Protocol.Frontend.execute { limit: cmd.limit },
                ],
                fields: Known prepared.fields,
            }

batchReadStep = \batchDecode, stream, { remaining, results } ->
    when remaining is
        [] ->
            when batchDecode results is
                Ok { value } ->
                    _ <- readReadyForQuery stream |> await

                    return value

                Err (MissingCmdResult index) ->
                    Task.err (PgProtoErr (MissingBatchedCmdResult index))

                Err (ExpectErr err) ->
                    Task.err (PgExpectErr err)

        [first, ..] ->
            fields <- await (batchedCmdFields results first.fields)
            result <- readCmdResult fields stream |> await

            next {
                remaining: remaining |> List.dropFirst 1,
                results: results |> List.append result,
            }

batchedCmdFields = \results, fieldsMethod ->
    when fieldsMethod is
        Describe ->
            Task.ok []

        ReuseFrom index ->
            when List.get results index is
                Ok result ->
                    Task.ok (Pg.Result.fields result)

                Err OutOfBounds ->
                    # TODO: better name
                    Task.err (PgProtoErr ResultOutOfBounds)

        Known fields ->
            Task.ok fields

# Execute helpers

readCmdResult = \initFields, stream ->
    msg, state <- messageLoop stream {
            fields: initFields,
            rows: [],
        }

    when msg is
        ParseComplete | BindComplete | ParameterDescription ->
            next state

        RowDescription fields ->
            next { state & fields: fields }

        DataRow row ->
            next { state & rows: List.append state.rows row }

        CommandComplete _ | EmptyQueryResponse | PortalSuspended ->
            return (Pg.Result.create state)

        _ ->
            unexpected msg

readReadyForQuery = \stream ->
    msg, {} <- messageLoop stream {}

    when msg is
        CloseComplete ->
            next {}

        ReadyForQuery _ ->
            return {}

        _ ->
            unexpected msg

# Prepared Statements

prepare : Str,{ name : Str, client : Client }
    -> Task
        (Cmd CmdResult [])
        [
            PgErr Error,
            PgProtoErr _,
            TcpReadErr _,
            TcpUnexpectedEOF,
            TcpWriteErr _,
        ]
prepare = \sql, { name, client } ->
    (@Client { stream }) = client

    _ <- Bytes.Encode.sequence [
            Protocol.Frontend.parse { sql, name },
            Protocol.Frontend.describeStatement { name },
            Protocol.Frontend.sync,
        ]
        |> send stream

    msg, state <- messageLoop stream []

    when msg is
        ParseComplete | ParameterDescription ->
            next state

        RowDescription fields ->
            next fields

        ReadyForQuery _ ->
            return (Cmd.prepared { name, fields: state })

        _ ->
            unexpected msg

# Errors

Error : Protocol.Backend.Error

errorToStr : Error -> Str
errorToStr = \err ->
    addField = \str, name, result ->
        when result is
            Ok value ->
                "\(str)\n\(name): \(value)"

            Err {} ->
                str

    fieldsStr =
        ""
        |> addField "Detail" err.detail
        |> addField "Hint" err.hint
        |> addField "Position" (err.position |> Result.map Num.toStr)
        |> addField "Internal Position" (err.internalPosition |> Result.map Num.toStr)
        |> addField "Internal Query" err.internalQuery
        |> addField "Where" err.ewhere
        |> addField "Schema" err.schemaName
        |> addField "Table" err.tableName
        |> addField "Data type" err.dataTypeName
        |> addField "Constraint" err.constraintName
        |> addField "File" err.file
        |> addField "Line" err.line
        |> addField "Routine" err.line

    "\(err.localizedSeverity) (\(err.code)): \(err.message)\n\(fieldsStr)"
    |> Str.trim

# Helpers

readMessage : Tcp.Stream -> Task Protocol.Backend.Message [PgProtoErr _, TcpReadErr _, TcpUnexpectedEOF]
readMessage = \stream ->
    headerBytes <- Tcp.readExactly 5 stream |> await

    protoDecode = \bytes, dec ->
        decode bytes dec
        |> Result.mapErr PgProtoErr
        |> Task.fromResult

    meta <- headerBytes |> protoDecode Protocol.Backend.header |> await

    if meta.len > 0 then
        payload <- Tcp.readExactly (Num.toNat meta.len) stream |> await
        protoDecode payload (Protocol.Backend.message meta.msgType)
    else
        protoDecode [] (Protocol.Backend.message meta.msgType)

messageLoop : Tcp.Stream, state, (Protocol.Backend.Message, state -> Task [Done done, Step state] _) -> Task done _
messageLoop = \stream, initState, stepFn ->
    state <- Task.loop initState

    message <- readMessage stream |> await

    when message is
        ErrorResponse error ->
            Task.err (PgErr error)

        ParameterStatus _ ->
            Task.ok (Step state)

        _ ->
            stepFn message state

next : a -> Task [Step a] *
next = \state ->
    Task.ok (Step state)

return : a -> Task [Done a] *
return = \result ->
    Task.ok (Done result)

unexpected : a -> Task * [PgProtoErr [UnexpectedMsg a]]
unexpected = \msg ->
    Task.err (PgProtoErr (UnexpectedMsg msg))

send : List U8, Tcp.Stream, ({} -> Task a _) -> Task a _
send = \bytes, stream, callback ->
    Tcp.write bytes stream |> await callback

sendWithSync : List U8, Tcp.Stream, ({} -> Task a _) -> Task a _
sendWithSync = \bytes, stream, callback ->
    Bytes.Encode.sequence [
        bytes,
        Protocol.Frontend.sync,
    ]
    |> send stream callback
