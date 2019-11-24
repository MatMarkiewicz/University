primes' :: [Int]
primes' = 2 : [x| x <- [3..],(all (\y -> x `mod ` y /= 0) (takeWhile (\a -> a^2 <= x) primes'))]