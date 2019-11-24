from math import gcd
n = int(input(""))
nums = [int(x) for x in input("").split(" ")]
Di = [nums[0]]
ResD = [nums[0]]
for i in range(1,n):
    Di = list(set([gcd(v,nums[i]) for v in Di] + [nums[i]]))
    ResD+=Di
print(len(set(ResD)))
