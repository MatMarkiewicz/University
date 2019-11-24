let horner_rec l x =
  let rec horner_helper xs = 
    match xs with
    [] -> 0.
    | h::[] -> h *. x
    | h::t -> (h +. horner_helper t) *. x in
  if x = 0. then List.hd l else (horner_helper l) /. x ;;

let horner_fold l x = 
  (if x = 0. then List.hd l
  else (List.fold_right (fun acc h -> (x *. (acc +. h))) l 0.) /. x);;

print_string("Test schematu Honrenra z rekursją ogonową (funkcja 2x^3 - x^2 + 1 w punktach 2,0,10) \n");;
print_float(horner_rec [1.;0.;-1.;2.] 2.);;
print_string("\n");;
print_float(horner_rec [1.;0.;-1.;2.] 0.);;
print_string("\n");;
print_float(horner_rec [1.;0.;-1.;2.] 10.);;
print_string("\n");;
print_string("Test schematu Honrenra z funkcją wbudowaną (funkcja 2x^3 - x^2 + 1 w punktach 2,0,10) \n");;
print_float(horner_fold [1.;0.;-1.;2.] 2.);;
print_string("\n");;
print_float(horner_fold [1.;0.;-1.;2.] 0.);;
print_string("\n");;
print_float(horner_fold [1.;0.;-1.;2.] 10.);;
print_string("\n");;