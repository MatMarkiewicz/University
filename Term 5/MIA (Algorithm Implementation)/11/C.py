n,m = map(int,input().split())
G = [[] for i in range(n)]
inDeg = [0]*n
for i in range(m):
    a,b = map(int,input().split())
    G[a-1].append((b-1,i))
    inDeg[b-1] += 1

S = [i for i in range(n) if inDeg[i] == 0]
T = []
while S:
    v = S.pop()
    T.append(v)
    for u,i in G[v]:
        inDeg[u] -= 1
        if not inDeg[u]:
            S.append(u)

D = [(0,0)]*n
for v in T:
    for u,i in G[v]:
        vd,vt = D[v]
        ud,ut = D[u]
        if ud <= vd + 1:
            D[u] = vd + 1, max(vt,i)
d,t = max(D)
if d == n-1:
    print(t+1)
else:
    print(-1)
