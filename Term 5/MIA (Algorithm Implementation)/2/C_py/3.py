from math import gcd
n = int(input(""))
nums = [int(x) for x in input("").split(" ")]
GCD = [0 for i in range(n+3)]
le = 0
mp = dict()
for i in range(1,n+1):
    num = nums[i-1]
    for j in range(le):
        GCD[j] = gcd(GCD[j],num)
    le +=1
    GCD[le] = num
    GCD.sort()
    tmp = 0
    for k in range(le):
        if GCD[k] in mp:
            mp[GCD[k]] += 1
        else:
            mp[GCD[k]] = 1
        if(k==0):
            tmp+=1
            GCD[tmp] = GCD[k]
            continue
        elif(GCD[k] == GCD[k-1]):
            continue
        else:
            tmp +=1
            GCD[tmp] = GCD[k]
    le = tmp
print(mp)
