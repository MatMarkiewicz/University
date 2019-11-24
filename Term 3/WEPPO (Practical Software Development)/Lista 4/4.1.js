module.exports = { foo1 };
let module2 = require('./4.2');

function foo1(n) {
    if ( n > 0 ) {
        console.log( `module1: ${n}`);
        module2.foo2(n-1);
    }
}