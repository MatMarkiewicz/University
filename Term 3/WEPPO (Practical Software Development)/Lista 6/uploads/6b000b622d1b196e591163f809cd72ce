
function isPrime(n){
    if (n == 2 || n == 1){
        return true;
    } else{
        for (var i = 2; i**2 <= n; i++){
            if (n%i === 0){
                return false;
            }
        }
        return true;
    }
}

var primes = [];
for (var i = 2; i < 100000; i++){
    if (isPrime(i)){
        primes.push(i);
    }
}

console.log(primes)