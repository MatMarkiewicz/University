{-# LANGUAGE KindSignatures, MultiParamTypeClasses, FlexibleInstances #-}
import Data.List (unfoldr)
import Data.Bool (bool)

(><) :: (a -> b) -> (a -> c) -> a -> (b,c)
(f >< g) x = (f x, g x)

warbler :: (a -> a -> b) -> a -> b
warbler f x = f x x

class Ord a => Prioq (t :: * -> *) (a :: *) where
    empty :: t a
    isEmpty :: t a -> Bool
    single :: a -> t a
    insert :: a -> t a -> t a
    merge :: t a -> t a -> t a
    extractMin :: t a -> (a, t a)
    findMin :: t a -> a
    deleteMin :: t a -> t a
    fromList :: [a] -> t a
    toList :: t a -> [a]
    insert = merge . single
    single = flip insert empty
    extractMin = findMin >< deleteMin
    findMin = fst . extractMin
    deleteMin = snd . extractMin
    fromList = foldr insert empty
    toList = unfoldr . warbler $ bool (Just . extractMin) (const Nothing) . isEmpty

newtype ListPrioq a = LP { unLP :: [a] }

instance Ord a => Prioq ListPrioq a where
    empty = LP []
    isEmpty (LP xs ) = xs == []
    insert a (LP []) = LP [a]
    insert a (LP (h:t)) = if a < h then LP (a:(h:t)) else LP (h:(unLP (insert a (LP t))))
    merge (LP []) lp2 = lp2
    merge (LP (h:t)) lp2 = merge (LP t) (insert h lp2)
    extractMin (LP (h:t)) = (h, (LP t))

{-
*Main> let t = LP [(1,2),(2,2)]
*Main> let s = insert (4,5) t
*Main> unLP s
[(1,2),(2,2),(4,5)]
*Main> let w = LP [(3,4),(5,4)]
*Main> let z = merge s w
*Main> unLP z
[(1,2),(2,2),(3,4),(4,5),(5,4)]
*Main> fst (extractMin z)
(1,2)
}