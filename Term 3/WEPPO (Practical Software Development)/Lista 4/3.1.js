
var Foo = function(a){
    this.a = a;
}

Foo.prototype.bar = function(b){
    (function qux(){
        console.log("test" + b);
    })();
}

var t = new Foo(1)
t.bar(2)
/*t.qux()
t.bar.qux()*/
