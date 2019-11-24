var lineReader = require('readline').createInterface({
    input: require('fs').createReadStream('logs.txt')
});

function sortObject(obj) {
    var arr = [];
    for (var prop in obj) {
        if (obj.hasOwnProperty(prop)) {
            arr.push([prop,obj[prop]])
        }
    }
    arr.sort(function(a, b) { return a[1] - b[1]; });
    return arr;
}

var ips = {}
lineReader.on('line', function (line) {
    var ip = line.split(" ")[1];
    if (ip in ips){
        ips[ip] = ips[ip] + 1;
    } else{
        ips[ip] = 1
    }   
})
lineReader.on('close', function(){
    var sorted = sortObject(ips).reverse();
    console.log(sorted[0]);
    console.log(sorted[1]);
    console.log(sorted[2]);
})

