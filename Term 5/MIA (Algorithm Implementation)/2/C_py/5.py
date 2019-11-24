from math import gcd
n = int(input(""))
nums = [int(x) for x in input("").split(" ")]
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