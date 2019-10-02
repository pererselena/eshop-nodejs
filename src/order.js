const mysql =require("promise-mysql");
const config = require("../config/db/eshop.json");
let db;

(async function() {
    db = await mysql.createConnection(config);

    process.on("exit", () => {
        db.end();
    });
})();

const order = {
    getAllOrders: async function () {
        let sql = `CALL get_orders();`;
        let res = await db.query(sql);

        return res[0];
    },

    getOrder:  async function (ordernummer) {
        let sql = `CALL get_order(${ordernummer});`;
        let res = await db.query(sql);

        return res[0][0];
    },


    createOrder: async function (body) {
        let sql = `CALL create_order(${body.kundnummer});`;
        let res = await db.query(sql, [body.kundnummer]);

        return res[0][0];
    },

    orderReady: async function (ordernummer) {
        let sql = `CALL order_ready(${ordernummer});`;

        await db.query(sql, [ordernummer]);
    },

    deleteOrderRow: async function (produktkod, ordernummer) {
        let sql = `CALL delete_row_order(${produktkod}, ${ordernummer});`;

        await db.query(sql);
    },

    updateOrderAntalRow: async function (produktkod, ordernummer, antal) {
        let sql = `CALL update_row_order(${produktkod}, ${ordernummer}, ${antal});`;

        await db.query(sql);
    },
};

const produktorder = {
    createProduktOrder: async function (body) {
        let sql = `CALL create_produkt_order(${body.produktkod},
            ${body.ordernummer}, ${body.antal});`;

        await db.query(sql, [
            body.produktkod,
            body.ordernummer,
            body.antal]);
    },
    getProduktorderForOrder: async function (ordernummer) {
        let sql = `CALL get_produkt_order(${ordernummer});`;
        let res = await db.query(sql);

        return res[0];
    },
};

module.exports = {
    order: order,
    produktorder: produktorder
};
