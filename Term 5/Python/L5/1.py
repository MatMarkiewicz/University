from time import time
from texttable import Texttable

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

def is_prime(n):    
    for d in range(2, int(n ** 0.5) + 1):        
        if n % d == 0:            
            return False    
    return True

class Primes:
    def __init__(self,max):
        self.max = max
        self.number = 1
    def __iter__(self):
        return self
    def __next__(self):
        self.number += 1
        if self.number >= self.max:
            raise StopIteration
        elif is_prime(self.number):
            return self.number
        else:
            self.__next__()


res = [["Czas","Imperatywna","Funkcyjna","Skladana","Iterator"]]
i = 1000

while i <= 128000:
    t00 = time()
    primes_im(i)
    t01 = time() - t00
    t10 = time()
    primes_fun(i)
    t11 = time() - t10
    t20 = time()
    primes_lc(i)
    t21 = time() - t20
    t30 = time()
    primes = Primes(i)
    for e in primes:
        pass
    t31 = time() - t30
    res.append([i,t01,t11,t21,t31])
    i *= 2

t = Texttable()
t.add_rows(res)
print(t.draw())

