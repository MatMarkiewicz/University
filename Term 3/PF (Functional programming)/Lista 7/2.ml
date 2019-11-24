type 'a list_mutable = LMnil | LMcons of 'a * 'a list_mutable ref

let testLM1 = LMcons(1,ref (LMcons(2,ref (LMcons(3,ref LMnil)))));;
let testLM2 = LMcons(4,ref (LMcons(5,ref (LMcons(6,ref LMnil)))));;

let rec concat_copy l1 l2 =
  match l1 with
  LMnil -> l2
  |LMcons(a,b) when !b = LMnil -> LMcons(a,ref l2)
  |LMcons(a,b) -> LMcons(a,ref (concat_copy !b l2));;

let concat_share l1 l2=
  let rec iter l = 
    match l with
    LMnil -> l2
    |LMcons(a,b) when !b = LMnil -> b := l2; l1
    |LMcons(a,b) -> iter !b in
  iter l1;;

let l1 = (concat_copy testLM1 testLM2);;
let l2 = (concat_share testLM1 testLM2);;

if l1 = l2 then print_string "true" else print_string "false";;
