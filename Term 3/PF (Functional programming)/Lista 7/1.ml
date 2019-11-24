(*1*)

let rec fix f = 
  fun x -> f (fix f) x;;

let rec fact0 x =
  if x = 0 then 1 else x * (fact0 (x-1));;
  
let fact = fix ( fun f -> fun n -> if n = 0 then 1 else n * (f (n-1)));;

List.map fact [1;2;3;4;5;6;7;8;9;10;11;12];;

(*2*)

let fact2 =
  let fact_helper = ref (fun x -> x) in
  let f = fun x -> if x = 0 then 1 else x * (!fact_helper (x - 1)) in
  fact_helper := f;
  fun x -> !fact_helper x;;

List.map fact2 [1;2;3;4;5;6;7;8;9;10;11;12];;

let fix2 f =
  let fix_helper = ref (fun x -> x) in
  let fix' f' n = f' !fix_helper n in
  fix_helper := fix' f;
  !fix_helper;;

let fact3 = fix2 ( fun f -> fun n -> if n = 0 then 1 else n * (f (n-1)));;

(*
type 'a fix = Fix of ('a fix -> ?)

let y = fun f -> ((fun (x: 'a fix) -> f(x x)))((fun (x: 'a fix) -> f(x x)))
*)

List.map fact3 [1;2;3;4;5;6;7;8;9;10;11;12];;