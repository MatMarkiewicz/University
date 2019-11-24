
function toDigits(n){
    return String(n).split("").map(function(x){
        return parseInt(x);
    });
};

function sumOfElements(l){
    var sum = 0;
    l.forEach(element => {
        sum += element
        });
    return sum;
};

function divisibleByDigits(n){
    function divisible(m){
        return n % m === 0;
    }
    var digits = toDigits(n);
    return digits.every(divisible) && divisible(sumOfElements(digits));
}

var array = [];
for(var i = 1; i < 100000; i++){
    if (divisibleByDigits(i)){
        array.push(i);
    }
}

console.log(array)
