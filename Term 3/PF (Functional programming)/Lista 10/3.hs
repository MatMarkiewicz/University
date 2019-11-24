int :: (String -> a) -> String -> (Integer -> a)
int f s i = f (s ++ (show i))

eol :: (String -> a) -> String -> a
eol f s = f (s ++ "\n")

flt :: (String -> a) -> String -> (Float -> a)
flt f s i = f (s ++ (show i))

str :: (String -> a) -> String -> (String -> a)
str f s1 s2 = f (s1 ++ s2)

lit :: String -> (String -> a) -> String -> a
lit s1 f s = f (s ++ s1)

(^^^) :: (b -> a) -> (c -> b) -> (c -> a)
(^^^) f1 f2 = (f1 . f2)

sprintf dir = dir id ""
printf dir = dir putStr ""

-- sprintf (lit "Ala ma " ^^^ int ^^^ lit " kot" ^^^ str ^^^ lit ".") 3 "y"

test n = sprintf (lit "Ala ma " ^^^ int ^^^ lit " kot" ^^^ str ^^^ lit ".") n (if n == 1 then "a" else if 1 < n && n < 5 then "y" else "ow")