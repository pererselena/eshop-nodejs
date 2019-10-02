const mysql =require("promise-mysql");
const config = require("../config/db/eshop.json");
let db;
const utilOrder = require("./order.js");
const produktOrder = utilOrder.produktorder;
const orderUtil = utilOrder.order;

(async function() {
    db = await mysql.createConnection(config);

    process.on("exit", () => {
        db.end();
    });
})();

const product = {
    getAllProducts: async function () {
        let sql = "CALL show_produkt();";
        let res = await db.query(sql);

        return res[0];
    },

    createProduct: async function (body) {
        let sql = `CALL create_product(${body.produktkod}, ${body.pris}, \
'${body.produktnamn}', '${body.bildlank}', '${body.beskrivning}');`;

        await db.query(sql);
    },

    getProduct: async function (produktkod) {
        let sql = `CALL get_product(${produktkod});`;
        let res = await db.query(sql);

        return res[0];
    },

    updateProduct: async function (body) {
        let sql = `CALL update_product(${body.produktkod}, ${body.pris}, \
'${body.produktnamn}', '${body.bildlank}', '${body.beskrivning}');`;

        await db.query(sql);
    },

    deleteProduct: async function (body) {
        let sql = `CALL clear_produktkategori(${body.produktkod});`;

        await db.query(sql);

        sql = `CALL delete_produktlager(${body.produktkod});`;

        await db.query(sql);

        sql = `CALL delete_product(${body.produktkod});`;

        await db.query(sql);
    }
};

const category = {
    getAllCategories: async function () {
        let sql = "CALL show_category();";
        let res = await db.query(sql);

        return res[0];
    },

    getProductsInCategory: async function (kategorinamn) {
        let sql = `CALL show_produktkategori("${kategorinamn}");`;
        let res = await db.query(sql);

        return res[0];
    },

    createProductCategory: async function (body) {
        for (var i = 0; i < body.kategorinamn.length; i++) {
            let sql = `CALL create_produktkategori(${body.produktkod}, \
                '${body.kategorinamn[i]}');`;

            await db.query(sql);
        }
    },

    getProductCategory: async function (produktkod) {
        let sql = `CALL get_produktkategori("${produktkod}");`;
        let res = await db.query(sql);

        return res[0];
    },

    updateProductCategory: async function (body) {
        let sql = `CALL clear_produktkategori(${body.produktkod});`;

        await db.query(sql);
        if (typeof body.kategorinamn === "string" || body.kategorinamn instanceof String) {
            let sql = `CALL update_produktkategori(${body.produktkod}, \
                '${body.kategorinamn}');`;

            await db.query(sql);
        } else {
            for (var i = 0; i < body.kategorinamn.length; i++) {
                let sql = `CALL update_produktkategori(${body.produktkod}, \
                    '${body.kategorinamn[i]}');`;

                await db.query(sql);
            }
        }
    },

    deleteProductCategory: async function (body) {
        let sql = `CALL delete_produktkategori(${body.produktkod}, '${body.kategorinamn}');`;

        await db.query(sql);
    }
};


const productLog = {
    getHistory: async function (number) {
        let sql = `CALL get_history(${number});`;

        let res = await db.query(sql, [number]);

        return res[0];
    }
};

const shelf = {
    getShelf: async function () {
        let sql = `CALL get_shelf();`;

        let res = await db.query(sql);

        return res[0];
    }
};

const inventory = {
    getInventory: async function () {
        let sql = `CALL get_inventory();`;

        let res = await db.query(sql);

        return res[0];
    },
    searchInventory: async function (search) {
        let sql = `CALL search_inventory("%${search}%");`;
        let res = await db.query(sql);

        return res[0];
    },
    invadd: async function (produktkod, shelf, number) {
        let sql = `CALL invadd(${produktkod}, "${shelf}", ${number});`;

        await db.query(sql);
    },
    invdel: async function (produktkod, shelf, number) {
        let sql = `CALL invdel(${produktkod}, "${shelf}", ${number});`;

        await db.query(sql);
    }
};

const order = {
    searchOrder: async function (search) {
        let sql = `CALL search_order("%${search}%");`;
        let res = await db.query(sql);

        return res[0];
    },
    plocklista: async function (search) {
        let sql = `CALL plocklista("${search}");`;
        let res = await db.query(sql);

        return res[0];
    },
    ship: async function (search) {
        let picklist = await order.plocklista(search);

        for (let i = 0; i < picklist.length; i++) {
            if (picklist[i].lagerdiff < 0 || picklist[i].lagerdiff == null) {
                console.log("Produkter saknas i lager");
                return;
            }
        }
        console.log("skickar order");
        let sql = `CALL ship(${search});`;
        let res = await db.query(sql);
        let po = await produktOrder.getProduktorderForOrder(search);
        let orderShip = await orderUtil.getOrder(search);

        sql = `CALL create_faktura(${orderShip.kundnummer}, ${search});`;
        await db.query(sql);

        for (let i = 0; i < po.length; i++) {
            let sqlstatment = `CALL reduce_pl(${po[i].produktkod}, ${po[i].antal});`;

            await db.query(sqlstatment);
        }

        return res[0];
    },
    getFaktura: async function (ordernummer) {
        let sql = `CALL get_faktura(${ordernummer});`;
        let res = await db.query(sql);

        return res[0];
    },
};


module.exports = {
    product: product,
    category: category,
    productLog: productLog,
    shelf: shelf,
    inventory: inventory,
    order: order
};
