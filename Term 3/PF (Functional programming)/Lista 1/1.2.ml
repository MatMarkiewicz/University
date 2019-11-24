let rec rec1 x = if x > 0 then 2 * (rec1 (x - 1)) + 1 else 0;;
let rec rec2 x acc = if x > 0 then (rec2 (x - 1) (2 * acc + 1)) else acc;;

let x = rec1 5;;
let y = rec2 5 0;;

print_int x;;
print_string "\n";;
print_int y;;

(*rec1 1000000;;*)
(*print_int(rec2 1000000 0);;*)
