/**
 * Route for log.
 */
"use strict";

const express = require("express");
const router  = express.Router();
const utilProj = require("../src/util_proj.js");
const logs = utilProj.logs;


const bodyParser = require("body-parser");
const urlencodedParser = bodyParser.urlencoded({ extended: false });

router.get("/", async (req, res) => {
    let data = {
        title: "Log"
    };

    data.res = await logs.getLogs("%");
    data.serch = req.params.serch;

    res.render("log", data);
});

router.post("/search", urlencodedParser, async (req, res) => {
    let data = {
        title: "Log"
    };

    data.res = await logs.getLogs(`${req.body.search}`);

    res.render("log", data);
});


module.exports = router;
