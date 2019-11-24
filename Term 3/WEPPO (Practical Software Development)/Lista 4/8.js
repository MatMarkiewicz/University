var fs = require('fs');

//1

fs.readFile('plik.txt', 'utf-8', function(err, data1) {
    fs.readFile('plik2.txt', 'utf-8', function(err, data2) {
        fs.readFile('plik3.txt', 'utf-8', function(err, data3) {
            console.log(data1);
            console.log(data2);
            console.log(data3);
          });
      });
});

//2

function my_fspromise( path, enc ) {
    return new Promise( (res, rej) => {
        fs.readFile( path, enc, (err, data) => {
            if ( err )
                rej(err);
            res(data);
            });
        });
};

my_fspromise('plik.txt', 'utf-8')
    .then( data1 => {
        my_fspromise('plik2.txt', 'utf-8')
            .then( data2 => {
                my_fspromise('plik3.txt', 'utf-8')
                    .then( data3 => {
                        console.log( data1 );
                        console.log( data2 );
                        console.log( data3 );
                })
        })
    })

// 3

const util = require('util');
const readFile = util.promisify(fs.readFile);

readFile('plik.txt', 'utf8')
    .then((text) => {
        console.log(text);
    })
    .catch((err) => {
        console.log('Error', err);
    });

// 4

const fsPromises = require('fs').promises;
async function openAndClose() {
  let file;
  try {
    file = await fsPromises.readFile('plik.txt', 'utf-8');
    console.log(file)
  } catch(e){
    console.log(e)
  }
}
openAndClose();







