n = int(input())
s = set()
def f(x,y,p,l,n):
    if p > n or l > 10:
        return
    if p > 0:
        s.add(p)
    f(x,y,10*p+x,l+1,n)
    f(x,y,10*p+y,l+1,n)

for x in range(10):
    for y in range(x):
        f(x,y,0,0,n)
    
print(len(s))