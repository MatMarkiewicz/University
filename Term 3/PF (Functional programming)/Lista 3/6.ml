
let rec pairs n = 
  let rec pairs_with_x x n = 
    if x + n + 1 >= 100 then [] else (x,n+1)::(pairs_with_x x (n+1)) in
    if n = 50 then [] else (pairs_with_x n n)@(pairs (n+1));;

let all_pairs = pairs 2;;

let pairs_with_sum sum = List.filter (fun (x,y) -> x+y = sum) all_pairs;;
let pairs_with_prod prod = List.filter (fun (x,y) -> x*y = prod) all_pairs;;

let helper_solve_p sum = 
  List.for_all (fun xs -> (List.length xs) > 1) (List.map (fun x -> pairs_with_prod x) (List.map (fun (x,y) -> x*y) (pairs_with_sum sum)));;
  
let solve_p prod = 
  let pairs_with_prod = pairs_with_prod prod in
  List.length (List.filter (fun (x,y) -> helper_solve_p (x+y)) pairs_with_prod) = 1;;

let solve_s sum = 
  let pairs_with_sum = pairs_with_sum sum in
  List.length (List.filter (fun (x,y) -> solve_p (x*y)) pairs_with_sum) = 1;;

let prods = List.map (fun (x,y) -> x*y) all_pairs;;

List.filter (fun (x,y) -> solve_p (x*y) && solve_s (x+y)) all_pairs;;

let rec nuts n = 
  if n = 100 then [] else n::(nuts (n+1));;

let print_pair (x,y) = print_int(x) ; print_string", "; print_int(y);;

print_pair(List.hd (solve_p 88));;
print_string("\n");;
print_pair(List.hd (solve_s 19));;


(*List.filter (fun xs -> (List.length xs) = 1) (List.map (fun prod -> solve_p prod) prods);;*)
(*List.filter (fun xs -> (List.length xs) = 1) (List.map (fun sum -> solve_s sum) sums);;*)
(*[[(2, 3)]; [(2, 4)]; [(1, 6)]; [(3, 5)]; [(1, 8)]; [(7, 8)]; [(1, 16)];
 [(8, 11)]; [(4, 19)]; [(8, 20)]; [(8, 58)]; [(2, 70)]; [(1, 80)]; [(6, 90)];
 [(6, 92)]]*)
 (*[[(1, 6)]; [(1, 8)]; [(1, 6)]; [(1, 15)]; [(1, 8)]; [(7, 8)]; [(1, 16)];
 [(8, 11)]; [(4, 19)]; [(5, 32)]; [(16, 29)]; [(7, 20)]; [(5, 16)];
 [(20, 27)]; [(23, 24)]]*)

 (*
 (1,6),(1,8),(7,8),(1,16),(8,11),(4,19),
 *)