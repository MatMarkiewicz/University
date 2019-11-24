type 'a llist = LNil | LCons of 'a * (unit -> 'a llist);;

let lhd = function
  LNil -> failwith "lhd"
  | LCons (x, _) -> x;;

let ltl = function
  LNil -> failwith "ltl"
  | LCons (_, xf) -> xf();;

let rec lfrom k = LCons (k, function () -> lfrom (k+1));;

let rec ltake = function
  (0, _) -> []
  | (_, LNil) -> []
  | (n, LCons(x,xf)) -> x::ltake(n-1, xf());;

let rec (@$) ll1 ll2 =
  match ll1 with
  LNil -> ll2
  | LCons(x, xf) -> LCons(x, function () -> (xf()) @$ ll2);;

let rec lmap f = function
  LNil -> LNil
  | LCons(x,xf) -> LCons(f x, function () -> lmap f (xf()) );;

let rec lfilter pred = function
  LNil -> LNil
  | LCons(x,xf) -> if pred x
  then LCons(x, function () -> lfilter pred (xf()) )
  else lfilter pred (xf());;

let rec ltakeWithTail = function
  (0, xq) -> ([],xq)
  | (_, LNil) -> ([],LNil)
  | (n, LCons(x,xf)) ->
  let (l,tail)=ltakeWithTail(n-1, xf())
  in (x::l,tail);;
  

(*a*)

let rec pi_n p n z = LCons(p,function () -> pi_n (p +. (z *. (1.0 /. n))) (n +. 2.0) (z *. -1.0));;

(*b*)

let rec map3 f stream = 
  let rec iter f x1 x2 x3 str = 
    let LCons(x4,nstr) = str() in LCons(f x1 x2 x3,function () -> iter f x2 x3 x4 nstr) 
  in let ([x1;x2],LCons(x3,str)) = ltakeWithTail (2,stream) in iter f x1 x2 x3 str;;

(*c*)

let pi2 = map3 (fun x y z -> z -. ( (y -. z) *. (y -. z) /. (x -. 2.0 *. y +. z)) ) (pi_n 1.0 3.0 (-1.0));;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_f l =
match l with
[] -> ()
| h::t -> print_float h ; print_string " " ; print_list_f t;;

print_list_f (ltake (10,(pi_n 1.0 3.0 (-1.0))));;
print_string("\n");;
print_float (4.0 *. (List.nth (ltake (100,(pi_n 1.0 3.0 (-1.0)))) 99));;
print_string("\n");;

let nats = lfrom 1;;
print_list (ltake (10,map3 (fun a b c -> a+b+c) nats));;
print_string("\n");;

print_list_f (ltake (10,pi2));;
print_string("\n");;
print_float (4.0 *. (List.nth (ltake (100,pi2)) 99))