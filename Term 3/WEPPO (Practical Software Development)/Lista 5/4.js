var http = require('http');
var express = require('express');
var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(express.urlencoded({extended:true}));

app.get( '/', (req, res) => {
    res.render('index2', {name:'', surname: '', subject: '', e1:'', e2:'', e3:'', e4:'', e5:'', e6:'', e7:'', e8:'', e9:'', e10:''});
});

app.post('/print', (req, res) => {
    var name = req.body.name;
    var surname = req.body.surname;
    var subject = req.body.subject;
    var e1 = req.body.e1 || 0;
    var e2 = req.body.e2 || 0;
    var e3 = req.body.e3 || 0;
    var e4 = req.body.e4 || 0;
    var e5 = req.body.e5 || 0;
    var e6 = req.body.e6 || 0;
    var e7 = req.body.e7 || 0;
    var e8 = req.body.e8 || 0;
    var e9 = req.body.e9 || 0;
    var e10 = req.body.e10 || 0;
    var exs = [e1,e2,e3,e4,e5,e6,e7,e8,e9,e10]
    if (!name || !surname || !subject){
        res.redirect('/')
    } else {
        res.render('print', {name:name, surname:surname, subject:subject, exs:exs});
    }
});

http.createServer(app).listen(3000);