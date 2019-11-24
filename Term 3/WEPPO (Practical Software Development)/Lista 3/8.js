
function* fib(){
    for(var i = 1, j = 0; true; i=i+j, j=i-j){
        yield i;
    }
};

function* take(it, top) {
    for (let i = 0; i < top; i++){
        yield it.next().value;
    };
}
    // zwróć dokładnie 10 wartości z potencjalnie
    // "nieskończonego" iteratora/generatora

for (let num of take( fib(), 10 ) ) {
    console.log(num);
}