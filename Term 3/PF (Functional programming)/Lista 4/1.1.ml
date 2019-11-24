
let is_palindrome l = 
  let rec iter xs ys = 
    match xs,ys with
    ([],[]) -> (true,[])
    |(h::t,[]) -> (true,h::t)
    |(h::t,h2::[]) -> (true,t)
    |(h::t,h2::h3::t2) -> let (b,hd::tl) = iter t t2 in (b && h = hd,tl) 
  in let (b,l) = iter l l in b;;
  
let print_bool b =
  if b then print_string "true" else print_string "false";;

print_bool(is_palindrome []);;
print_string("\n");; 
print_bool(is_palindrome [1]);;
print_string("\n");;
print_bool(is_palindrome [1;2;1]);;
print_string("\n");;
print_bool(is_palindrome [1;2;3]);;
print_string("\n");;
print_bool(is_palindrome [1;2;3;4;4;3;2;1]);;
print_string("\n");;
print_bool(is_palindrome [1;2;3;4;5;3;2;1]);;
print_string("\n");;