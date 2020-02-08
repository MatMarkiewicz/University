n,m = map(int,input().split())
for i in range(m - n%m):
    print(n//m,end=' ')
for i in range(n%m):
    print(n//m + 1, end=' ')
