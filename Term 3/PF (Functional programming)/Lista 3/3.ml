
let segregate xs = 
  let rec segregate_h xs last =
    match xs with
    [] -> [last]
    |h::t when h = List.hd last -> segregate_h t (h::last)
    |h::t -> last::(segregate_h t [h]) in
  segregate_h (List.tl xs) [(List.hd xs)];;
  
let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_of_lists l =
  match l with
  [] -> ()
  | h::t -> print_list h ; print_string ";" ; print_list_of_lists t;;

print_list_of_lists (segregate [1;2;2;5;6;6;6;2;2]);;