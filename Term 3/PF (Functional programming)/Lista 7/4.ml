
let fresh_v = 
  let iter = ref 0 in
  function n ->
    if n = 0 then
      function x ->
        iter := 1 + !iter;
        (x ^ (string_of_int !iter))
    else function x -> iter := (int_of_string x); "done";
  ;;

let fresh = fresh_v 0;;
let reset n = 
  let c = (fresh_v 1) (string_of_int n) in ();;

fresh "x";;
fresh "x";;
reset 5;;
fresh "x";;
fresh "x";;