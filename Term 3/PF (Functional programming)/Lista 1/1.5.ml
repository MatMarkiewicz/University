
(*ctrue to dwuargumentowa funkcja zwracająca większy, a cfalse mniejszy argument*)
let ctrue x y = (if x > y then x else y);;
let cfalse x y = (if x < y then x else y);;

let cand c1 c2 = (fun x y -> (let max = (if x>y then x else y) and min = (if x>y then y else x) in (if (c1 x y) == max && (c2 x y) == max then max else min)));;
let cor c1 c2 = (fun x y -> (let max = (if x>y then x else y) and min = (if x>y then y else x) in (if (c1 x y) == max || (c2 x y) == max then max else min)));;

print_string "Test cand ( (true, true), (true, false), (false, true), (false, false))\n";;
print_string "Wynikowa funkcje aplikujemy do liczb 0 1, zwrocenie 0 oznacza false, 1 oznacza true\n";;
let x = 0;;
let y = 1;;
let test_and1 = (cand ctrue ctrue);;
print_int(test_and1 x y);;
print_string "\n";;
let test_and2 = (cand ctrue cfalse);;
print_int(test_and2 x y);;
print_string "\n";;
let test_and3 = (cand cfalse ctrue);;
print_int(test_and3 x y);;
print_string "\n";;
let test_and4 = (cand cfalse cfalse);;
print_int(test_and4 x y);;
print_string "\n";;
print_string "Test cor ( (true, true), (true, false), (false, true), (false, false))\n";;
print_string "Wynikowa funkcje aplikujemy do liczb 0 1, zwrocenie 0 oznacza false, 1 oznacza true\n";;
let x = 0;;
let y = 1;;
let test_or1 = (cor ctrue ctrue);;
print_int(test_or1 x y);;
print_string "\n";;
let test_or2 = (cor ctrue cfalse);;
print_int(test_or2 x y);;
print_string "\n";;
let test_or3 = (cor cfalse ctrue);;
print_int(test_or3 x y);;
print_string "\n";;
let test_or4 = (cor cfalse cfalse);;
print_int(test_or4 x y);;
print_string "\n";;
print_string "\n";;

let cbool_of_bool b = (let s = (if b then (fun x y -> x > y) else (fun x y -> x < y)) in (fun x y -> (if (s x y) then x else y)));;

print_string "Test cbool of bool (true -> ctrue i false -> cfalse)\n";;
print_int((cbool_of_bool true) x y);;
print_string "\n";;
print_int((cbool_of_bool false) x y);;
print_string "\n";;
print_string "\n";;

let bool_of_cbool = (fun cb -> (if (cb true false) == true then true else false));;

print_string "Test bool of cbool (ctrue -> true i cfalse -> false)\n";;
let bool2int b = (if b then 1 else 0);;
print_int(bool2int(bool_of_cbool ctrue));;
print_string "\n";;
print_int(bool2int(bool_of_cbool cfalse));;
print_string "\n";;
print_string "\n";;