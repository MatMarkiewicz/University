n,m = map(int,input().split())
inpt = []

for i in range(m):
    k,f = map(int,input().split())
    inpt.append((k,f))

res = set()
for p in range(1,101):
    flag = True
    for k,f in inpt:
        if (k+p-1)//p != f:
            flag = False
            break
    if flag:
        res.add((n+p-1)//p )

if len(res) == 1:
    print(res.pop())
else:
    print(-1)
