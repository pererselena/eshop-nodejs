/**
 * Route for index.
 */
"use strict";

const express = require("express");
const router  = express.Router();


router.get("/index", async (req, res) => {
    let data = {
        title: "Welcome | CoffeeTea shop"
    };

    res.render("index", data);
});

module.exports = router;
