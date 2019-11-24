let compose f g = (fun x -> f(g(x)));;
let rec iter f n = (if n > 0 then (compose f (iter f (n - 1))) else (fun x -> x));;

let add x y = ((iter (fun z -> z + 1) x) y);;
let mult x y = ((iter (fun z -> z + x) y) 0);;
let exp x y = ((iter (fun z -> z * x) y) 1);;

print_string "Test add (9 + 10)\n";;
print_int(add 9 10);;
print_string "\n";;
print_string "\n";;

print_string "Test mult (9 * 10)\n";;
print_int(mult 9 10);;
print_string "\n";;
print_string "\n";;

print_string "Test exp (2 ^ 4)\n";;
print_int(exp 2 4);;
print_string "\n";;
print_string "\n";;

