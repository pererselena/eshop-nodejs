const mysql =require("promise-mysql");
const config = require("../config/db/eshop.json");
let db;

(async function() {
    db = await mysql.createConnection(config);

    process.on("exit", () => {
        db.end();
    });
})();

const logs = {
    getLogs: async function (search) {
        let sql = `CALL get_log("%${search}%");`;
        let res = await db.query(sql);

        return res[0];
    }
};

const faktura = {
    payed: async function (fakturanummer, date) {
        let sql = `CALL pay_faktura(${fakturanummer}, ${date});`;
        let res = await db.query(sql);

        return res[0];
    }
};

module.exports = {
    logs: logs,
    faktura: faktura
};
