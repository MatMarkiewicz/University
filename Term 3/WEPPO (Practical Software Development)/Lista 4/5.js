process.stdin.setEncoding('utf8');
console.log("Podaj swoje imię")
var stdin = process.openStdin();
stdin.on('data', function(chunk) { console.log("Witaj " + chunk); });
