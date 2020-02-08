n = int(input())
Str = list(map(int,input().split()))

Reps = {}
for i,s in enumerate(Str):
    Reps.setdefault(s,[]).append(i)

M,m = 2 ** 121 - 1,int(1e9) + 1
Pows,Hashes = [1],[0]*(n+1)
for i in range(n):
    Pows.append((Pows[-1]*m)%M)
    Hashes[i+1] = (Hashes[i]*m +Str[i])%M

def hash(a,b):
    return (Hashes[a+b] - (Hashes[a]*Pows[b])%M)%M

ans = 0
i = 0
while i < n:
    for r in Reps[Str[i]]:
        if r<=i:
            continue
        if 2*r-i<=n and hash(i,r-i) == hash(r,r-i):
            ans = max(ans,r)
            i = r-1
            break
    i+=1

res = Str[ans:]
print(len(res))
print(" ".join(map(str,res)))
        
