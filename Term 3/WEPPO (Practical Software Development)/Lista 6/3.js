var http = require('http');
var express = require('express');
var cookieParser = require('cookie-parser');
var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');
app.disable('etag');
app.use(cookieParser());

app.use(express.urlencoded({
    extended: true
}));

app.post("/", (req,res) => {
    const cookieValue = new Date().toString();
    res.cookie('cookie', cookieValue);
    res.render("index2", { cookieValue: cookieValue, saved:"manualy" } );    
})
app.post("/del", (req,res)=>{
    res.clearCookie("cookie");
    res.render("index2", { cookieValue: "n/a", saved:"actually removed instead" } );    
})

app.use("/", (req, res) => {
    let cookieValue;
    let saved = false;
    console.log(req.cookies.cookie)
    if (!req.cookies.cookie) {
        cookieValue = new Date().toString();
        res.cookie('cookie', cookieValue);
        saved = true;
    } else {
        cookieValue = req.cookies.cookie;
    }
    res.render("index2", { cookieValue: cookieValue, saved: saved ? "auto" : "not" } );
});

http.createServer(app).listen(3000);
