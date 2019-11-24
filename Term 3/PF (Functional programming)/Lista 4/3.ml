
type 'a mtree = MNode of 'a * 'a forest
and 'a forest = EmptyForest | Forest of 'a mtree * 'a forest;;
type 'a mtree_lst = MTree of 'a * ('a mtree_lst ) list;;


let testmt = MNode(1,Forest(MNode(2,EmptyForest),Forest(MNode(3,EmptyForest),Forest(MNode(4,EmptyForest),EmptyForest))));;

let testmtreelst = MTree(1,[MTree(2,[]);MTree(3,[MTree(5,[]);MTree(6,[]);MTree(7,[])]);MTree(4,[])]);;

let rec preorder mtree =
  let rec preorderf forest = 
    match forest with
    EmptyForest -> [[]]
    | Forest(mt,f) -> (preorder mt)::(preorderf f) in
  let MNode(v,f) = mtree in v::(List.flatten (preorderf f));;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

print_list(preorder testmt);;

(*Używając typów mtree_lst*)

let rec preorder2 mtree labels = 
  let MTree(v,l) = mtree in v::(List.fold_right (fun x acc -> preorder2 x acc) l labels);;


let rec breadth mtree = 
  let rec breadthl mtree_lst = 
    match mtree_lst with
    [] -> []
    |mt::t -> let MTree(v1,l1) = mt in v1::(breadthl (t@l1)) in
  let MTree(v,l) = mtree in v::(breadthl l);;

print_string("\n");;
print_list(preorder2 testmtreelst []);;
print_string("\n");;
print_list(breadth testmtreelst);;