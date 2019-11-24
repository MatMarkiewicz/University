
let test_matrix1 = [[1;2];[3;4]];;
let test_matrix2 = [[1;2;3;4];[3;4;5;6];[5;6;7;8];[7;8;9;10]];;
let test_bad_matrix1 = [[1;2;3;4];[3;4;5;6];[5;6;7];[7;8;9;10]];;

(*1*)
let is_correct_matrix xss = 
  List.for_all (fun xs -> List.length xs = List.length xss) xss;;

(*2*)
let nth_column xss n = 
  List.map (fun xs -> List.nth xs n) xss;;

(*3*)
let transposition xss = 
  let len = (List.length xss) in
    let rec transposition_h n =
      match n with
      0 -> []
      |n -> (nth_column xss (len-n))::(transposition_h (n-1)) in
    transposition_h len;;

(*4*)
let zip xs ys = 
  List.map2 (fun x y -> (x,y)) xs ys;;

(*5*)
let zipf f xs ys = 
  List.map (fun (x,y) -> f x y) (zip xs ys);;

(*6*)
(* 1. Transpozycja macierzy, 2. utworzenie par mnożonych elementów i wymnorzenie ich 3. sumowanie wymnożonych elementów *)
let mult_vec v m = 
  List.map (fun xs -> (List.fold_left (fun acc h -> acc +. h) 0. (zipf ( *. ) v xs))) (transposition m);;

(*7*)
let mult_matrix m1 m2 = 
  List.map (fun v -> mult_vec v m2) m1;;

let rec print_list l =
  match l with
  [] -> ()
  | h::t -> print_int h ; print_string " " ; print_list t;;

let rec print_list_of_floats l =
  match l with
  [] -> ()
  | h::t -> print_float h ; print_string " " ; print_list_of_floats t;;

let rec print_list_of_lists l =
  match l with
  [] -> ()
  | h::t -> print_list h ; print_string "\n" ; print_list_of_lists t;;

let rec print_list_of_lists_of_floats l =
  match l with
  [] -> ()
  | h::t -> print_list_of_floats h ; print_string "\n" ; print_list_of_lists_of_floats t;;

print_string("Test funkcji sprawdzajacej poprawnosc macierzy \n");;
if (is_correct_matrix test_matrix2) then print_string("ok, ") else print_string("error, ");;
if (is_correct_matrix test_bad_matrix1) then print_string("error") else print_string("ok");;
print_string("\n");;
print_string("\n");;

print_string("Test nth_column ([[1;2;3;4];[3;4;5;6];[5;6;7;8];[7;8;9;10]], kolumna 0)\n");;
print_list(nth_column test_matrix2 0);;
print_string("\n");;
print_string("\n");;

print_string("Test transpozycji (macierz [[1;2;3;4];[3;4;5;6];[5;6;7;8];[7;8;9;10]]) \n");;
print_list_of_lists(transposition test_matrix2);;
print_string("\n");;
print_string("\n");;

print_string("Test zipf ((+.) [1.;2.;3.] [4.;5.;6.]) \n");;
print_list_of_floats (zipf (+.) [1.;2.;3.] [4.;5.;6.]);;
print_string("\n");;
print_string("\n");;

print_string("Test mult vec ([1.; 2.] * [[2.; 0.]; [4.; 5.]]) \n");;
print_list_of_floats(mult_vec  [1.; 2.] [[2.; 0.]; [4.; 5.]] );;
print_string("\n");;
print_string("\n");;

print_string("Test mult matrix ([[1.; 2.];[3.;1.]] * [[2.; 0.]; [4.; 5.]])\n");;
print_list_of_lists_of_floats(mult_matrix [[1.; 2.];[3.;1.]] [[2.; 0.]; [4.; 5.]]);;