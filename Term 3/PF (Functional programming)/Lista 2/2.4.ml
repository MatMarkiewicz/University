
(*1*)


let rec reverse l acc =
  match (l, acc) with
  ([], acc) -> acc
  | (h::t, acc) -> (reverse t (h::acc));;

let partition p l = 
  let rec partition_h l0 l1 l2 =
    match (l0,l1,l2) with
    ([],l1,l2) -> ((reverse l1 []),(reverse l2 []))
    | (h::t,l1,l2) when (p h) -> (partition_h t (h::l1) l2)
    | (h::t,l1,l2) -> (partition_h t l1 (h::l2))
    in (partition_h l [] []);;


(*2*)


let rec ( @ ) l1 l2 =
  match l1 with
  [] -> l2
  | h::t -> h::(t@l2);;

let rec quicksort cmp l =
  match l with
  [] -> []
  | h::[] -> l
  | h::t -> let l1,l2 = (partition (fun x -> (cmp x h)) t) in (quicksort cmp l1)@(h::(quicksort cmp l2));;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

print_string("Test partition\n");;
let l1,l2 = partition (fun x -> x>5) [1;2;3;4;5;6;7;8;9];;
print_list l1;;
print_string("\n");;
print_list l2;;
print_string("\n");;
print_string("\n");;

print_string("Test quicksort\n");;
print_list(quicksort (fun x y -> x <= y) [1;2;3;4;5;6;7;8;9]);;
print_string("\n");;
print_string("\n");;

