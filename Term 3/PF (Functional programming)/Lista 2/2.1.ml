
let rec map l f =
  match l with
  [] -> []
  |h::t -> f h::map t f;;

let rec add_edited l f l0 = 
  match l with
  [] -> []
  | h::[] -> (f h)::l0
  | h::t -> (f h)::(add_edited t f l0);;
  
let rec sublist l =
  match l with
  [] -> [[]]
  | h::t -> let sub = (sublist t) in (add_edited sub (fun l2 -> h::l2) sub);;
  
let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_of_lists l =
  match l with
  [] -> ()
  | h::t -> print_list h ; print_string ";" ; print_list_of_lists t;;
    
print_list_of_lists(sublist [1;2;3]);;
print_string "\n";;
print_list_of_lists(sublist []);;
print_string "\n";;
print_list_of_lists(sublist [1;2;3;4;5]);;

