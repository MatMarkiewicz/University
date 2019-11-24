var Tree = function (left,right,val){
    this.left = left;
    this.right = right;
    this.val = val;
}

var iter = function(t){
    if (t == null){
        return [];
    } else{
        let t1 = [];
        let t2 = [];
        t1 = iter(t.left);
        t2 = iter(t.right);
        t1.unshift(t.val)
        return t1.concat(t2)
    }
}

/*
Tree.prototype[Symbol.iterator] = function* (){
    for (let e of this.left){
        yield e}
    yield this.val;
    for (let e of this.right){
        yield e;} 
        
}
*/

Tree.prototype[Symbol.iterator] = function* (){
    let t = iter(this);
    for (let i = 0; i < t.length ; i++){
        yield t[i]
    }
}

var testTree = new Tree(new Tree(new Tree(null, null, 3),new Tree(null, null, 4), 2),
                        new Tree(new Tree(null, null, 6),new Tree(null, null, 7), 5), 1);


for (var e of testTree){
    console.log(e)
}