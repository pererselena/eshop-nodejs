"use strict";

// Read from commandline
const readline = require("readline");
const util = require("./src/util.js");
const productLog = util.productLog;
const shelf = util.shelf;
const inventory = util.inventory;
const order = util.order;
const utilProj = require("./src/util_proj.js");
const logs = utilProj.logs;
const faktura = utilProj.faktura;



(function () {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    showMenu();
    rl.setPrompt("Choose from menu: ");
    rl.prompt();

    rl.on("close", process.exit);
    rl.on("line", async (line) => {
        line = line.trim();
        let lineArray = line.split(" ");


        switch (lineArray[0]) {
            case "quit":
            case "exit":
                process.exit();
                break;
            case "menu":
            case "help":
                showMenu();
                break;
            case "log": {
                let numLines;

                if (typeof lineArray[1]=="undefined") {
                    numLines = 1;
                } else {
                    numLines = lineArray[1];
                }
                let res = await productLog.getHistory(numLines);

                console.table(res);
                break;
            }
            case "shelf": {
                let res = await shelf.getShelf();

                console.table(res);
                break;
            }
            case "inventory": {
                let search;
                let res;

                if (typeof lineArray[1]=="undefined") {
                    res = await inventory.getInventory();
                } else {
                    search = lineArray[1];
                    res = await inventory.searchInventory(search);
                }
                console.table(res);
                break;
            }
            case "invadd": {
                let produktkod;
                let shelf;
                let number;

                if (typeof lineArray[1]=="undefined") {
                    break;
                } else if (typeof lineArray[2]=="undefined") {
                    break;
                } else if (typeof lineArray[3]=="undefined") {
                    break;
                } else {
                    produktkod = lineArray[1];
                    shelf = lineArray[2];
                    number = lineArray[3];
                    await inventory.invadd(produktkod, shelf, number);
                }
                break;
            }
            case "invdel": {
                let produktkod;
                let shelf;
                let number;

                if (typeof lineArray[1]=="undefined") {
                    break;
                } else if (typeof lineArray[2]=="undefined") {
                    break;
                } else if (typeof lineArray[3]=="undefined") {
                    break;
                } else {
                    produktkod = lineArray[1];
                    shelf = lineArray[2];
                    number = lineArray[3];
                    await inventory.invdel(produktkod, shelf, number);
                }
                break;
            }
            case "order": {
                let search;
                let res;

                if (typeof lineArray[1]=="undefined") {
                    res = await order.searchOrder("%");
                } else {
                    search = lineArray[1];
                    res = await order.searchOrder(search);
                }
                console.table(res);
                break;
            }
            case "picklist": {
                let search;
                let res;

                if (typeof lineArray[1]=="undefined") {
                    console.log("You have to specify order number.");
                } else {
                    search = lineArray[1];
                    res = await order.plocklista(search);
                }
                console.table(res);
                break;
            }
            case "ship": {
                let search;

                if (typeof lineArray[1]=="undefined") {
                    console.log("You have to specify order number.");
                } else {
                    search = lineArray[1];
                    await order.ship(search);
                }
                break;
            }
            case "about": {
                console.log("This school project has been made by" +
                "Elena Perers with in the cours 'Data base' at BTH.");
                break;
            }
            case "logsearch": {
                let search;

                if (typeof lineArray[1]=="undefined") {
                    search = "%";
                } else {
                    search = lineArray[1];
                }
                let res = await logs.getLogs(search);

                console.table(res);
                break;
            }
            case "payed": {
                let fakturanummer;
                let date;

                if (typeof lineArray[1]=="undefined" ||
                    typeof lineArray[2]=="undefined") {
                    console.log("Incorrect usage!");
                    break;
                } else {
                    fakturanummer = lineArray[1];
                    date = lineArray[2];
                }
                await faktura.payed(fakturanummer, new Date(date).valueOf()/1000);
                break;
            }
        }

        rl.prompt();
    });
})();

function showMenu() {
    console.info(
        `\x1b[1mYou can choose these comments: \n` +
        `\x1b[42mexit, quit\x1b[0m: Exits the program. \n` +
        `\x1b[42mhelp, menu\x1b[0m: Show this menu. \n` +
        `\x1b[42mlog <number>\x1b[0m: Show number of latest log entries. \n` +
        `\x1b[42mshelf\x1b[0m: Show what shelfs exists in the storage. \n` +
        `\x1b[42minventory\x1b[0m: Show table with which products is available in the storage. \n` +
        `\x1b[42minventory <str>\x1b[0m: Search for product cod, product name and shelf. \n` +
        `\x1b[42minvadd <productid> <shelf> <number>\x1b[0m: Add specified \
amount of products to the shelf. \n` +
        `\x1b[42minvdel <productid> <shelf> <number>\x1b[0m: Delete specified \
amount of products to the shelf. \n` +
        `\x1b[42morder\x1b[0m: Show table with all orders.\n` +
        `\x1b[42morder <search>\x1b[0m: Search for orders which are matching \
customer and order number. \n` +
        `\x1b[42mpicklist <orderid>\x1b[0m: Show and create picklist from specified \
order number. \n` +
        `\x1b[42mship <orderid>\x1b[0m: Ship the specified order. \n` +
        `\x1b[42mlogsearch <str>\x1b[0m: Search for events in the log. \n` +
        `\x1b[42mpayed <invoiceid> <date>\x1b[0m: Mark an invoice as payed.\
Date format YYYY-MM-DD\n` +
        `\x1b[42mabout\x1b[0m: Information about who created this program. \n\n\x1b`
    );
}
