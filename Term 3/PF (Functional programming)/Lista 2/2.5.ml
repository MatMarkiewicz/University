
let rec map l f =
  match l with
  [] -> []
  |h::t -> f h::map t f;;

let rec ( @ ) l1 l2 =
  match l1 with
  [] -> l2
  | h::t -> h::(t@l2);;

let rec concat_map l f = 
  match l with
  [] -> []
  |h::t -> (f h)@(concat_map t f);;

let insert l a =
  let rec insert_h h t =
    match (h,t) with
    (h, []) -> [h@[a]]
    |(h, h2::t2) -> (h@(a::t))::(insert_h (h@[h2]) t2) 
    in (insert_h [] l);;

let rec permutations l = 
  match l with
  [] -> [[]]
  | h::t -> (concat_map (permutations t) (fun x -> insert x h));;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_of_lists l =
  match l with
  [] -> ()
  | h::t -> print_list h ; print_string ";" ; print_list_of_lists t;;

print_list_of_lists(permutations [1;2;3;4]);;
print_string("\n");;
