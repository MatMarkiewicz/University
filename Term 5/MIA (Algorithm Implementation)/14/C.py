n,k = map(int,input().split())
inpt = set()
for _ in range(n):
    inpt.add(input()[::2])

flag = False
for a in inpt:
    for b in inpt:
        c = 0 
        for i in range(k):
            if int(a[i]) + int(b[i]) != 2:
                c += 1
        if c == k:
            flag = True

if flag:
    print('yes')
else:
    print('no')
    