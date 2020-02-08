a,b = map(int,input().split())
res = 0
for i in range(65):
    for j in range(i-1):
        if a <= (2**i - 1) - 2**j <= b:
            res += 1
print(res)