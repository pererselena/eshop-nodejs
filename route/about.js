/**
 * Route for about.
 */
"use strict";

const express = require("express");
const router  = express.Router();


router.get("/", async (req, res) => {
    let data = {
        title: "Welcome | CoffeeTea shop"
    };

    res.render("about", data);
});

module.exports = router;
