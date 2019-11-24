{-# LANGUAGE Rank2Types #-}

newtype Church = Church (forall a. (a -> a) -> (a -> a))

church_to_int :: Church -> Integer
church_to_int (Church f) = (f (\x -> x+1)) 0

instance Eq Church where
    a == b = (church_to_int a) == (church_to_int b)

instance Ord Church where
    a <= b = (church_to_int a) <= (church_to_int b)
    
instance Show Church where
    show a = show (church_to_int a)

comp f g x = f(g(x))
iter f n = if n == 0 then id else comp f (iter f (n-1))

instance Num Church where
    a + b = (fromInteger ((church_to_int a) + (church_to_int b)))
    a - b = (fromInteger (max 0 ( (church_to_int a) - (church_to_int b) )))
    a * b = (fromInteger ((church_to_int a) * (church_to_int b)))
    abs a = a
    signum a = if (church_to_int a) == 0 then 0 else 1
    fromInteger i = Church (\f -> (iter f i))
    
zero = Church (\f -> id) 