
(*1*)

let rec ( @ ) l1 l2 =
  match l1 with
  [] -> l2
  | h::t -> h::(t@l2);;

let rec length l = 
  match l with
  [] -> 0
  | h::t -> 1 + length t;;

let rec merge l1 l2 cmp = 
  match (l1,l2) with
  ([],l2) -> l2
  |(l1,[]) -> l1
  |(h1::t1, h2::t2) when (cmp h1 h2) -> h1::(merge t1 (h2::t2) cmp)
  |(h1::t1, h2::t2) -> h2::(merge (h1::t1) t2 cmp);;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_of_chars l =
  match l with
  [] -> ()
  | h::t -> print_char h ; print_string " " ; print_list_of_chars t;;


(*2*)


let rec reverse l acc =
  match (l, acc) with
  ([], acc) -> acc
  | (h::t, acc) -> (reverse t (h::acc));;

let rec merge2_h l1 l2 l3 cmp = 
  match (l1,l2,l3) with
  ([],l2,l3) -> (reverse l3 l2)
  |(l1,[],l3) -> (reverse l3 l1)
  |(h1::t1, h2::t2, l3) when (cmp h1 h2) -> (merge2_h t1 (h2::t2) (h1::l3) cmp)
  |(h1::t1, h2::t2, l3) -> (merge2_h (h1::t1) t2 (h2::l3) cmp);;

let merge2 l1 l2 cmp =
  (merge2_h l1 l2 [] cmp);;

let rec merge3_h l1 l2 l3 cmp = 
  match (l1,l2,l3) with
  ([],l2,l3) -> (reverse l2 l3)
  |(l1,[],l3) -> (reverse l1 l3)
  |(h1::t1, h2::t2, l3) when (cmp h1 h2) -> (merge3_h t1 (h2::t2) (h1::l3) cmp)
  |(h1::t1, h2::t2, l3) -> (merge3_h (h1::t1) t2 (h2::l3) cmp);;

let merge3 l1 l2 cmp =
  (merge3_h l1 l2 [] cmp);;

let rec n_nuts n =
  (if n == 0 then n::[] else n::(n_nuts (n-1)));;


(*3*)

let rec halve l1 l2 n =
  match (l1,l2,n) with
  ([],l2,n) -> ([],l2)
  | (l1,l2,0) -> (l2,l1)
  | (h::t,l2,n) -> (halve t (h::l2) (n-1));;

let rec mergesort l = 
  let m = (length l)/2
    in if m == 0 then l else 
      let l1,l2 = (halve l [] m) in (merge2 (mergesort l1) (mergesort l2) (fun x y -> x <= y));;


let neg f =
  if (f 1 2) then (fun x y -> x >= y) else (fun x y -> x <= y)

let rec mergesort2 l cmp = 
  let m = (length l)/2
    in if m == 0 then l else 
      let l1,l2 = (halve l [] m) in (merge3 (mergesort2 l1 (neg cmp)) (mergesort2 l2 (neg cmp)) cmp);;
  
print_string("Test merge\n");;
print_list(merge [1;3;5;7;9] [2;4;6;8] (fun x y -> x <= y) );;
print_string("\n");;
print_list_of_chars(merge ['a';'d';'f';'j';'p'] ['b';'d';'h';'l';'o';'r'] (fun x y -> x <= y) );;
print_string("\n");;
print_string("\n");;

print_string("Test merge z rekursją ogonową\n");;
print_list(merge2 [1;3;5;7;9] [2;4;6;8] (fun x y -> x <= y) );;
print_string("\n");;
print_list_of_chars(merge2 ['a';'d';'f';'j';'p'] ['b';'d';'h';'l';'o';'r'] (fun x y -> x <= y) );;
print_string("\n");;
print_string("\n");;

print_string("Test mergesort (rekursja ogonowa)\n");;
print_list(mergesort [1;3;4;8;9;4;2;8;0] );;
print_string("\n");;
print_string("\n");;

print_string("Test mergesort (rekursja ogonowa bez odwracania list)\n");;
print_list(mergesort2 [1;3;4;8;9;4;2;8;0;3;5;8;9] (fun x y -> x >= y) );;
print_string("\n");;
print_string("\n");;

(*print_string("Merge n liczb\n");;
*(merge2 (n_nuts 100000) (n_nuts 100000) (fun x y -> x <= y));;
*print_string("\n");;
*print_string("Koniec merga\n");;*)


