var http = require('http');
var express = require('express');
var session = require('express-session');
var app = express();
var FileStore = require('session-file-store')(session);

app.set('view engine', 'ejs');
app.set('views', './views');
app.disable('etag');
const store = new FileStore;
app.use(session({
    store: store,
    secret: 'gwewhrs wehbwe'
}));

app.post("/destroy", (req,res)=>{
    req.session.destroy()
    res.render("index3", { sessionValue: "" } );
})

app.get("/test", (req,res)=>{
    var sessionValue;
    if (!req.session.sessionValue) {
    sessionValue = "no session exist"
    } else {
    sessionValue = req.session.sessionValue;
    }
    res.render("index3", { sessionValue: sessionValue } );
})

app.use("/", (req, res) => {
    var sessionValue;
    if (!req.session.sessionValue) {
    sessionValue = new Date().toString();
    req.session.sessionValue = sessionValue;
    } else {
    sessionValue = req.session.sessionValue;
    }
    res.render("index3", { sessionValue: sessionValue } );
});

http.createServer(app).listen(3000);