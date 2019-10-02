/**
 * Route for order.
 */
"use strict";

const express = require("express");
const router  = express.Router();
const util = require("../src/order.js");
const order = util.order;
const produktorder = util.produktorder;
const util2 = require("../src/customer.js");
const customer = util2.customer;
const util3 = require("../src/util.js");
const order2 = util3.order;

const bodyParser = require("body-parser");
const urlencodedParser = bodyParser.urlencoded({ extended: false });

router.get("/", async (req, res) => {
    let data = {
        title: "Order"
    };

    data.res = await order.getAllOrders();

    res.render("order/index", data);
});

router.get("/create", async (req, res) => {
    let data = {
        title: "Skapa order"
    };

    data.kund = await customer.getAllCustomers();

    res.render("order/create", data);
});

router.get("/show/:id", async (req, res) => {
    let data = {
        title: "Skapa order"
    };

    data.order = await order.getOrder(req.params.id);
    data.produktorder = await produktorder.getProduktorderForOrder(req.params.id);
    res.render("order/show", data);
});

router.get("/order_ready/:id", async (req, res) => {
    await order.orderReady(req.params.id);

    res.redirect(`/eshop/order`);
});

router.post("/create", urlencodedParser, async (req, res) => {
    let orders = await order.createOrder(req.body);

    res.redirect(`/eshop/order/show/${orders.ordernummer}`);
});

router.get("/delete_row/:id", async (req, res) => {
    let params = req.params.id.split("-");
    let produktkod = params[0];
    let ordernummer = params[1];

    await order.deleteOrderRow(produktkod, ordernummer);

    res.redirect(`/eshop/order/show/${ordernummer}`);
});

router.post("/update_row/:id", urlencodedParser, async (req, res) => {
    let params = req.params.id.split("-");
    let produktkod = params[1];
    let ordernummer = params[0];

    await order.updateOrderAntalRow(produktkod, ordernummer, req.body.antal);

    res.redirect(`/eshop/order/show/${ordernummer}`);
});

router.get("/picklist/:id", async (req, res) => {
    let data = {
        title: "Picklist"
    };

    data.res = await order2.plocklista(req.params.id);
    data.ordernummer = req.params.id;

    res.render("order/picklist", data);
});

router.get("/faktura/:id", async (req, res) => {
    let data = {
        title: "Faktura"
    };


    data.res = await order2.getFaktura(req.params.id);
    if (data.res.length === 0) {
        res.render("order/nofaktura", data);
    }

    res.render("order/faktura", data);
});



module.exports = router;
