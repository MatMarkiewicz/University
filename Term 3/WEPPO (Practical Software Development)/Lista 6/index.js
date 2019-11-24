const express = require('express')
const multer = require('multer')
const fs = require('fs')
const path = require('path')

const UPLOAD_PATH = 'uploads';
const upload = multer({ dest: `${UPLOAD_PATH}/` });

const app = express();

app.post('/file', upload.single('file'), function (req, res, next) {
    fs.copyFileSync(path.join(UPLOAD_PATH,req.file.filename),"./file")
    console.log(req.file)
    res.send("recieved")
})

app.use(express.static('public'))

app.listen(3000, function () {
    console.log('listening on port 3000!');
});
