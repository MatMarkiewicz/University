n,m = map(int,input().split())
G = [[set() for i in range(n)] for j in range(n)]
for i in range(m):
    a,b,c = map(int,input().split())
    G[a-1][b-1].add(c)
    G[b-1][a-1].add(c)

for a in range(n):
    for b in range(n):
        for c in range(n):
            G[b][c] |= (G[a][c] & G[b][a])

q = int(input())
for i in range(q):
    u,v = map(int,input().split())
    if G[u-1][v-1]:
        print(len(G[u-1][v-1]))
    else:
        print(0)
