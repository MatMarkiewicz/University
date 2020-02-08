n,m = map(int,input().split())
A = list(map(int,input().split()))
B = list(map(int,input().split()))
A.sort()
B.sort()
sa,sb = sum(A),sum(B)
ans=9999999999999999999999999999999999999
temp = 0
for i in range(n):
    ans = min(ans,temp+(n-i)*sb)
    temp += A[i]
temp = 0
for i in range(m):
    ans = min(ans,temp+(m-i)*sa)
    temp += B[i]
print(ans)