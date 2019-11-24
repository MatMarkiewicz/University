type 'a prop = Var of 'a | Top | Bot
             | Conj of 'a prop * 'a prop
             | Disj of 'a prop * 'a prop
             | Impl of 'a prop * 'a prop

type 'a ps = PDone of 'a prop
  | PConc of 'a prop * 'a ps
  | PHyp  of 'a shyp * 'a ps
and 'a shyp = 'a prop * 'a ps

let rec equal_prop p1 p2 =
  match p1,p2 with
  (Var(c1),Var(c2)) -> c1=c2
  |(Top,Top) -> true
  |(Bot,Bot) -> true
  |(Conj(p11,p12),Conj(p21,p22)) -> (equal_prop p11 p21) && (equal_prop p12 p22)
  |(Disj(p11,p12),Disj(p21,p22)) -> (equal_prop p11 p21) && (equal_prop p12 p22)
  |(Impl(p11,p12),Impl(p21,p22)) -> (equal_prop p11 p21) && (equal_prop p12 p22)
  |(_,_) -> false;;

let rec is_member x xs =
  match xs with
  [] -> false
  |h::t -> (equal_prop x h) || is_member x t;;

let is_I prop checked =
  match prop with
  Var(c) -> is_member (Var(c)) checked
  | Top -> true
  | Bot -> false
  | Conj(p1,p2) -> (is_member p1 checked) && (is_member p2 checked)
  | Disj(p1,p2) -> (is_member p1 checked) || (is_member p2 checked)
  | Impl(p1,p2) -> is_member (Impl(p1,p2)) checked;;

let is_EB prop checked =
  is_member Bot checked;;

let rec is_ECL prop checked =
  match checked with
  [] -> false
  | h::t -> (match h with
          Conj(prop,_) -> true
          | _ -> false) || (is_ECL prop t);;

let rec is_ECR prop checked =
  match checked with
  [] -> false
  | h::t -> (match h with
          Conj(_,prop) -> true
          | _ -> false) || (is_ECR prop t);;

let is_EI prop checked =
  let rec iter ched =
    match ched with
    [] -> false
    | h::t -> (match h with
            Impl(q,prop) -> (is_member q checked)
            | _ -> false) || (iter t) 
  in iter checked;;

let rec all_pairs l =
  let rec pairs_with_p p xs =
    match xs with
    [] -> []
    | h::t -> (p,h)::(pairs_with_p p t)
  in match l with
  [] -> []
  | h::[] -> []
  | h::t -> (pairs_with_p h t)@(all_pairs t);;

let is_ED prop checked =
  let rec all_impl prop ched =
    match ched with
    [] -> []
    | (Impl(q,prop))::t -> q::(all_impl prop t)
    | _::t -> (all_impl prop t) in
  let list_of_preds = all_impl prop checked in
  let pairs = all_pairs list_of_preds in
  let rec iter pairs = 
    match pairs with
    [] -> false
    | (a,b)::t -> (is_member (Disj(a,b)) checked) || (iter t)
  in iter pairs;;

let rec is_E prop checked =
  (is_ECL prop checked) || (is_ECR prop checked) || (is_ED prop checked) || (is_EI prop checked) || (is_EB prop checked);;

type 'a ress = ResTs of 'a prop | ResFs

let rec ps_check ps checked =
  match ps with
  PDone(prop) -> if (is_I prop checked) || (is_E prop checked) then ResTs(prop) else ResFs
  | PConc(prop,ps2) -> if (is_I prop checked) || (is_E prop checked) then ps_check ps2 (prop::checked) else ResFs
  | PHyp((hypprop,hypps),ps2) -> let res = ps_check hypps (hypprop::checked) in
                                match res with
                                ResTs(prop) -> ps_check ps2 ((Impl(hypprop,prop))::checked)
                                | ResFs -> ResFs;;

                      
let rec print_form f =
  match f with
  Top -> print_string "T"
  |Bot -> print_string "F"
  |Var(c) -> print_string c
  |Conj(f1,f2) -> print_string "("; print_form f1; print_string " ^ "; print_form f2; print_string ")"
  |Disj(f1,f2) -> print_string "("; print_form f1; print_string " v "; print_form f2; print_string ")"
  |Impl(f1,f2) -> print_string "("; print_form f1; print_string " => "; print_form f2; print_string ")"                                

let print_check_s (s,prop,ps) =
  let res = ps_check ps [] in
  print_string s; print_newline();
  match res,prop with
  (ResTs(rp),p) when rp = p -> print_string "Dowod poprawny" ; print_newline (); print_form p
  | (ResTs(rp),p) -> print_string "Dowod niepoprawny, dowiedziono inna formule" ; print_newline (); print_form p; print_newline (); print_form rp
  | (ResFs,_) -> print_string "Dowod niepoprawny, blad w dowodzie";;


let main proofs =
  List.map (fun p -> (print_check_s p) ; print_newline (); print_newline ()) proofs;;  

let test11 = PHyp(
  (Conj(Var("A"),Impl(Var("A"),Var("B"))),
  PConc(
    Var("A"),
    PConc(
      Impl(Var("A"),Var("B")),
      PDone(
        Var("B")
      )
    )
  )),
  PDone(Impl(Conj(Var("A"),Impl(Var("A"),Var("B"))),Var("B")))
);;

let test12 = PHyp(
  (Conj(Var("A"),Impl(Var("A"),Var("B"))),
  PConc(
    Var("A"),
    PConc(
      Impl(Var("A"),Var("B")),
      PDone(
        Var("C")
      )
    )
  )),
  PDone(Impl(Conj(Var("A"),Impl(Var("A"),Var("B"))),Var("B")))
);;


let test13 = PHyp(
  (Conj(Var("P"),Var("Q")),
  PConc(
    Var("P"),
    PDone(Disj(Var("P"),Var("Q")))
  )),
  PDone(Impl(Conj(Var("P"),Var("Q")),Disj(Var("P"),Var("Q"))))
);;

let test14 = PHyp(
  (Disj(Var("P"),Var("Q")),
  PConc(
    Var("P"),
    PDone(Disj(Var("P"),Var("Q")))
  )),
  PDone(Impl(Conj(Var("P"),Var("Q")),Disj(Var("P"),Var("Q"))))
);;

let test15 = PHyp(
  (Var("P"),
  PHyp(
    (Var("Q"),PDone(Var("P"))),
    PDone(Impl (Var "Q", Var "P"))
  )),
  PDone((Impl (Var "P", Impl (Var "Q", Var "P"))))
);;

let test16 = PHyp(
  (Var("P"),
  PHyp(
    (Var("Q"),PDone(Var("P"))),
    PDone(Impl (Var "P", Var "Q"))
  )),
  PDone((Impl (Var "P", Impl (Var "Q", Var "P"))))
);;

let test17 = PHyp(
  (Impl (Disj (Var "P", Var "Q"), Var "R"),
  PHyp(
    (Var("Q"),PConc(Disj (Var "P", Var "Q"),
      PDone(Var("R")))
    ),
    PDone(Impl (Var "Q", Var "R"))
  )),
  PDone((Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))))
);;

let test18 = PHyp(
  (Impl (Disj (Var "P", Var "Q"), Var "R"),
  PHyp(
    (Var("Q"),PConc(Disj (Var "P", Var "Q"),
      PDone(Var("R2")))
    ),
    PDone(Impl (Var "Q", Var "R"))
  )),
  PDone((Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))))
);;

let proofs =
  [("naza11",(Impl (Conj (Var "A", Impl (Var "A", Var "B")), Var "B")),test11);
  ("naza12",(Impl (Conj (Var "A", Impl (Var "A", Var "B")), Var "B")),test12);
  ("nazwa13",Impl(Conj(Var("P"),Var("Q")),Disj(Var("P"),Var("Q"))),test13);
  ("nazwa14",Impl(Conj(Var("P"),Var("Q")),Disj(Var("P"),Var("Q"))),test14);
  ("nazwa15",(Impl (Var "P", Impl (Var "Q", Var "P"))),test15);
  ("nazwa16",(Impl (Var "P", Impl (Var "Q", Var "P"))),test16);
  ("nazwa17",(Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))),test17);
  ("nazwa18",(Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))),test18)
  ];;

main(proofs);;

