type form =  True | False | Var of char | Conj of form * form | Dysj of form * form | Cond of form * form;;
type frame = Frame of form * proof
and proof = Form of form | SecF of frame * proof | Sec of form * proof ;; 

let test_rule = SecF( 
  Frame(
    Conj( Var('p'), Cond( Var('p'), Var('q') ) ),
    Sec(
      Var('p'),
      Sec(
        Cond(Var('p'),Var('q')),
        Form(
          Var('q')
        )
      )
    )
  ),
  Form(
    Cond( Conj( Var('p'), Cond( Var('p'), Var('q') ) ), Var('q') )
  )
)

let rec print_form f =
  match f with
  True -> print_string "T"
  |False -> print_string "F"
  |Var(c) -> print_char c
  |Conj(f1,f2) -> print_string "("; print_form f1; print_string " ^ "; print_form f2; print_string ")"
  |Dysj(f1,f2) -> print_string "("; print_form f1; print_string " v "; print_form f2; print_string ")"
  |Cond(f1,f2) -> print_string "("; print_form f1; print_string " => "; print_form f2; print_string ")"

let rec print_rule r =
  match r with
  Form(f) -> print_form f
  |Sec(f,r) -> print_form f; print_string("\n"); print_rule(r)
  |SecF(fr,r) -> let Frame(f1,r1) = fr in print_string("["); print_form f1; print_string(":\n"); 
                                           print_rule r1; print_string("];\n"); print_rule(r); print_string(";\n");;

print_rule test_rule