
let rec not_decreasing_prefix hd tl =
  match (hd, tl) with
  (hd,[]) -> (hd,[])
  |([],h::t) -> not_decreasing_prefix [h] t
  |(h1::t1,h2::t2) when h2 >= h1 -> not_decreasing_prefix (h2::h1::t1) t2
  |(h1::t1,h2::t2) -> (h1::t1,h2::t2);;

let rec swap hd tl x =
  match tl with
  [] -> (hd,x)
  |h::t when h > x -> ((hd@(x::t)), h)
  |h::t -> swap (hd@[h]) t x;;

let next_perm xs =
  let (hd,tl) = not_decreasing_prefix [] xs in
  if tl = [] then hd else
  let h::t = tl in
  let (s,x) = swap [] (List.rev hd) h in (List.rev s)@(x::t);;


let rec fact n =
  if n = 0 then 1 else n*(fact (n-1));;

let rec perms p aperms n nmax =
  if n >= nmax then aperms else 
  let np = next_perm p in perms np (aperms@[np]) (n+1) nmax;;

let all_perms p = perms p [] 0 (fact (List.length p));;

let rec print_list_of_chars l = 
  match l with
  [] -> ()
  | h::t -> print_char h ; print_string " " ; print_list_of_chars t;;
let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;
let print_perm_c p =
  print_list_of_chars p;;
let print_perm p =
  print_list (List.rev p);;
let rec print_perms xss =
  match xss with
  [] -> ()
  |h::t -> print_perm h; print_string "\n"; print_perms t;;
let rec print_perms_c xss =
  match xss with
  [] -> ()
  |h::t -> print_perm_c h; print_string "\n"; print_perms_c t;;
  

print_perms(all_perms [4;3;2;1]);;
print_string("\n");;
print_perms_c(all_perms ['c';'b';'a']);;