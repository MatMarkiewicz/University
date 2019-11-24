var http = require('http');
var express = require('express');

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use( (req, res) => {
    res.header('Content-disposition', 'attachment; filename="foo.txt"');
    res.end('tekst');
});

http.createServer(app).listen(3000);
