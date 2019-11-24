
var foo = function() {
    var object = {
        bar : function (){
            private = 42;
            qux();
        },
        public : 10
    };
    var private = 42;
    function qux(){
        private = 42;
        object.public = 10;
        object.bar();
    }
    return object
}();

foo.bar().qux()