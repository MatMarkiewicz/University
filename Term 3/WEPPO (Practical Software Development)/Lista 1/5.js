
function fibRec(n){
    if (n==1 || n==2){
        return 1;
    } else{
        return fibRec(n-1) + fibRec(n-2);
    }
}

function fibIter(n){
    var a=0, b=1;
    for (var i = 0; i<n; i++){
        b += a;
        a = b-a;
    }
    return a;
}

for (var i = 10; i<=40; i++){
    console.time("rec" + i);
    fibRec(i);
    console.timeEnd("rec" + i);
    console.time("iter" + i);
    fibIter(i);
    console.timeEnd("iter" + i);
}
