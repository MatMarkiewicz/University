type 'a btree = Leaf | Node of 'a btree * 'a * 'a btree;;
let btree = Node(Node(Node(Leaf,3,Leaf),2,Leaf),1,Node(Node(Leaf,5,Leaf),4,Node(Leaf,6,Leaf)));;
let btree2 = Node(Node(Node(Leaf,3,Leaf),2,Leaf),1,Node(Node(Leaf,5,Leaf),4,Node(Leaf,6,Node(Leaf,7,Leaf))));;

let rec nodes btree = 
  match btree with
  Leaf -> 0
  | Node(l,v,r) -> 1 + (nodes l) + (nodes r);;

let is_balanced btree = 
  let rec iter bt = 
    match bt with
    Leaf -> (true,0)
    | Node(l,v,r) -> let (b1,n1) = (iter l) and (b2,n2) = (iter r) in (b1&&b2&&(abs(n1-n2)<=1),n1+n2+1) in
  let (b,n) = (iter btree) in b;;

let print_bool b = 
  if b then print_string("true \n") else print_string("false \n");;

print_bool(is_balanced btree);;
print_bool(is_balanced btree2);;

let halve xs =
  let m = (List.length xs)/2 in
  let rec iter l n=
    match l with
    [] -> ([],[])
    | h::t when n = m -> ([],h::t)
    | h::t -> let (h1,t1) = (iter t (n+1)) in (h::h1,t1) in iter xs 0;;
  
let rec list_to_bbtree l = 
  match l with
  [] -> Leaf
  |h::t-> let (l1,l2) = halve t in Node((list_to_bbtree l1),h,(list_to_bbtree l2));;

let preorder t =
  let rec preord = function
    (Leaf, labels) -> labels
    | (Node(t1,v,t2), labels) -> v :: preord (t1, preord (t2, labels))
  in preord (t,[]);;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;


print_list(preorder (list_to_bbtree [1;2;3;4;5;6]));;
print_string("\n");;
print_bool(is_balanced (list_to_bbtree [1;2;3;4;5;6]));;
