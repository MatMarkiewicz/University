(** Typ danych reprezentujący formuły zdaniowe *)
type 'a prop = Var of 'a | Top | Bot
             | Conj of 'a prop * 'a prop
             | Disj of 'a prop * 'a prop
             | Impl of 'a prop * 'a prop

(** Typ danych reprezentujący drzewa dowodu w systemie dedukcji
   naturalnej, wraz z typem ramek *)
type 'a pt = Ax of 'a prop
           | TopI
           | ConjI  of 'a pt * 'a pt
           | DisjIL of 'a pt * 'a prop
           | DisjIR of 'a prop * 'a pt
           | ImplI  of 'a hypt
           | BotE   of 'a prop
           | ConjEL of 'a pt
           | ConjER of 'a pt
           | DisjE  of 'a pt * 'a hypt * 'a hypt
           | ImplE  of 'a pt * 'a pt
and 'a hypt = 'a prop * 'a pt

(** Typ danych reprezentujący skryptowy zapis dowodu (patrz lista 5) w
   systemie dedukcji naturalnej, wraz z typem ramek *)
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

type 'a res = ResT of 'a prop | ResF of string * 'a prop

let rec pt_check pt axs =
  match pt with
  Ax(p) -> if is_member p axs then ResT(p) else ResF("Niepoprawne zalozenie",p)
  | TopI -> ResT(Bot)
  | ConjI(pt1,pt2) -> let res1 = pt_check pt1 axs and res2 = pt_check pt2 axs in
                      (match (res1,res2) with
                      (ResT(rp1),ResT(rp2)) -> ResT(Conj(rp1,rp2))
                      |(ResF(s,rpt),ResT(rp)) -> ResF(s,rpt)
                      |(_,ResF(s,rpt)) -> ResF(s,rpt))
  | DisjIL(pt,p) -> let res = pt_check pt axs in
                      (match res with
                      ResT(rp) -> ResT(Disj(rp,p))
                      | ResF(s,rpt) -> ResF(s,rpt))
  | DisjIR(p,pt) -> let res = pt_check pt axs in
                      (match res with
                      ResT(rp) -> ResT(Disj(p,rp))
                      | ResF(s,rpt) -> ResF(s,rpt))
  | ImplI(hpt) -> let (p,pt) = hpt in let res = pt_check pt (p::axs) in
                      (match res with
                      ResT(rp) -> ResT(Impl(p,rp))
                      | ResF(s,rpt) -> ResF(s,rpt))
  | BotE(p) -> ResT(p)
  | ConjEL(pt) -> let res = pt_check pt axs in
                  (match res with
                  ResT(rp) -> (match rp with
                              Conj(p,q) -> ResT(p)
                              | _ -> ResF("Niepoprawne formuly w ConjEL",rp))
                  | ResF(s,rpt) -> ResF(s,rpt))
  | ConjER(pt) -> let res = pt_check pt axs in
                  (match res with
                  ResT(rp) -> (match rp with
                              Conj(p,q) -> ResT(q)
                              | _ -> ResF("Niepoprawne formuly w ConjER",rp))
                  | ResF(s,rpt) -> ResF(s,rpt))
  | DisjE(pt,hpt1,hpt2) -> let res1 = pt_check pt axs in
                        (match res1,hpt1,hpt2 with
                        (ResT(Disj(p,q)),(p2,pt1),(q2,pt2)) when p = p2 && q = q2 -> let res1 = pt_check pt1 (p::axs) and res2 = pt_check pt2 (q::axs) in
                                                        (match res1,res2 with
                                                        (ResT(rp1),ResT(rp2)) when rp1 = rp2 -> ResT(rp1)
                                                        | (ResF(s,rpt1),_) -> ResF(s,rpt1)
                                                        | (_,ResF(s,rpt1)) -> ResF(s,rpt1)) 
                        | (ResF(s,rpt),_,__) -> ResF(s,rpt)
                        | (ResT(p),_,__) -> ResF("Niepoprawne formuly w DisjE",p))
  | ImplE(pt1,pt2) -> let res1 = pt_check pt1 axs and res2 = pt_check pt2 axs in
                      (match res1,res2 with
                      (ResT(rp1),ResT(Impl(rp3,rp2))) when rp1 = rp3 -> ResT(rp2)
                      | (ResF(s,rpt),_) -> ResF(s,rpt)
                      | (_,ResF(s,rpt)) -> ResF(s,rpt)
                      | _,ResT(p) -> ResF("Niepoprawne formuly w ImplE",p));;

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

type 'a thing = TGoal of string * ('a prop) * ('a pt)
| SGoal of string * ('a prop) * ('a ps)

let rec print_form f =
  match f with
  Top -> print_string "T"
  |Bot -> print_string "F"
  |Var(c) -> print_string c
  |Conj(f1,f2) -> print_string "("; print_form f1; print_string " ^ "; print_form f2; print_string ")"
  |Disj(f1,f2) -> print_string "("; print_form f1; print_string " v "; print_form f2; print_string ")"
  |Impl(f1,f2) -> print_string "("; print_form f1; print_string " => "; print_form f2; print_string ")"

let rec print_check (str,prop,pt) =
  let res = pt_check pt [] in
  print_string str; print_newline ();
  match res,prop with
  (ResT(rp),p) when rp = p -> print_string "Dowod poprawny" ; print_newline (); print_form p
  | (ResT(rp),p) -> print_string "Dowod niepoprawny, dowiedziono inna formule" ; print_newline (); print_form p; print_newline (); print_form rp
  | (ResF(s,p),_) -> print_string "Dowod niepoprawny, blad w dowodzie"; print_newline (); print_string s; print_newline (); print_form p;; 

let print_check_s (s,prop,ps) =
  let res = ps_check ps [] in
  print_string s; print_newline();
  match res,prop with
  (ResTs(rp),p) when rp = p -> print_string "Dowod poprawny" ; print_newline (); print_form p
  | (ResTs(rp),p) -> print_string "Dowod niepoprawny, dowiedziono inna formule" ; print_newline (); print_form p; print_newline (); print_form rp
  | (ResFs,_) -> print_string "Dowod niepoprawny, blad w dowodzie";;

let main proofs =
  List.map (fun p -> (match p with
                     TGoal(s,pt,p1) -> print_check (s,pt,p1); print_newline (); print_newline ()
                     | SGoal(s,ps,p1) -> print_check_s (s,ps,p1); print_newline (); print_newline ())
                     ) proofs;;



(**)

let test = ImplI(
  Conj(Var("A"),Impl(Var("A"),Var("B"))),
  ImplE(
    ConjEL(
      Ax(Conj(Var("A"),Impl(Var("A"),Var("B"))))),
    ConjER(
      Ax(Conj(Var("A"),Impl(Var("A"),Var("B")))))
    )
  );;

let test3 = ImplI(
  Conj(Var("P"),Var("Q")),
  ConjEL(Ax(Conj(Var("P"),Var("Q"))))
);;

let test4 = ImplI(
  Var("P"),
  ImplI(
    Var("Q"),
    Ax(Var("P"))
  )
);;

let test5 = ImplI(
  Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ),
  DisjE(
    ConjER(Ax(Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ))),
    (
      Var("P"),
      ImplE(
        Ax(Var("P")),
        ConjEL(ConjEL(Ax(Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ))))
      )
    ),
    (
      Var("Q"),
      ImplE(
        Ax(Var("Q")),
        ConjER(ConjEL(Ax(Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ))))
      )
    )
  )
);;

let test6 = ImplI(
  Impl(Disj(Var("P"),Var("Q")),Var("R")),
  ImplI(
    Var("Q"),
    ImplE(
      DisjIR(
        Var("P"),
        Ax(Var("Q"))
      ),
      Ax(Impl(Disj(Var("P"),Var("Q")),Var("R")))
    )
  )
);;

let ResT(res1) = pt_check test [];;
let ResT(res2) = pt_check test3 [];;
let ResT(res3) = pt_check test4 [];;
let ResT(res4) = pt_check test5 [];;
let ResT(res5) = pt_check test6 [];;
(*
print_form res1;;
print_string("\n");;
print_form res2;;
print_string("\n");;
print_form res3;;
print_string("\n");;
print_form res4;;
print_string("\n");;
print_form res5;;
*)
(*Przykłady błędów*)

let test2 = ImplI(
  Conj(Var("A"),Impl(Var("A"),Var("B"))),
  ImplE(
    ConjEL(
      Ax(Conj(Var("A"),Impl(Var("B"),Var("A"))))),
    ConjER(
      Ax(Conj(Var("A"),Impl(Var("A"),Var("B")))))
    )
  );;

let test7 = ImplI(
  Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ),
  DisjE(
    ConjER(Ax(Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ))),
    (
      Var("P"),
      ImplE(
        Ax(Var("P")),
        ConjEL(ConjEL(Ax(Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ))))
      )
    ),
    (
      Var("Q"),
      ImplE(
        Ax(Var("Q")),
        ConjEL(ConjEL(Ax(Conj( Conj(Impl(Var("P"),Var("R")),Impl(Var("Q"),Var("R"))), Disj(Var("P"),Var("Q")) ))))
      )
    )
  )
);;

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


let proofs = [TGoal("naza1T",(Impl (Conj (Var "A", Impl (Var "A", Var "B")), Var "B")),test);
              TGoal("nazwa2T",(Impl (Conj (Var "P", Var "Q"), Var "P")),test3);
              TGoal("nazwa3T",(Impl (Var "P", Impl (Var "Q", Var "P"))),test4);
              TGoal("nazwa4T",(Impl
              (Conj (Conj (Impl (Var "P", Var "R"), Impl (Var "Q", Var "R")),
                Disj (Var "P", Var "Q")),
              Var "R")),test5);
              TGoal("nazwa5T",(Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))),test6);
              TGoal("nazwa6F",(Impl
              (Conj (Conj (Impl (Var "P", Var "R"), Impl (Var "Q", Var "R")),
                Disj (Var "P", Var "Q")),
              Var "R")),test7);
              TGoal("nazwa7F",(Impl (Conj (Var "A", Impl (Var "A", Var "B")), Var "B")),test2);
              TGoal("nazwa8F",(Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "R", Var "Q"))),test6);
              SGoal("naza11T",(Impl (Conj (Var "A", Impl (Var "A", Var "B")), Var "B")),test11);
              SGoal("naza12F",(Impl (Conj (Var "A", Impl (Var "A", Var "B")), Var "B")),test12);
              SGoal("nazwa13T",Impl(Conj(Var("P"),Var("Q")),Disj(Var("P"),Var("Q"))),test13);
              SGoal("nazwa14F",Impl(Conj(Var("P"),Var("Q")),Disj(Var("P"),Var("Q"))),test14);
              SGoal("nazwa15T",(Impl (Var "P", Impl (Var "Q", Var "P"))),test15);
              SGoal("nazwa16F",(Impl (Var "P", Impl (Var "Q", Var "P"))),test16);
              SGoal("nazwa17T",(Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))),test17);
              SGoal("nazwa18F",(Impl (Impl (Disj (Var "P", Var "Q"), Var "R"), Impl (Var "Q", Var "R"))),test18)];;

main proofs;;



