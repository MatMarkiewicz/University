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

let rec next_resolve xss gl volume = 
  let h::t = xss in 
  if is_resolved gl volume (List.rev h) then ((List.rev h),t) 
  else let i = (List.length gl) - 1 in next_resolve (t@(all_moves h i i)) gl volume;;

let rec lmap f = function
  LNil -> LNil
  | LCons(x,xf) -> LCons(f x, function () -> lmap f (xf()) );;

let rec ltake = function
(0, _) -> []
| (_, LNil) -> []
| (n, LCons(x,xf)) -> x::ltake(n-1, xf());;

let nsol (glasses, volume) n = 
  let rec results_h glasses volume (r,l) = LCons((r,l),function () -> results_h glasses volume (next_resolve l glasses volume) ) in
  let results gl v = lmap (function (a,b) -> a) (results_h gl v ([],[[]])) in
  List.tl (ltake ((n+1),results glasses volume));;
