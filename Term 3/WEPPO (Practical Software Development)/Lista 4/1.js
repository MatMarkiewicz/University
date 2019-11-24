var Tree = function(left,right,val){
    this.left = left;
    this.right = right;
    this.val = val;
}

var testTree = new Tree( new Tree( new Tree (null, null, 3), null, 2 ), null, 1);
console.log(testTree)
console.log(testTree.left)