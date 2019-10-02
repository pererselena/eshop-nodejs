/**
 * Route for category.
 */
"use strict";

const express = require("express");
const router  = express.Router();
const util = require("../src/util.js");
const category = util.category;


router.get("/", async (req, res) => {
    let data = {
        title: "Category"
    };

    data.res = await category.getAllCategories();

    res.render("category", data);
});

module.exports = router;
