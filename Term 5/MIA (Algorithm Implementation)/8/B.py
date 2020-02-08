def f(x):
    if x%4==0:
        return x
    elif x%4==1:
        return 1
    elif x%4==2:
        return x+1
    return 0

n = int(input())
res = 0
for i in range(n):
    x,m = input().split()
    x,m = int(x),int(m)
    res ^= f(x-1)^f(x+m-1)

if res == 0:
    print("bolik")
else:
    print("tolik")