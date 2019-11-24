iter :: [a] -> [a] -> [b] -> [b] -> [(a,b)]
iter [] hx [] hy = (iter2 hx hy)
iter (h:t) hx [] hy = (zip ((tail hx) ++ [h]) (reverse hy)) ++ (iter t ((tail hx) ++ [h]) [] hy)
iter [] hx (h:t) hy = (zip hx (reverse ((tail hy) ++ [h]))) ++ (iter [] hx t ((tail hy) ++ [h]))
iter (h0:t0) hx (h:t) hy = (zip (hx ++ [h0]) (reverse (hy ++ [h]))) ++ (iter t0 (hx ++ [h0]) t (hy ++ [h]))

iter2 :: [a] -> [b] -> [(a,b)]
iter2 [] [] = []
iter2 (h:t) (h2:t2) = (zip t (reverse t2)) ++ (iter2 t t2)

(><) :: [a] -> [b] -> [(a,b)]
(><) xs ys = iter xs [] ys []

--(><) xs ys =  concat [ (zip (take i xs) (reverse (take i ys))) | i <- [1..] ]