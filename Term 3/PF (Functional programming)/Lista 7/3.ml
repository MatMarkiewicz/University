type 'a cache = 'a list

let empty_cache = [];;

let find_in_cache cache x = 
  List.assoc x !cache

let add_to_cache cache x y = 
  cache := (x,y):: !cache; ();;

let rec fib n = if n < 2 then n else (fib (n-1)) + (fib (n-2));;

let memo f =
  let cache = ref empty_cache in
  function x -> 
    try 
      find_in_cache cache x
    with 
      Not_found -> let y = f x in add_to_cache cache x y; y;;

let memo_fib0 = memo fib;;
  
let memo_fib = 
  let cache = ref [] in
    let rec iter n =
      try 
        List.assoc n !cache 
      with 
        Not_found -> let y = if n < 2 then n else (iter (n-1)) + (iter (n-2)) 
          in cache := (n,y) :: !cache;
          y
    in iter;;

fib 37;; (* wynik po sekundzie *)
memo_fib0 37;; (* wynik po sekundzie *)
memo_fib0 37;; (* wynik natychmiastowy *)
memo_fib 37;; (* wynik prawie natychmiastowy, pomimo obliczania go pierwszy raz *)
memo_fib 37;; (*wynik natychmiastowy*)
