type 'a place = Begin | Middle of 'a place * 'a | Place of 'a place * 'a list ;;

let rec findNth xs n =
  let rec iter l m p =
    match l with
    [] -> Place(Begin,[])
    |h::[] when n=m -> Place(p,[h])
    |h::[] -> Place(Middle(p,h),[])
    |h::t when n=m -> Place(p,h::t)
    |h::t -> iter t (m+1) (Middle(p,h))
  in iter xs 0 Begin;;

let rec collapse p = 
  match p with
  Begin -> []
  |Middle(p1,v) -> (collapse p1)@[v]
  |Place(p1,t) -> (collapse p1)@t;;

let add x p =
  let Place(p1,t) = p in Place(p1,x::t);;

(*[1;2;4]*)

let del p = 
  match p with
  Place(p1,h::t) -> Place(p1,t)
  |Place(p1,[]) -> Place(p1,[]);;

let next p =
  match p with
  Place(p1,h::t) -> Place(Middle(p1,h),t)
  |Place(p1,[]) -> Place(p1,[]);;

let prev p =
  match p with
  Place(Begin,t) -> Place(Begin,t)
  |Place(Middle(p,v),t) -> Place(p,v::t);;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

print_list(collapse (add 3 ( findNth [1;2;4] 2)));;
print_string"\n";;
print_list(collapse (del ( findNth [1;2;4] 2)));;
print_string"\n";;
print_list(collapse (del (add 3 (findNth [1;2;4] 2))));;
print_string"\n";;
print_list(collapse (add 3 ( next (findNth [1;2;4] 1))));;
print_string"\n";;
print_list(collapse (add 3 ( prev (findNth [1;2;4] 3))));;