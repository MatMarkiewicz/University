module.exports = { foo2 };
let module1 = require('./4.1');

function foo2(n) {
    if ( n > 0 ) {
        console.log( `module2: ${n}`);
        module1.foo1(n-1);
    }
}