from math import gcd
from random import randint
from time import time
#n = int(input(""))
n = 500000
#nums = input("").split(" ")
print("generowanie liczb")
nums = [randint(1,1000000000000000000) for x in range(500000)]
print("obliczenia")
b = time()

S1 = set()
S2 = set()
S1.add(nums[0])
S2.add(nums[0])
for i in range(1,n):
    S3 = set()
    for e in S2:
        x = gcd(nums[i],e)
        S3.add(x)
        S1.add(x)
    S1.add(nums[i])
    S3.add(nums[i])
    S2=S3
print(len(S1))

a =time()
print(a-b)

