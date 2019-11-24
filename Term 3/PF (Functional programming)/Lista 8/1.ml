module type PQUEUE =
sig
  type priority
  type 'a t

  exception EmptyPQueue

  val empty : 'a t
  val insert : 'a t -> priority -> 'a -> 'a t
  val remove : 'a t -> priority * 'a * 'a t
end

module PQueue : PQUEUE with type priority = int = 
struct
  type priority = int
  type 'a t = Empty | PQue of priority * 'a * 'a t

  exception EmptyPQueue

  let empty = Empty;;

  let rec insert pque p a = 
    match pque with
    Empty -> PQue(p,a,pque)
    | PQue(p1,a1,pq) when p > p1 -> PQue(p, a, pque )
    | PQue(p1,a1,pq) -> PQue( p1, a1, (insert pq p a) );;

  let remove pque =
    match pque with
    Empty -> raise EmptyPQueue
    | PQue(p,a,pq) -> (p,a,pq);; 
end

let pque_to_list pq =
  let rec iter pq l =
    try let p,a,rpq = PQueue.remove pq in (iter rpq (a::l))
    with PQueue.EmptyPQueue -> l
  in iter pq [];;

let pq_sort l =
  let rec list_to_pq l pq = 
    match l with
    [] -> pq
    | h::t -> list_to_pq t (PQueue.insert pq h h) in
  pque_to_list (list_to_pq l PQueue.empty );;


pq_sort [3;7;9;4;2;6;3;6;8];;
pq_sort [];;
pq_sort [9;8;7;6;5;4;3;2;1;0];;
pq_sort [1;2;3;4;5;6;7;8;9];;

module type ORDTYPE =
sig
  type t
  type comparison = LT | EQ | GT
  val compare : t -> t -> comparison
end

module PQueue2 (OrdType: ORDTYPE) : PQUEUE with type priority = OrdType.t = 
struct 
  type priority = OrdType.t
  type 'a t = Empty | PQue of priority * 'a * 'a t

  exception EmptyPQueue

  let empty = Empty;;

  let rec insert pque p a = 
    match pque with
    Empty -> PQue(p,a,pque)
    | PQue(p1,a1,pq) -> match OrdType.compare p p1 with
                        GT -> PQue(p, a, pque )
                        |EQ -> PQue(p, a, pque )
                        |LT -> PQue( p1, a1, (insert pq p a) );;

  let remove pque =
    match pque with
    Empty -> raise EmptyPQueue
    | PQue(p,a,pq) -> (p,a,pq);; 

end;;

module IntOrd : ORDTYPE with type t = int =
struct
  type t = int 
  type comparison = LT | EQ | GT
  let compare x y = 
    if x>y then GT else if x=y then EQ else LT;;
end

module PQueue_int = PQueue2 (IntOrd);;
(*(module PQueue_int = (PQueue_int_h : PQUEUE with type priority = int);;)*)

let pque2_to_list pq =
  let rec iter pq l =
    try let p,a,rpq = PQueue_int.remove pq in (iter rpq (a::l))
    with PQueue_int.EmptyPQueue -> l
  in iter pq [];;

let pq_sort2 l =
  let rec list_to_pq l pq = 
    match l with
    [] -> pq
    | h::t -> list_to_pq t (PQueue_int.insert pq h h) in
  pque2_to_list (list_to_pq l PQueue_int.empty );;


pq_sort2 [3;7;9;4;2;6;3;6;8];;
pq_sort2 [];;
pq_sort2 [9;8;7;6;5;4;3;2;1;0];;
pq_sort2 [1;2;3;4;5;6;7;8;9];;

let sort (type a) (module M : ORDTYPE with type t = a) (l : a list) = 5;;
