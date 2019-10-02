/**
 * Route for product.
 */
"use strict";

const express = require("express");
const router  = express.Router();
const util = require("../src/util.js");
const product = util.product;
const category = util.category;

const bodyParser = require("body-parser");
const urlencodedParser = bodyParser.urlencoded({ extended: false });

router.get("/", async (req, res) => {
    let data = {
        title: "Poducts"
    };

    data.res = await product.getAllProducts();

    res.render("product/index", data);
});


router.get('/create', async (req, res) => {
    let data = {
        title: "Lägg till produkt"
    };

    data.res = await category.getAllCategories(req.params.id);
    res.render("product/create", data);
});



router.post("/create", urlencodedParser, async (req, res) => {
    await product.createProduct(req.body);
    await category.createProductCategory(req.body);


    res.redirect("/eshop/product");
});



router.get("/update/:id", async (req, res) => {
    let data = {
        title: "Ändra produkten",
        id: req.params.id
    };

    data.res = await product.getProduct(req.params.id);
    data.res.cat = await category.getAllCategories(req.params.id);
    let pk = await category.getProductCategory(req.params.id);

    data.res.pk = [];
    for (var i = 0; i < pk.length; i++) {
        data.res.pk.push(pk[i].kategorinamn);
    }
    res.render("product/update", data);
});

router.post("/update", urlencodedParser, async (req, res) => {
    await product.updateProduct(req.body);
    await category.updateProductCategory(req.body);

    res.redirect(`/eshop/product`);
});

router.get("/delete/:id", async (req, res) => {
    let data = {
        title: "Radera produkten",
        id: req.params.id
    };

    data.res = await product.getProduct(req.params.id);
    data.res.pk = await category.getProductCategory(req.params.id);

    res.render("product/delete", data);
});

router.post("/delete/:id", urlencodedParser, async (req, res) => {
    await product.deleteProduct(req.body);
    await category.deleteProductCategory(req.body);


    res.redirect(`/eshop/product`);
});

router.get("/:category", async (req, res) => {
    let data = {
        title: "Poducts in category"
    };

    data.res = await category.getProductsInCategory(req.params.category);

    res.render("product/produktkategori", data);
});


module.exports = router;
