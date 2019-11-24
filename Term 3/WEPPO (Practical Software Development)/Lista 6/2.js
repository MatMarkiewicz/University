var http = require('http');
var express = require('express');
var session = require('express-session');

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use("/", (req, res) => {
    res.render("index", { formData:
        {
            label:"label",
            id:"id"
        }
    } );
   });

http.createServer(app).listen(3000);