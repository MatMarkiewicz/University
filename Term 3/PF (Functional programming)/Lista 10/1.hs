data BTree a = Leaf | Node ( BTree a ) a ( BTree a ) deriving (Show)

dfnum_h :: BTree a -> Integer -> (BTree Integer,Integer)
dfnum_h Leaf i = (Leaf,i)
dfnum_h (Node t1 a t2) i = let r1 = (dfnum_h t1 (i+1)) in let r2 = (dfnum_h t2 (snd r1)) in ( (Node (fst r1) i (fst r2)), (snd r2) )

dfnum :: BTree a -> BTree Integer
dfnum t = let (rt,_) = dfnum_h t 1 in rt

bfnum_h ::  Integer -> [BTree a]-> [(Integer, BTree a)]
bfnum_h i [] = []
bfnum_h i ((Node Leaf a Leaf):t) = (i,(Node Leaf a Leaf)):(bfnum_h (i+1) t)
bfnum_h i ((Node Leaf a t2):t) = (i,(Node Leaf a t2)):(bfnum_h (i+1) (t++[t2]))
bfnum_h i ((Node t1 a Leaf):t) = (i,(Node t1 a Leaf)):(bfnum_h (i+1) (t++[t1]))
bfnum_h i ((Node t1 a t2):t) = (i,(Node t1 a t2)):(bfnum_h (i+1) (t++(t1:[t2])))

edited_list :: [a] -> [a]
edited_list (h1:h2:t) = h1:t
edited_list l = l

bfnum_h2 :: [(Integer, BTree a)] -> BTree Integer
bfnum_h2 [] = Leaf
bfnum_h2 ((i,(Node Leaf a Leaf)):t) = (Node Leaf i Leaf)
bfnum_h2 ((i,(Node Leaf a t2)):t) = (Node Leaf i (bfnum_h2 t))
bfnum_h2 ((i,(Node t1 a Leaf)):t) = (Node (bfnum_h2 t) i Leaf)
bfnum_h2 ((i,(Node t1 a t2)):t) = (Node (bfnum_h2 (edited_list t)) i (bfnum_h2 (tail t)))

bfnum :: BTree a -> BTree Integer
bfnum t = bfnum_h2 (bfnum_h 1 [t])

-- zwróciło drzewo 3-2-1-3 ???
--let t1 = Node ( Node ( Node Leaf 'a' Leaf ) 'b' Leaf ) 'c' ( Node Leaf 'd' Leaf )
--let t2 = bfnum t1
--let (Node t3 c t4) = t2
--let (Node t5 b t6) = t3
--let (Node t7 d t8) = t4
--let (Node t9 a t10) = t5