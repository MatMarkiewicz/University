type 'a btree = Leaf | Node of 'a btree * 'a * 'a btree;;
let btree = Node(Node(Node(Leaf,3,Leaf),2,Leaf),1,Node(Node(Leaf,5,Leaf),4,Node(Leaf,6,Leaf)));;
let btree2 = Node(Node(Node(Leaf,3,Leaf),2,Leaf),1,Node(Node(Leaf,5,Leaf),4,Node(Leaf,6,Node(Leaf,7,Leaf))));;
let btree3 = Node(Node(Leaf,1,Leaf),2,Node(Leaf,3,Leaf));;

let prod btree =
  let rec prod_cps bt k = 
    match bt with
    Leaf -> k 1
    |Node(l,v,r) when v = 0 -> 0
    |Node(l,v,r) -> prod_cps l (fun x -> prod_cps r (fun y -> k x*v*y))
  in prod_cps btree (fun x -> x);;

print_int (prod btree);;
print_string("\n");;
print_int (prod btree2);;
print_string("\n");;
print_int (prod btree3);;
print_string("\n");;

