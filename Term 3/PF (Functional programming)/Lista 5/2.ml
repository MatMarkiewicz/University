type move = FILL of int | DRAIN of int | TRANSFER of int * int;;
type 'a llist = LNil | LCons of 'a * (unit -> 'a llist);;

let rec change_val l n x =
  match l,n with
  ([],n) -> []
  |(h::t,0) -> x::t
  |(h::t,n) -> h::(change_val t (n-1) x);;
  
let next_state glasses state move = 
  match move with
  FILL(n) -> let max = List.nth glasses n in change_val state n max
  |DRAIN(n) -> change_val state n 0
  |TRANSFER(n,m) -> let val1 = List.nth state n and val2 = List.nth state m and max2 = List.nth glasses m in
                   let diff = min (max2 - val2) val1 in change_val (change_val state n (val1-diff)) m (val2 + diff);;

let rec init_state glasses = 
  match glasses with
  [] -> []
  |h::t -> 0::(init_state t);;

let rec is_member x xs =
  match xs with
  [] -> false
  |h::t -> x=h || is_member x t;;

let is_resolved glasses value movements =
  let final_state = List.fold_left (fun a m -> next_state glasses a m) (init_state glasses) movements in
  is_member value final_state;;

let rec all_transfers move n m =
  if n = 0 then (if m = 0 then [] else [((TRANSFER(0,m))::move)])
  else  if n = m then (all_transfers move (n-1) m) else ((TRANSFER(n,m))::move)::(all_transfers move (n-1) m);;

let rec all_moves move n0 n = 
  if n = 0 then ((FILL 0)::move)::((DRAIN 0)::move)::(all_transfers move n0 0)
  else ((FILL n)::move)::((DRAIN n)::move)::((all_transfers move n0 n)@(all_moves move n0 (n-1)));;

let next_level glasses movements =
  let n = (List.length glasses) - 1 in
  List.flatten (List.map (fun move -> all_moves move n n) movements);;
 
let rec movs_tree_lvl lvl gl = LCons (lvl, (function () -> movs_tree_lvl (next_level gl lvl) gl));;   

let nsol (glasses, volume) n = 
  let rec iter results l ll  =
    if List.length results = n then results else
    match l with
    [] -> let LCons(_,f) = ll in let LCons(l2,f2) = f() in iter results l2 (LCons(l2,f2))
    |h::t -> if is_resolved glasses volume (List.rev h) then iter ((List.rev h)::results) t ll else iter results t ll in
  iter [] [] (movs_tree_lvl [[]] glasses);; 


let print_bool b =
  if b then print_string "true" else print_string "false";;

print_bool (is_resolved [4;9] 5 [FILL 1;TRANSFER (1,0)]);;

(*
# next_state gl st (FILL 1);;
- : int list = [4; 9]
# next_state gl st (FILL 0);;
- : int list = [4; 6]
# next_state gl st (DRAIN 0);;
- : int list = [0; 6]
# next_state gl st (TRANSFER (0,1));;a
- : int list = [1; 9]
# all_moves [] 2 2;;
- : move list list =
[[FILL 2]; [DRAIN 2]; [TRANSFER (1, 2)]; [TRANSFER (0, 2)]; [FILL 1];
 [DRAIN 1]; [TRANSFER (2, 1)]; [TRANSFER (0, 1)]; [FILL 0]; [DRAIN 0];
 [TRANSFER (2, 0)]; [TRANSFER (1, 0)]]

# nsol ([4;9],5) 3;;
- : move list list =
[[FILL 1; TRANSFER (0, 1); TRANSFER (1, 0)];
 [FILL 1; FILL 1; TRANSFER (1, 0)]; [FILL 1; TRANSFER (1, 0)]]
 
*)