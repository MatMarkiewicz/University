type form =  True | False | Var of char | Conj of form * form | Dysj of form * form | Cond of form * form 
type pre = Est of form | PreE of form * rule | PreR of rule
and rule = Rule of pre list * form;;

let rec is_member x xs =
  match xs with
  [] -> false
  |h::t -> x=h || is_member x t;;

let rec remove_duplicates xs ys =
  match xs with
  [] -> ys
  |h::t -> if is_member h ys then remove_duplicates t ys else remove_duplicates t (h::ys)

let rec vars_in_form f = 
  let rec iter f = 
    match f with
    True -> [],[]
    |False -> [],[]
    |Var(c) -> [c],[]
    |Conj(f1,f2) -> let (p1,n1) = iter f1 and (p2,n2) = iter f2 in (p1@p2),(n1@n2)
    |Dysj(f1,f2) -> let (p1,n1) = iter f1 and (p2,n2) = iter f2 in (p1@p2),(n1@n2)
    |Cond(f1,f2) -> let (p1,n1) = iter f1 and (p2,n2) = iter f2 in (n1@p2),(p1@n2)
  in let p,n = iter f in (remove_duplicates p []),(remove_duplicates n []);;

let testform = Cond( Conj( Var('p'), Cond( Var('p'), Var('q') ) ), Var('q') )

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_char h ; print_string " " ; print_list t;;

let pos,neg = vars_in_form testform;;
print_list pos;;
print_string("\n");;
print_list neg;;
print_string("\n");;
print_string("\n");;

let rec vars_in_rule rule = 
  let vars_in_pre p =
    match p with
    Est(f) -> vars_in_form f
    |PreR(r) -> vars_in_rule r
    |PreE(f,r) -> let p1,n1 = vars_in_form f and p2,n2 = vars_in_rule r in (n1@p2),(p1@n2) in
  let Rule(ps,f) = rule in
  let vars = List.map (fun p -> vars_in_pre p) ps in
  let p1 = List.flatten (List.map (fun (x,y) -> x) vars) and n1 = List.flatten (List.map (fun (x,y) -> y) vars)
  and p2,n2 = vars_in_form f in (remove_duplicates (p1@p2) []),(remove_duplicates (n1@n2) []);;


let testrule = Rule(
  [
    PreE(
      Conj( Var('p'), Cond( Var('p'), Var('q') ) ),
      Rule(
        [
          PreR(
            Rule(
              [
                Est(Conj( Var('p'), Cond( Var('p'), Var('q') ) ))
              ],
              Var('p')
            )
          );
          PreR(
            Rule(
              [
                Est(Conj( Var('p'), Cond( Var('p'), Var('q') ) ))
              ],
              Cond( Var('p'), Var('q'))
            )
          )
        ],
        Var('q')
      )
    )
  ],
  Cond( Conj( Var('p'), Cond( Var('p'), Var('q') ) ), Var('q') )
);;


let pos,neg = vars_in_rule testrule;;
print_list pos;;
print_string("\n");;
print_list neg;;