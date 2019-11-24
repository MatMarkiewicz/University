function forEach( a, f ) {
    for(let i = 0; i < a.length; i++){
        f(a[i]);
    }
};

function map( a, f ) {
    for(let i = 0; i < a.length; i++){
        a[i] = f(a[i]);
    }
    return a
};

function filter( a, f ) {
    var b = [];
    for(let i = 0; i < a.length; i++){
        if (f(a[i])){
            b.push(a[i])
        };
    }
    return b
};

var a = [1,2,3,4];
forEach( a, _ => { console.log( _ ); } );
// [1,2,3,4]
console.log(filter( a, _ => _ < 3 ));
// [1,2]
console.log(map( a, _ => _ * 2 ));
// [2,4,6,8]
    