data RegExpr = Exp Char | Concat RegExpr RegExpr | Alternation RegExpr RegExpr | Star RegExpr | Epsilon deriving Show

class Monad m => Nondet m where
    amb :: m a -> m a -> m a
    fail' :: m a
       
match' :: Nondet m => RegExpr -> String -> m String
match' Epsilon s = return s
match' (Exp a) [] = fail'
match' (Exp a) (s1:s2) = if a == s1 then return s2 else fail'
match' (Concat e1 e2) s = do
                            s' <- match' e1 s
                            match' e2 s'
match' (Alternation e1 e2) s = amb (match' e1 s) (match' e2 s)
match' (Star (Star e)) s = match' (Star e) s
match' (Star e) s = match' (Alternation (Concat e (Star e)) Epsilon) s

match :: Nondet m => RegExpr -> String -> m ()
match e s = do 
    s' <- (match' e s)
    if s' == [] then return () else fail'

instance Nondet [] where
    amb = (++)
    fail' = []

instance Nondet Maybe where
    amb Nothing c = c
    amb c _ = c
    fail' = Nothing

matchL e s = match e s :: [()]
matchM e s = match e s :: Maybe ()

testRE = Concat (Alternation (Exp 'a') (Exp 'b')) (Alternation (Exp 'a') (Exp 'b'))
testRE2 = Star (Alternation (Exp 'a') (Exp 'b'))
testRE3 = Star (Star (Star (Exp 'a')))
