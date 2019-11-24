data Color = Red | Black deriving (Show)
data RBTree a = RBNode Color (RBTree a) a (RBTree a) | RBLeaf deriving (Show)

check :: RBTree a -> (RBTree a,Bool)
check (RBNode Black (RBNode Red (RBNode Red a x b)  y c)  z d) = (RBNode Red (RBNode Black a x b)  y (RBNode Black c z d),True)
check (RBNode Black (RBNode Red a x (RBNode Red b y c))  z d) = (RBNode Red (RBNode Black a x b)  y (RBNode Black c z d),True)
check (RBNode Black a x (RBNode Red b y (RBNode Red c z d))) = (RBNode Red (RBNode Black a x b)  y (RBNode Black c z d),True)
check (RBNode Black a x (RBNode Red (RBNode Red b y c) z d)) = (RBNode Red (RBNode Black a x b)  y (RBNode Black c z d),True)
check (RBNode c t1 a t2) = let (ct1,b1) = (check t1) in let (ct2,b2) = (check t2) in if b1 || b2 then (check (RBNode c (fst (check t1)) a (fst (check t2)))) else ((RBNode c (fst (check t1)) a (fst (check t2))),False)
check RBLeaf = (RBLeaf,False)

rbnode :: Color -> RBTree a -> a -> RBTree a -> RBTree a
rbnode c t1 a t2 = let (RBNode c2 t3 a2 t4) = (fst (check (RBNode c t1 a t2))) in (RBNode Black t3 a2 t4)

color :: RBTree a -> Color
color RBLeaf = Black
color (RBNode c t1 a t2) = c

value :: RBTree a -> a
value RBLeaf = error "Leaf"
value (RBNode c t1 a t2) = a

left :: RBTree a -> RBTree a 
left RBLeaf = RBLeaf
left (RBNode c t1 a t2) = t1

right :: RBTree a -> RBTree a 
right RBLeaf = RBLeaf
right (RBNode c t1 a t2) = t2

-- (RBNode Black (RBNode Red (RBNode Red RBLeaf "x" RBLeaf) "y" RBLeaf)  "z" RBLeaf)
-- rbnode Black (RBNode Red (RBNode Red RBLeaf "x" RBLeaf) "y" RBLeaf)  "z" RBLeaf

rbinsert_h :: Ord a => a -> RBTree a -> RBTree a
rbinsert_h a RBLeaf = (RBNode Red RBLeaf a RBLeaf)
rbinsert_h a (RBNode c t1 a2 t2) = if a > a2 then (RBNode c t1 a2 (rbinsert_h a t2)) else (RBNode c (rbinsert_h a t1) a2 t2)

rbinsert :: Ord a => a -> RBTree a -> RBTree a
rbinsert a RBLeaf = (RBNode Black RBLeaf a RBLeaf)
rbinsert a (RBNode c t1 a2 t2) = if a > a2 then rbnode c t1 a2 (rbinsert_h a t2) else rbnode c (rbinsert_h a t1) a2 t2

-- let t2 = rbnode Black (RBNode Red (RBNode Red RBLeaf "x" RBLeaf) "y" RBLeaf)  "z" RBLeaf
-- let let t3 = rbinsert "w" t2
-- let t4 = rbinsert "a" t3

-- zadanie 5

halve :: [a] -> Int -> [a] -> ([a],a,[a])
halve (h:t) 0 head = (reverse head,h,t)
halve (h:t) i head = halve t (i-1) (h:head)

rbtreeFromList_h :: [a] -> Int -> RBTree a
rbtreeFromList_h [] i = RBLeaf
rbtreeFromList_h (a:[]) i = RBNode Red RBLeaf a RBLeaf
rbtreeFromList_h l i = let len1 = (i-1) `div` 2 in let (h,a,t) = halve l len1 [] in RBNode Black (rbtreeFromList_h h len1) a (rbtreeFromList_h t (i - len1 - 1))

rbtreeFromList :: [a] -> RBTree a
rbtreeFromList l = let (RBNode c t1 a t2) = rbtreeFromList_h l (length l) in RBNode Black t1 a t2