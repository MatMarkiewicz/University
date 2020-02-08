n,m,k = map(int,input().split())
l,r = 1,n*m
while l<r:
    mid = (l+r)//2
    c = 0
    for i in range(1,n+1):
        c += min(m,mid//i)
    if c < k:
        l = mid+1
    else:
        r = mid
print(l)