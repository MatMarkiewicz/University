
let rec length l = 
  match l with
  [] -> 0
  | h::t -> 1 + length t;;

let rec reverse l acc =
  match (l, acc) with
  ([], acc) -> acc
  | (h::t, acc) -> (reverse t (h::acc));;

let rec halve l1 l2 n =
  match (l1,l2,n) with
  ([],l2,n) -> ([],l2)
  | (l1,l2,0) -> (l2,l1)
  | (h::t,l2,n) -> (halve t (h::l2) (n-1));;

let rec ( @ ) l1 l2 =
  match l1 with
  [] -> l2
  | h::t -> h::(t@l2);;

let rec cycle_h l n =
  match (l, n) with
  (l, 0) -> l
  | (h::t, n) -> cycle_h (t@[h]) (n-1);; 

let cycle l n = 
  cycle_h l (length l - n);;

let cycle2 l n =
  let l1, l2 = halve l [] n in
  (reverse l2 [])@l1;;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

print_list(cycle [1;2;3;4] 3);;
print_string("\n");;
print_list(cycle2 [1;2;3;4] 3);;