
let horner_rec l x =
  let rec horner_helper xs acc = 
    match xs with
    [] -> 0.
    | h::[] -> acc +. h
    | h::t -> horner_helper t (x *. (acc +. h)) in
  horner_helper l 0.;;

let rec last xs =
  match xs with
  h::[] -> h
  |h::t -> last t;;

let horner_fold l x = 
  (if x = 0. then last l
  else (List.fold_left (fun acc h -> (x *. (acc +. h))) 0. l) /. x);;

print_string("Test schematu Honrenra z rekursją ogonową (funkcja x^3 - x + 2 w punktach 2,0,10) \n");;
print_float(horner_rec [1.;0.;-1.;2.] 2.);;
print_string("\n");;
print_float(horner_rec [1.;0.;-1.;2.] 0.);;
print_string("\n");;
print_float(horner_rec [1.;0.;-1.;2.] 10.);;
print_string("\n");;
print_string("Test schematu Honrenra z funkcją wbudowaną (funkcja x^3 - x + 2 w punktach 2,0,10) \n");;
print_float(horner_fold [1.;0.;-1.;2.] 2.);;
print_string("\n");;
print_float(horner_fold [1.;0.;-1.;2.] 0.);;
print_string("\n");;
print_float(horner_fold [1.;0.;-1.;2.] 10.);;
print_string("\n");;