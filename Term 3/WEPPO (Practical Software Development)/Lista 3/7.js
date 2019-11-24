
function fib(n) {
    var _fib = 1;
    var _fib1 = 0;
    return {
        next : function() {
            var _fibp = _fib1;
            _fib1 = _fib;
            _fib = _fib1 + _fibp;
            return {
                value : _fib1,
                done : false
            }
        }
    }
}

var _it = fib();
var n = 10
for ( var _result; _result = _it.next(), !_result.done && n > 0; ) {
    console.log( _result.value );
    n--;
}

function* fib2(){
    for(var i = 1, j = 0; true; i=i+j, j=i-j){
        yield i;
    }
};
var _it2 = fib2();
var n2 = 10
for ( var _result; _result = _it2.next(), !_result.done && n2 > 0; ) {
    console.log( _result.value );
    n2--;
}
/*for ( var i of fib2() ) {
    console.log( i );
}*/