import sys

def BS(x):
    l = 1
    r = 1000000
    while (r-l) > 1:
        m = (l+r)//2
        if m*(m-1)//2 > x:
            r = m
        else:
            l = m
    if l*(l-1)//2 != x:
        print("Impossible")
        sys.exit()
    return l

a00,a01,a10,a11=map(int,input().split())

if (a00 + a01 + a10 + a11) == 0:
    print("0")
    sys.exit()


c0 = BS(a00)
c1 = BS(a11)

if a00==0 or a11==0:
    if (a01 + a10) == 0:
        if c0 == 1:
            c0 = 0
        if c1 == 1:
            c1 = 0
        print("0" * c0, end = "")
        print("1" * c1)
        sys.exit()

if (c0*c1) != (a01+a10):
    print("Impossible")
    sys.exit()

s = list("0" * (c0+c1))
for i in range(c0+c1):
    if c0==0 or a01 < c1:
        s[i] = "1"
        a10 -+ c1
        c1 -= 1
    else:
        a01 -= c1
        c0 -= 1

print("".join(s))
