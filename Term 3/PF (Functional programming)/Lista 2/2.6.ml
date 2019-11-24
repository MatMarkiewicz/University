
let rec map l f =
  match l with
  [] -> []
  |h::t -> f h::map t f;;

let rec ( @ ) l1 l2 =
  match l1 with
  [] -> l2
  | h::t -> h::(t@l2);;

let rec suffixes l =
  match l with
  [] -> [[]]
  | h::t -> let h2::t2 = (suffixes t) in (h::h2)::h2::t2;;

let rec prefixes l =
  match l with
  [] -> [[]]
  |h::t -> []::(map (prefixes t) (fun l2 -> h::l2));;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_of_lists l =
  match l with
  [] -> ()
  | h::t -> print_list h ; print_string ";" ; print_list_of_lists t;;

print_list_of_lists(suffixes [1;2;3]);;
print_string("\n");;
print_list_of_lists(prefixes [1;2;3]);;
print_string("\n");;