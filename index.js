"use strict";

const port = 1337;

const express = require("express");
const routeIndex = require("./route/index.js");
const routeAbout = require("./route/about.js");
const routeProduct = require("./route/product.js");
const routeCategory = require("./route/category.js");
const routeOrder = require("./route/order.js");
const routeCustomer = require("./route/customer.js");
const routeOrderRow = require("./route/order_row.js");
const routeLog = require("./route/log.js");
const path = require("path");//för att koppla css och html i publik mapen
const app = express();

app.set("view engine", "ejs");

app.use((req, res, next) => {
    console.info(`Got request on ${req.path} (${req.method})`);
    next();
});//ska lägga innan public

app.use(express.static(path.join(__dirname, "public")));//för att koppla css och html i publik mapen

app.use("/eshop/", routeIndex);
app.use("/eshop/about", routeAbout);
app.use("/eshop/product", routeProduct);
app.use("/eshop/category", routeCategory);
app.use("/eshop/customer", routeCustomer);
app.use("/eshop/order", routeOrder);
app.use("/eshop/order_row", routeOrderRow);
app.use("/eshop/log", routeLog);

app.listen(port, () => {
    console.info(`server is listening on port ${port}.`);
});
