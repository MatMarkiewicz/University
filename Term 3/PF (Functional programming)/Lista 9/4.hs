insert :: a -> [a] -> [a] -> [[a]]
insert a xs [] = [(xs ++ [a])]
insert a xs (h:ys) = (xs ++ (a:(h:ys))):(insert a (xs ++ [h]) ys)

iperm :: [a] -> [[a]]
iperm [] = [[]]
iperm (h:xs) = concatMap (\xs -> insert h [] xs) (iperm xs)

delete :: Ord a => a -> [a] -> [a]
delete a [] = []
delete a (h:t) = if a == h then t else h:(delete a t)

helper :: Ord a => a -> [a] -> [[a]]
helper a [b] = if a == b then [[a]] else [[]]
helper _ [] = [[]]
helper a xs = let sp = (sperm (delete a xs)) in map (\ys -> a:ys) sp

sperm :: Ord a => [a] -> [[[a]]]
sperm xs = (map (\a -> (helper a xs)) xs)