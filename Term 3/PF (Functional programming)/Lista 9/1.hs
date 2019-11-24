
f :: [Int] -> [Int]
f (p:xs) = [x| x<-xs, x `mod` p /= 0]

primes :: [Int]
primes = map head (iterate f [2..])