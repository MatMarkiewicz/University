
type form = Var of char | Neg of form | Con of form * form | Alt of form * form;;

let testform = Con(Alt(Var('p'),Var('q')),Neg(Var('r')));;
let testform2 = Neg(Con(Var('p'),Neg(Var('p'))));;

let rec is_member x xs =
  match xs with
  [] -> false
  |h::t -> x=h || is_member x t;;

let rec remove_duplicates xs ys =
  match xs with
  [] -> ys
  |h::t -> if is_member h ys then remove_duplicates t ys else remove_duplicates t (h::ys)

let rec vars f = 
  let rec vars_iter form = 
    match form with
    Var(c) -> [c]
    | Neg(f1) -> (vars f1)
    | Con(f1,f2) -> (vars f1)@(vars f2)
    | Alt(f1,f2) -> (vars f1)@(vars f2) in
  remove_duplicates (vars_iter f) [];;

let rec vals vars = 
  match vars with
  [] -> [[]]
  |v::t -> let valst = (vals t) in (List.map (fun xs -> (v,true)::xs) valst)@(List.map (fun xs -> (v,false)::xs) valst);;

let rec find_val p val0 = 
  match val0 with
  [] -> false
  |(h,b)::t when h = p -> b
  |(h,b)::t -> find_val p t;;

let rec value f val0 = 
  match f with
  Var(c) -> find_val c val0
  | Neg(f1) -> not (value f1 val0)
  | Con(f1,f2) -> (value f1 val0) && (value f2 val0)
  | Alt(f1,f2) -> (value f1 val0) || (value f2 val0)

let is_taut f =
  let rec iter vals = 
    match vals with
    [] -> (true,[])
    |v::t -> if not (value f v) then (false,v) else iter t in
  let vars = vars f in let vals = vals vars in iter vals;;
  
let rec nnf form = 
  match form with
  Var(c) -> Var(c)
  | Con(f1,f2) -> Con((nnf f1),(nnf f2)) 
  | Alt(f1,f2) -> Alt((nnf f1),(nnf f2))
  | Neg(f) -> 
      match f with
      Var(c) -> Neg(Var(c))
    | Con(f1,f2) -> Alt((nnf (Neg(f1))),(nnf (Neg(f2))))
    | Alt(f1,f2) -> Con((nnf (Neg(f1))),(nnf (Neg(f2))))
    | Neg(f1) -> (nnf f1);;

type literal = Literal of char * bool

let rec cnf_clause val0 = 
  match val0 with
  [] -> []
  |h::t -> let (v,b) = h in if b then Literal(v,not b)::(cnf_clause t) else Literal(v,b)::(cnf_clause t);;

let cnf_h form = 
  let rec iter vals =
    match vals with
    [] -> []
    |h::t when (not (value form h)) -> (cnf_clause h)::(iter t)
    |h::t -> (iter t) in
    iter (vals (vars form));;

let rec dnf_clause val0 = 
  match val0 with
  [] -> []
  |h::t -> let (v,b) = h in if b then Literal(v,b)::(dnf_clause t) else Literal(v,not b)::(dnf_clause t);;

let dnf_h form = 
  let rec iter vals =
  match vals with
  [] -> []
  |h::t when (value form h) -> (dnf_clause h)::(iter t)
  |h::t -> (iter t) in
  iter (vals (vars form));;

let rec exp a n = 
  if n=0 then 1 else a*(exp a (n-1));;
  
let is_taut f =
  let dnf = dnf_h f and vars = vars f in List.length dnf = exp 2 (List.length vars);;

let is_cont f =
  let cnf = cnf_h f and vars = vars f in List.length cnf = exp 2 (List.length vars);;

(*
pVq ^ -r
cnf - [[Neg (Var 'r'); Neg (Var 'p'); Neg (Var 'q')];
 [Neg (Var 'r'); Neg (Var 'p'); Var 'q'];
 [Neg (Var 'r'); Var 'p'; Neg (Var 'q')]; [Neg (Var 'r'); Var 'p'; Var 'q'];
 [Var 'r'; Var 'p'; Var 'q']]
 dnf - [[Neg (Var 'r'); Var 'p'; Var 'q']; [Neg (Var 'r'); Var 'p'; Neg (Var 'q')];
 [Neg (Var 'r'); Neg (Var 'p'); Var 'q']]
*) 

type 'a altm = Altm of 'a list;;
type 'a conm = Conm of 'a list;;
type conml = Conml of literal list;;
type altml = Altml of literal list;;
type cnf_form = Altm of conml list;;
type dnf_form = Conm of altml list;;

let cnf form = 
  let l = cnf_h form in Altm(List.map (fun xs -> Conml xs) l);;

let dnf form = 
  let l = dnf_h form in Conm(List.map (fun xs -> Altml xs) l);;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_char h ; print_string " " ; print_list t;;



(*
print_list(vars testform);;
*)