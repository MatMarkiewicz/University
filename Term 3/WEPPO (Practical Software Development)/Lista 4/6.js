var fs = require('fs');

fs.readFile('plik.txt', 'utf-8', function(err, data) {
  console.log( data );
});