ana :: (b -> Maybe (a, b)) -> b -> [a]
ana f st = case f st of
    Nothing -> []
    Just (v, st') -> v : ana f st'

-- ana (\x -> Just (x,x+1)) 0

azip :: [a] -> [b] -> [(a,b)]
azip l1 l2 = ana aziph (l1,l2)
    where
        aziph ([],[]) = Nothing
        aziph (l1,[]) = Nothing
        aziph ([],l2) = Nothing
        aziph ((h1:t1),(h2:t2)) = Just ((h1,h2),(t1,t2))

-- azip [1,2,3] [4,5,6]

aiterate :: (a -> a) -> a -> [a]
aiterate f a0 = ana aiterateh a0
        where
            aiterateh a0 = Just (a0,(f a0))

-- take 10 (aiterate (2*) 1)

amap :: (a -> b) -> [a] -> [b]
amap f l = ana amaph l
    where
        amaph [] = Nothing
        amaph (h:t) = Just ((f h),t)

-- amap (\x -> x+2) [1,2,3]

cata :: (a -> b -> b) -> b -> [a] -> b
cata f v [] = v
cata f v (x:xs) = f x (cata f v xs) -- foldr

clength :: [a] -> Int
clength l = cata clengthh 0 l
        where
            clengthh a b = b+1

cfilter :: (a -> Bool) -> [a] -> [a]
cfilter f l = cata cfilterh [] l
        where
            cfilterh a b = if (f a) then a:b else b 

-- cfilter (\x -> x > 3) [1,2,3,4,5,6,7]

cmap :: (a -> b) -> [a] -> [b]
cmap f l = cata cmaph [] l
        where
            cmaph a b = (f a):b

-- cmap (\x -> x+2) [1,2,3]

data Expr a b =
    Number b
    | Var a
    | Plus (Expr a b) (Expr a b)


data Maybe' a b c = JustNum b | JustVar a | JustPlus c

ana' :: (c -> Maybe' a b (c,c)) -> c -> Expr a b
ana' f st = case f st of
    JustNum a -> Number a
    JustVar b -> Var b
    JustPlus (c1,c2) -> Plus (ana' f c1) (ana' f c2)


cata' :: (a -> b, b -> b -> b) -> Expr a b -> b
cata' (env, op) expr =
    case expr of
        Number x -> x
        Var x -> env x
        Plus x y -> op (cata' (env,op) x) (cata' (env,op) y)
    
find_val :: String -> [(String, a)] -> a
find_val var env = snd (head (filter (\x -> fst x == var) env))
    
eval env expr = cata' (find_in_env, (+)) expr
    where find_in_env var = find_val var env

