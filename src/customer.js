const mysql =require("promise-mysql");
const config = require("../config/db/eshop.json");
let db;

(async function() {
    db = await mysql.createConnection(config);

    process.on("exit", () => {
        db.end();
    });
})();

const customer = {
    getAllCustomers: async function () {
        let sql = `CALL get_customers();`;
        let res = await db.query(sql);

        return res[0];
    },
    getAllCustomersWithInfo: async function () {
        let sql = `CALL customers_with_info();`;
        let res = await db.query(sql);

        return res[0];
    }
};

module.exports = {
    customer: customer
};
