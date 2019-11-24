
function fibRec(n){
    if (n==1 || n==2){
        return 1;
    } else{
        return fibRec(n-1) + fibRec(n-2);
    }
};

function memoize(fn) {
    var cache = {};
    return function(n) {
        if ( n in cache ) {
            return cache[n]
        } else {
            var result = fn(n);
            cache[n] = result;
            return result;
        }
    }
};

var memoFib = memoize(fibRec);
for (var i = 10; i<=40; i++){
    console.time("rec" + i);
    fibRec(i);
    console.timeEnd("rec" + i);
    console.time("memo" + i);
    memoFib(i);
    console.timeEnd("memo" + i);
};

for (var i = 10; i<=13; i++){
    console.time("rec" + 35);
    fibRec(35);
    console.timeEnd("rec" + 35);
    console.time("memo" + 35);
    memoFib(35);
    console.timeEnd("memo" + 35);
}