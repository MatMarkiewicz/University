type 'a lnode = {item: 'a; mutable next: 'a lnode};;

let mk_circular_list e =
  let rec x = {item=e; next=x}
  in x;;

let insert_head e l =
  let x = {item=e; next=l.next}
  in l.next <- x; l;;

let elim_head l = l.next <- (l.next).next; ();;

let create_circular_list n =
  let l0 = mk_circular_list n in
  let rec iter n l =
    if n = 0 then l else iter (n-1) (insert_head n l) in
  iter (n-1) l0;;

let rec cl_nth cl n =
  if n = 1 then cl else cl_nth (cl.next) (n-1);;

let j_perm n m =
  let cl = create_circular_list n in
  let rec iter i xs cl =
    if i = n then xs else
      let l = cl_nth cl m in
       let v = (l.next).item in elim_head l ; iter (i+1) (v::xs) l in
  List.rev (iter 0 [] cl);;

j_perm 7 3;;
