{-# LANGUAGE FunctionalDependencies , FlexibleContexts , FlexibleInstances #-}

import Data.Char

class Monad m => StreamTrans m i o | m -> i o where
    readS :: m ( Maybe i)
    emitS :: o -> m ()

myToLower :: StreamTrans m Char Char => m Integer
myToLower =
    aux 0 where
    aux count = do
        next <- readS
        case next of
            Nothing -> return count
            Just c -> do
                emitS (toLower c)
                if isUpper c then 
                    aux (count + 1)
                else 
                    aux count

instance StreamTrans IO Char Char where
    readS = do
        ent <- getChar
        if ent == '\n' then
            return Nothing
        else
            return (Just ent)
    emitS = putChar

main :: IO ()
main = do
    ret <- myToLower
    print ret

newtype ListTrans i o a = LT' { unLT' :: [i] -> ([i], [o], a) }

instance Functor (ListTrans i o ) where
    fmap f (LT' g) = (LT' h) where
        h l = let (i,o,a) = g l in (i,o,f a)
 
instance Applicative (ListTrans i o ) where
    pure a = LT' f where
        f li = (li,[],a)
    (LT' f) <*> (LT' g) = (LT' h) where
        h li = let (lif,lof,af) = f li in let (lig,log,ag) = g lif in (lig,lof ++ log,af ag)

instance Monad (ListTrans i o ) where
    (LT' f) >>= g = LT' h where
        h li = let (lif,lof,af) = f li in let (lig,log,ag) =  (unLT' (g af)) lif in (lig,lof ++ log,ag)

instance StreamTrans ( ListTrans i o) i o where
    readS = LT' (\i -> if null i then ([],[],Nothing) else (tail i,[],Just (head i)))
    emitS o = LT' (\i -> (i,[o],()))

transform :: ListTrans i o a -> [i] -> ([o], a)
transform (LT' f) li = let (lif,log,af) = f li in (log,af)

-- transform myToLower  "TesToWy NapiS"





-- newtype State s a = State { unState :: s -> (s,a)}

-- return = pure 

-- instance Functor (State s) where
--     fmap f (State g) = State h where
--                         h s = let (s',x) = g s in (s',f x)

-- instance Applicative (State s) where
--     pure x = State f where
--         f s = (s,x)
--     State f <*> State g = State h where
--         h s = let (s',ff) = f s in let (s'',x) = g s' in (s'', ff x)

-- instance Monad (State s) where
--     State f >>= g = State h where
--                     h s = let (s',x) = f s in let (s'',y) = unState (g x) s' in (s'',y)




