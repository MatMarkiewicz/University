fun x->x;;
(*- : 'a -> 'a = <fun>*)
fun x -> 0 + x;;
(*- : int -> int = <fun>)
fun f g arg -> f(g(arg));;
(*- : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b = <fun>*)
fun x -> List.hd [];;
fun x -> raise Not_found;;
(*- : 'a -> 'b = <fun>*)

