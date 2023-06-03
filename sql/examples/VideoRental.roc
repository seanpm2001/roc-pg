# This file was automatically generated by roc-sql
interface VideoRental
    exposes [
        inventory,
        filmActor,
        address,
        city,
        actorInfo,
        actor,
        filmCategory,
        category,
        country,
        language,
        customer,
        film,
        customerList,
        payment,
        rental,
        paymentP2022N04,
        rentalByCategory,
        salesByFilmCategory,
        store,
        staff,
        salesByStore,
        staffList,
        paymentP2022N07,
        paymentP2022N02,
        paymentP2022N03,
        paymentP2022N05,
        paymentP2022N06,
        paymentP2022N01,
    ]
    imports [
        sql.Sql.{ identifier },
        sql.Sql.Types,
    ]

inventory = {
    schema: "video_rental",
    name: "inventory",
    alias: "i",
    columns: \alias -> {
        storeId: identifier alias "store_id" Sql.Types.i32,
        filmId: identifier alias "film_id" Sql.Types.i32,
        inventoryId: identifier alias "inventory_id" Sql.Types.i32,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

filmActor = {
    schema: "video_rental",
    name: "film_actor",
    alias: "fa",
    columns: \alias -> {
        filmId: identifier alias "film_id" Sql.Types.i32,
        actorId: identifier alias "actor_id" Sql.Types.i32,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

address = {
    schema: "video_rental",
    name: "address",
    alias: "a",
    columns: \alias -> {
        cityId: identifier alias "city_id" Sql.Types.i32,
        addressId: identifier alias "address_id" Sql.Types.i32,
        phone: identifier alias "phone" Sql.Types.str,
        postalCode: identifier alias "postal_code" (Sql.Types.nullable Sql.Types.str),
        district: identifier alias "district" Sql.Types.str,
        address2: identifier alias "address2" (Sql.Types.nullable Sql.Types.str),
        address: identifier alias "address" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

city = {
    schema: "video_rental",
    name: "city",
    alias: "c",
    columns: \alias -> {
        countryId: identifier alias "country_id" Sql.Types.i32,
        cityId: identifier alias "city_id" Sql.Types.i32,
        city: identifier alias "city" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

actorInfo = {
    schema: "video_rental",
    name: "actor_info",
    alias: "ai",
    columns: \alias -> {
        actorId: identifier alias "actor_id" (Sql.Types.nullable Sql.Types.i32),
        filmInfo: identifier alias "film_info" (Sql.Types.nullable Sql.Types.str),
        lastName: identifier alias "last_name" (Sql.Types.nullable Sql.Types.str),
        firstName: identifier alias "first_name" (Sql.Types.nullable Sql.Types.str),
    },
}

actor = {
    schema: "video_rental",
    name: "actor",
    alias: "a",
    columns: \alias -> {
        actorId: identifier alias "actor_id" Sql.Types.i32,
        lastName: identifier alias "last_name" Sql.Types.str,
        firstName: identifier alias "first_name" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

filmCategory = {
    schema: "video_rental",
    name: "film_category",
    alias: "fc",
    columns: \alias -> {
        categoryId: identifier alias "category_id" Sql.Types.i32,
        filmId: identifier alias "film_id" Sql.Types.i32,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

category = {
    schema: "video_rental",
    name: "category",
    alias: "c",
    columns: \alias -> {
        categoryId: identifier alias "category_id" Sql.Types.i32,
        name: identifier alias "name" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

country = {
    schema: "video_rental",
    name: "country",
    alias: "c",
    columns: \alias -> {
        countryId: identifier alias "country_id" Sql.Types.i32,
        country: identifier alias "country" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

language = {
    schema: "video_rental",
    name: "language",
    alias: "l",
    columns: \alias -> {
        languageId: identifier alias "language_id" Sql.Types.i32,
        name: identifier alias "name" (Sql.Types.unsupported "bpchar"),
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

customer = {
    schema: "video_rental",
    name: "customer",
    alias: "c",
    columns: \alias -> {
        activebool: identifier alias "activebool" Sql.Types.bool,
        active: identifier alias "active" (Sql.Types.nullable Sql.Types.i32),
        addressId: identifier alias "address_id" Sql.Types.i32,
        storeId: identifier alias "store_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        email: identifier alias "email" (Sql.Types.nullable Sql.Types.str),
        lastName: identifier alias "last_name" Sql.Types.str,
        firstName: identifier alias "first_name" Sql.Types.str,
        createDate: identifier alias "create_date" (Sql.Types.unsupported "date"),
        lastUpdate: identifier alias "last_update" (Sql.Types.nullable (Sql.Types.unsupported "timestamptz")),
    },
}

film = {
    schema: "video_rental",
    name: "film",
    alias: "f",
    columns: \alias -> {
        length: identifier alias "length" (Sql.Types.nullable Sql.Types.i16),
        rentalDuration: identifier alias "rental_duration" Sql.Types.i16,
        originalLanguageId: identifier alias "original_language_id" (Sql.Types.nullable Sql.Types.i32),
        languageId: identifier alias "language_id" Sql.Types.i32,
        filmId: identifier alias "film_id" Sql.Types.i32,
        rating: identifier alias "rating" (Sql.Types.nullable Sql.Types.str),
        description: identifier alias "description" (Sql.Types.nullable Sql.Types.str),
        title: identifier alias "title" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
        replacementCost: identifier alias "replacement_cost" Sql.Types.dec,
        rentalRate: identifier alias "rental_rate" Sql.Types.dec,
        fulltext: identifier alias "fulltext" (Sql.Types.unsupported "tsvector"),
        specialFeatures: identifier alias "special_features" (Sql.Types.nullable (Sql.Types.unsupported "_text")),
        releaseYear: identifier alias "release_year" (Sql.Types.nullable (Sql.Types.unsupported "year")),
    },
}

customerList = {
    schema: "video_rental",
    name: "customer_list",
    alias: "cl",
    columns: \alias -> {
        sid: identifier alias "sid" (Sql.Types.nullable Sql.Types.i32),
        id: identifier alias "id" (Sql.Types.nullable Sql.Types.i32),
        notes: identifier alias "notes" (Sql.Types.nullable Sql.Types.str),
        country: identifier alias "country" (Sql.Types.nullable Sql.Types.str),
        city: identifier alias "city" (Sql.Types.nullable Sql.Types.str),
        phone: identifier alias "phone" (Sql.Types.nullable Sql.Types.str),
        zipcode: identifier alias "\"zip code\"" (Sql.Types.nullable Sql.Types.str),
        address: identifier alias "address" (Sql.Types.nullable Sql.Types.str),
        name: identifier alias "name" (Sql.Types.nullable Sql.Types.str),
    },
}

payment = {
    schema: "video_rental",
    name: "payment",
    alias: "p",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

rental = {
    schema: "video_rental",
    name: "rental",
    alias: "r",
    columns: \alias -> {
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        inventoryId: identifier alias "inventory_id" Sql.Types.i32,
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
        returnDate: identifier alias "return_date" (Sql.Types.nullable (Sql.Types.unsupported "timestamptz")),
        rentalDate: identifier alias "rental_date" (Sql.Types.unsupported "timestamptz"),
    },
}

paymentP2022N04 = {
    schema: "video_rental",
    name: "payment_p2022_04",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

rentalByCategory = {
    schema: "video_rental",
    name: "rental_by_category",
    alias: "rbc",
    columns: \alias -> {
        category: identifier alias "category" (Sql.Types.nullable Sql.Types.str),
        totalSales: identifier alias "total_sales" (Sql.Types.nullable Sql.Types.dec),
    },
}

salesByFilmCategory = {
    schema: "video_rental",
    name: "sales_by_film_category",
    alias: "sbfc",
    columns: \alias -> {
        category: identifier alias "category" (Sql.Types.nullable Sql.Types.str),
        totalSales: identifier alias "total_sales" (Sql.Types.nullable Sql.Types.dec),
    },
}

store = {
    schema: "video_rental",
    name: "store",
    alias: "s",
    columns: \alias -> {
        addressId: identifier alias "address_id" Sql.Types.i32,
        managerStaffId: identifier alias "manager_staff_id" Sql.Types.i32,
        storeId: identifier alias "store_id" Sql.Types.i32,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

staff = {
    schema: "video_rental",
    name: "staff",
    alias: "s",
    columns: \alias -> {
        active: identifier alias "active" Sql.Types.bool,
        picture: identifier alias "picture" (Sql.Types.nullable (Sql.Types.unsupported "bytea")),
        storeId: identifier alias "store_id" Sql.Types.i32,
        addressId: identifier alias "address_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        password: identifier alias "password" (Sql.Types.nullable Sql.Types.str),
        username: identifier alias "username" Sql.Types.str,
        email: identifier alias "email" (Sql.Types.nullable Sql.Types.str),
        lastName: identifier alias "last_name" Sql.Types.str,
        firstName: identifier alias "first_name" Sql.Types.str,
        lastUpdate: identifier alias "last_update" (Sql.Types.unsupported "timestamptz"),
    },
}

salesByStore = {
    schema: "video_rental",
    name: "sales_by_store",
    alias: "sbs",
    columns: \alias -> {
        manager: identifier alias "manager" (Sql.Types.nullable Sql.Types.str),
        store: identifier alias "store" (Sql.Types.nullable Sql.Types.str),
        totalSales: identifier alias "total_sales" (Sql.Types.nullable Sql.Types.dec),
    },
}

staffList = {
    schema: "video_rental",
    name: "staff_list",
    alias: "sl",
    columns: \alias -> {
        sid: identifier alias "sid" (Sql.Types.nullable Sql.Types.i32),
        id: identifier alias "id" (Sql.Types.nullable Sql.Types.i32),
        country: identifier alias "country" (Sql.Types.nullable Sql.Types.str),
        city: identifier alias "city" (Sql.Types.nullable Sql.Types.str),
        phone: identifier alias "phone" (Sql.Types.nullable Sql.Types.str),
        zipcode: identifier alias "\"zip code\"" (Sql.Types.nullable Sql.Types.str),
        address: identifier alias "address" (Sql.Types.nullable Sql.Types.str),
        name: identifier alias "name" (Sql.Types.nullable Sql.Types.str),
    },
}

paymentP2022N07 = {
    schema: "video_rental",
    name: "payment_p2022_07",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

paymentP2022N02 = {
    schema: "video_rental",
    name: "payment_p2022_02",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

paymentP2022N03 = {
    schema: "video_rental",
    name: "payment_p2022_03",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

paymentP2022N05 = {
    schema: "video_rental",
    name: "payment_p2022_05",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

paymentP2022N06 = {
    schema: "video_rental",
    name: "payment_p2022_06",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}

paymentP2022N01 = {
    schema: "video_rental",
    name: "payment_p2022_01",
    alias: "pp0",
    columns: \alias -> {
        rentalId: identifier alias "rental_id" Sql.Types.i32,
        staffId: identifier alias "staff_id" Sql.Types.i32,
        customerId: identifier alias "customer_id" Sql.Types.i32,
        paymentId: identifier alias "payment_id" Sql.Types.i32,
        paymentDate: identifier alias "payment_date" (Sql.Types.unsupported "timestamptz"),
        amount: identifier alias "amount" Sql.Types.dec,
    },
}
