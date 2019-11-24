let test_stream_1 = (fun x -> x);;
let test_stream_2 = (fun x -> x + 2);;
let test_stream_3 = (fun x -> x * 2);;

(*a*)
let hd = (fun s -> (s 0));;
let tl = (fun s -> (fun x -> (s (x+1))));;

print_string "Test hd i tl (strumien liczb naturalnych) \n";;
print_int(hd test_stream_1);;
print_string "\n";;
print_int((tl test_stream_1) 0);;
print_string "\n";;
print_int((tl test_stream_1) 1);;
print_string "\n";;
print_string "\n";;

(*b*)

let add = (fun s v -> (fun x -> ((s x)+ v));;

print_string "Test add (dodanie 5 do liczb naturalnych)\n";;
let test_stream_12 = (add test_stream_1 5);;
print_int(test_stream_12 0);;
print_string "\n";;
print_int(test_stream_12 1);;
print_string "\n";;
print_int(test_stream_12 2);;
print_string "\n";;
print_string "\n";;

(*c*)

let map = (fun s f -> (fun x -> (f (s x))));;

print_string "Test map (strumien liczb naturalnych, funkcja x^2)\n";;
let f x = x * x;;
let test_stream_13 = (map test_stream_1 f);;
print_int(test_stream_13 0);;
print_string "\n";;
print_int(test_stream_13 1);;
print_string "\n";;
print_int(test_stream_13 2);;
print_string "\n";;
print_string "\n";;

(*d*)

let map2 = (fun s1 s2 f -> (fun x -> (f (s1 x) (s2 x))));;

print_string "Test map2 (funkcja x * y, strumien liczb naturalnych i liczb naturalnych *2 )\n";;
let g x y = x * y;;
let test_stream_14 = (map2 test_stream_1 test_stream_3 g);;
print_int(test_stream_14 0);;
print_string "\n";;
print_int(test_stream_14 1);;
print_string "\n";;
print_int(test_stream_14 2);;
print_string "\n";;
print_string "\n";;

(*e*)

let replace = (fun s n a -> (fun x -> (if x mod n == 0 then a else (s x))));;

print_string "Test replace (strumien liczb naturalnych, n = 2, a = 42 )\n";;
let test_stream_15 = (replace test_stream_1 2 42);;
print_int(test_stream_15 0);;
print_string "\n";;
print_int(test_stream_15 1);;
print_string "\n";;
print_int(test_stream_15 2);;
print_string "\n";;
print_string "\n";;

(*f*)

let take = (fun s n -> (fun x -> (s (n * x))));;

print_string "Test take (strumien liczb naturalnych, n = 5)\n";;
let test_stream_16 = (take test_stream_1 5);;
print_int(test_stream_16 0);;
print_string "\n";;
print_int(test_stream_16 1);;
print_string "\n";;
print_int(test_stream_16 2);;
print_string "\n";;
print_string "\n";;

(*g*)

let rec scan_helper f a s n = (if n == 0 then (f a (s n)) else (f (scan_helper f a s (n-1)) (s n)));;

let scan = (fun s f a -> (fun x -> (scan_helper f a s x)));;

print_string "Test scan (strumien liczb naturalnych, a = 2, f = a + b)\n";;
let h a b = a + b
let test_stream_17 = (scan test_stream_1 h 2);;
print_int(test_stream_17 0);;
print_string "\n";;
print_int(test_stream_17 1);;
print_string "\n";;
print_int(test_stream_17 2);;
print_string "\n";;
print_string "\n";;

(*h*)

let rec tabulate s ?(a=0) b = (if a = b then [(s a)] else ((s a) :: (tabulate s ~a:(a+1) b)));;

print_string "Test tabulate (strumien liczb naturalnych od 0)\n";;
let test_stream_18 = (tabulate test_stream_1 10);;
print_int(List.hd test_stream_18);;
print_string "\n";;
print_int(List.hd (List.tl test_stream_18));;
print_string "\n";;
print_int(List.hd (List.tl (List.tl test_stream_18)));;
print_string "\n";;
print_string "Test tabulate (strumien liczb naturalnych od 2)\n";;
let test_stream_19 = (tabulate test_stream_1 ~a:2 10);;
print_int(List.hd test_stream_19);;
print_string "\n";;
print_int(List.hd (List.tl test_stream_19));;
print_string "\n";;
print_int(List.hd (List.tl (List.tl test_stream_19)));;
print_string "\n";;
print_string "\n";;