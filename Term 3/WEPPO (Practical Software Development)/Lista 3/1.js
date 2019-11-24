
var object = {
    i : 10,
    foo : function(x){
        return object.i * x;
    },
    get bar() {
        return object.i;
    },
    set bar(x) {
        object.i = x;
    }
}

console.log(object.i);
console.log(object.foo(5));
console.log(object.bar);
object.bar = 20;
console.log(object.bar);

object.j = 20;
object.foo2 = function(x) {
    return object.j * x;
};

Object.defineProperty( object, 'bar2', {
    get : function() {
        return object.j;
    }
});

Object.defineProperty( object, 'bar3', {
    set : function(x) {
        object.j = x
    }
});

console.log(object.j);
console.log(object.foo2(5));
console.log(object.bar2);
object.bar3 = 30;
console.log(object.bar2);
