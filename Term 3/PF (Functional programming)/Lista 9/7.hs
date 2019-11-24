data Tree a = Node (Tree a) a (Tree a) | Leaf
data Set a = Fin (Tree a) | Cofin (Tree a)

insert :: Ord a => a -> Tree a -> Tree a
insert a Leaf = Node Leaf a Leaf
insert a t = let Node t1 b t2 = t in if a > b then Node t1 b (insert a t2) else Node (insert a t1) b t2

iter :: Ord a => [a] -> Tree a -> Tree a
iter [] t = t
iter (h:tail) t = iter tail (insert h t)

setFromList :: Ord a => [a] -> Set a
setFromList xs = Fin (iter xs Leaf)

setEmpty :: Ord a => Set a
setEmpty = Fin(Leaf)

setFull :: Ord a => Set a
setFull = Cofin(Leaf)

treeMember :: Ord a => a -> Tree a -> Bool
treeMember a Leaf = False
treeMember a (Node t1 b t2) = if a == b then True else (if a > b then treeMember a t2 else treeMember a t1)

setMember :: Ord a => a -> Set a -> Bool
setMember a (Cofin t) = not (treeMember a t)
setMember a (Fin t) = treeMember a t

setComplement :: Ord a => Set a -> Set a
setComplement (Fin t) = Cofin t
setComplement (Cofin t) = Fin t

setIntersection :: Ord a => Set a -> Set a -> Set a
setIntersection (Fin t1) (Fin t2) = 
setIntersection (Fin t1) (Cofin t2) = 
setIntersection (Cofin t1) (Fin t2) = 
setIntersection (Cofin t1) (Cofin t2) = 
--setUnion, setIntersection :: Ord a => Set a -> Set a -> Set a

