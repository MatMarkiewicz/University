import math
import time 

def primes_im(n):
    res = []
    for i in range(2,n):
        p = True
        for j in range(2, int(i ** 0.5) + 1):
            if i%j == 0:
                p = False
                break
        if p:
            res.append(i)
    return res

def primes_lc(n):
    return [x for x in range(2, n) if all(x % y != 0 for y in range(2, int(x ** 0.5) + 1))]

def is_prime_fun(n):
    return len(list(filter(lambda k: n%k == 0 and n != 2, range(2,int(n ** 0.5) + 1)))) == 0

def primes_fun(n):
    return list(filter(is_prime_fun,range(2,n)))

N = 100000
print(f"Czas dla wersji imperatywnej ", end = "")
t = time.time()
primes_im(N)
t2 = time.time() - t
print(t2)

print(f"Czas dla wersji list składanych ", end = "")
t = time.time()
primes_lc(N)
t2 = time.time() - t
print(t2)

print(f"Czas dla wersji funkcyjnej ", end = "")
t = time.time()
primes_fun(N)
t2 = time.time() - t
print(t2)
