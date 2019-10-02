/**
 * Route for order_row.
 */
"use strict";

const express = require("express");
const router  = express.Router();
const util = require("../src/util.js");
const product = util.product;
const util2 = require("../src/order.js");
const produktorder = util2.produktorder;

const bodyParser = require("body-parser");
const urlencodedParser = bodyParser.urlencoded({ extended: false });


router.get("/create/:ordernummer", async (req, res) => {
    let data = {
        title: "Order"
    };

    data.ordernummer = req.params.ordernummer;
    data.produkt = await product.getAllProducts();

    res.render("order_row/create", data);
});


router.post("/add", urlencodedParser, async (req, res) => {
    await produktorder.createProduktOrder(req.body);

    res.redirect("/eshop/order/show/" + req.body.ordernummer);
});

module.exports = router;
