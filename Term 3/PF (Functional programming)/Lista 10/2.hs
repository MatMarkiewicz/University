data BTree a = Leaf | Node ( BTree a ) a ( BTree a ) deriving (Show)
data Array a = Array (BTree a) Integer deriving (Show)

aempty :: Array a 
aempty = Array Leaf 0

asub_h :: BTree a -> Integer -> a
asub_h (Node t1 a t2) 1 = a
asub_h (Node t1 a t2) i = if i `mod` 2 == 0 then asub_h t1 (i `div` 2) else asub_h t2 (i `div` 2)

asub :: Array a -> Integer -> a
asub (Array t n) = asub_h t

aupdate_h :: BTree a -> Integer -> a -> BTree a
aupdate_h (Node t1 b t2) 1 a = Node t1 a t2
aupdate_h (Node t1 b t2) i a = if i `mod` 2 == 0 then Node (aupdate_h t1 (i `div` 2) a) b t2 else Node t1 b (aupdate_h t2 (i `div` 2) a)

aupdate :: Array a -> Integer -> a -> Array a
aupdate (Array t n) i a = Array (aupdate_h t i a) n

ahiext_h :: BTree a -> Integer -> a -> BTree a
ahiext_h t 1 a = Node Leaf a Leaf
ahiext_h (Node t1 b t2) i a = if i `mod` 2 == 0 then Node (ahiext_h t1 (i `div` 2) a) b t2 else Node t1 b (ahiext_h t2 (i `div` 2) a)

ahiext :: Array a -> a -> Array a
ahiext (Array t n) a = Array (ahiext_h t (n+1) a) (n+1)

ahierm_h :: BTree a -> Integer -> BTree a
ahierm_h (Node t1 a t2) 1 = Leaf
ahierm_h (Node t1 a t2) i = if i `mod` 2 == 0 then Node (ahierm_h t1 (i `div` 2)) a t2 else Node t1 a (ahierm_h t2 (i `div` 2))

ahirem :: Array a -> Array a
ahirem (Array t n) = Array (ahierm_h t n) (n-1)

--let t2 = Array (Node Leaf 1 Leaf) 1
--let t3 = ahiext t2 2
--let t4 = ahiext t3 3
--let t5 = ahiext t4 4
--let t6 = aupdate t5 3 6
--asub t6 1
--asub t6 2
--asub t6 3
--asub t6 4