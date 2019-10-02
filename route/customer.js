/**
 * Route for Customer.
 */
"use strict";

const express = require("express");
const router  = express.Router();
const util2 = require("../src/customer.js");
const customer = util2.customer;

router.get("/", async (req, res) => {
    let data = {
        title: "Customer"
    };

    data.res = await customer.getAllCustomersWithInfo();

    res.render("customer/index", data);
});



module.exports = router;
