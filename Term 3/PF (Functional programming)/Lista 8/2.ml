module type VERTEX =
sig
  type t
  type label
  val equal : t -> t -> bool
  val create : label -> t
  val label : t -> label
end

module type EDGE= 
sig
  type t
  type vertex
  type label
  val equal : t -> t -> bool
  val create : vertex -> vertex -> label -> t
  val first_vertex : t -> vertex
  val last_vertex : t -> vertex
end

module Ver : VERTEX with type label = string =
struct
  type t = Ver of label
  and label = string

  let equal v1 v2 =
    match v1,v2 with
    Ver(s1),Ver(s2) -> s1=s2
  
  let create l =
    Ver(l);;

  let label v =
    let Ver(s) = v in s;;

end

module Ed : EDGE with type label = string = 
struct
  type vertex = Ver.t
  type t = Edge of vertex * vertex * string
  type label = string
  let equal e1 e2 =
    match e1, e2 with
      Edge(v00, v01, s1), Edge(v10, v11, s2) -> v00 = v10 && v01 = v11 && s1=s2;;

  let first_vertex edge =
    match edge with
      Edge(v0, v1, s) -> v0;;

  let last_vertex edge =
    match edge with
      Edge(v0, v1, s) -> v1;;

  let create v1 v2 s =
    Edge(v1,v2, s);;

end

module type GRAPH =
sig
    
  (* typ reprezentacji grafu *)
  type t
  module V : VERTEX
  type vertex = V.t
  module E : EDGE with type vertex = vertex
  type edge = E.t

  (* funkcje wyszukiwania *)
  val mem_v : t -> vertex -> bool
  val mem_e : t -> edge -> bool
  val mem_e_v : t -> vertex -> vertex -> bool
  val find_e : t -> vertex -> vertex -> edge
  val succ : t -> vertex -> vertex list
  val pred : t -> vertex -> vertex list
  val succ_e : t -> vertex -> edge list
  val pred_e : t -> vertex -> edge list

  (* funkcje modyfikacji *)
  val empty : t
  val add_e : t -> edge -> t
  val add_v : t -> vertex -> t
  val rem_e : t -> edge -> t
  val rem_v : t -> vertex -> t

  (* iteratory 
  val fold_v : ( vertex -> 'a -> 'a) -> t -> 'a -> 'a
  val fold_e : ( edge -> 'a -> 'a) -> t -> 'a -> 'a
  *)
end

module Graph : GRAPH =
struct
  module V = Ver
  type vertex = V.t
  module E = Ed
  type edge = E.t
  type t = Graph of vertex list * edge list

  let rec member_v x xs =
    match xs with
    [] -> false
    |h::t -> V.equal h x || (member_v x t);;

  let rec member_e x xs =
    match xs with
    [] -> false
    |h::t -> E.equal h x || (member_e x t);;
  
  let mem_v g v =
    let Graph(vs,es) = g in member_v v vs;;

  let mem_e g e =
    let Graph(vs,es) = g in member_e e es;;

  let mem_e_v g v1 v2 =
    let rec iter l =
      match l with
      [] -> false
      |h::t -> ((E.first_vertex h)=v1 && (E.last_vertex h)=v2) || iter t in
    let Graph(vs,es) = g in iter es;;

  let find_e g v1 v2 =
    let rec iter l =
      match l with
      [] -> (E.create v1 v2 "err")
      |h::t -> if ((E.first_vertex h)=v1 && (E.last_vertex h)=v2) then h else iter t in
    let Graph(vs,es) = g in iter es;;

  let succ g v =
    let rec iter l =
      match l with
      [] -> []
      |h::t when V.equal h v -> t
      |h::t -> iter t 
    in let Graph(vs,es) = g in iter vs;;

  let pred g v =
    let rec iter l acc =
      match l with
      [] -> acc
      |h::t when V.equal h v -> acc
      |h::t -> iter t (h::acc)
    in let Graph(vs,es) = g in iter vs [];;

  let succ_e g e =
    let rec iter l =
      match l with
      [] -> []
      |h::t when E.equal h e -> t
      |h::t -> iter t 
    in let Graph(vs,es) = g in iter es;;

  let pred_e g e =
    let rec iter l acc =
      match l with
      [] -> acc
      |h::t when E.equal h e -> acc
      |h::t -> iter t (h::acc)
    in let Graph(vs,es) = g in iter es [];;

  let empty = Graph([],[])

  let add_e g e =
    let Graph(vs,es) = g in Graph(vs,(e::es));;

  let add_v g v =
    let Graph(vs,es) = g in Graph((v::vs),es);;

  let rem_e g e =
    let rec iter l =
      match l with
      [] -> []
      |h::t when E.equal e h -> iter t 
      |h::t -> h::(iter t) 
    in let Graph(vs,es) = g in Graph(vs,(iter es));;

  let rem_v g v =
    let rec iter l =
      match l with
      [] -> []
      |h::t when V.equal v h -> iter t 
      |h::t -> h::(iter t) 
    in let Graph(vs,es) = g in Graph((iter vs),es);;

  end
