(*Zakładając, że f x -> f^n(x) to n`te złożenie:*)

let compose f g = fun x -> f(g(x));;
let rec iter f n = if n > 0 then compose f (iter f (n - 1)) else (fun x -> x);;
let inc = (fun x -> x + 1);;
let ctrue x y = (if x > y then x else y);;
let cfalse x y = (if x < y then x else y);;
let bool_of_cbool cb = (if (cb true false) == true then true else false);;

let zero f x = (if (f x) != x then x else x);;

let succ cn = (fun f x -> f(cn f x));;

let add cn1 cn2 = (fun f x -> (cn1 f (cn2 f x)));;

let mul cn1 cn2 = (fun f x -> (cn1 (cn2 f) x));;

let is_zero = (fun cn -> (if (cn inc 1) == 1 then ctrue else cfalse));;

let cnum_of_int n = (fun f x -> ((iter f n)x));;
(*let rec int_of_cnum_helper cn f x n = (if (bool_of_cbool(is_zero cn)) then 0 else (if (cn f x) == ((iter f n)x) then n else (int_of_cnum_helper cn f x (n+1))));;
let int_of_cnum2 cn = (int_of_cnum_helper cn inc 4 0);;*)
let int_of_cnum cn = (cn inc 0);;


print_string "Test zero i is_zero (jesli cnum jest zerem is_zero zwraca true wypisywane jako 1, testowane zero i cnum z 5)\n";;
let bool2int b = (if b then 1 else 0);;
let cnum5 = (cnum_of_int 5);;
let cnum50 = (cnum_of_int 50);;
print_int(bool2int(bool_of_cbool(is_zero(zero))));;
print_string "\n";;
print_int(bool2int(bool_of_cbool(is_zero(cnum5))));;
print_string "\n";;
print_string "\n";;

print_string "Test cnum of int oraz int of cnum (int -> cnum -> int dla 5 i 50)\n";;
print_int(int_of_cnum(cnum_of_int 5));;
print_string "\n";;
print_int(int_of_cnum(cnum_of_int 50));;
print_string "\n";;
print_string "\n";;

print_string "Test succ (nastepnik cnum5)\n";;
print_int(int_of_cnum(succ cnum5));;
print_string "\n";;
print_string "\n";;

print_string "Test add (cnum5 + cnum50)\n";;
print_int(int_of_cnum(add cnum5 cnum50));;
print_string "\n";;
print_string "\n";;

print_string "Test add (cnum5 * cnum50)\n";;
print_int(int_of_cnum(mul cnum5 cnum50));;
print_string "\n";;
print_string "\n";;
