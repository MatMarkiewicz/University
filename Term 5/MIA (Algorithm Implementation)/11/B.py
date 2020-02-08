n,m = map(int,input().split())
G = [[] for i in range(n)]
for i in range(m):
    a,b = map(int,input().split())
    G[a-1].append(b-1)
    G[b-1].append(a-1)

def BFS(v):
    queue = [v]
    d = [-1] * n
    W = [0] * n
    d[v],W[v],i = 0,1,0
    while i < len(queue):
        u = queue[i]
        i += 1
        for w in G[u]:
            if d[w] == -1:
                queue.append(w)
                d[w] = d[u] + 1
            if d[w] == d[u] + 1:
                W[w] += W[u]
    return d,W
 
D0,W0 = BFS(0)
DN,WN = BFS(n-1)

res = W0[n-1]
for v in range(1,n-1):
    if D0[v] + DN[v] == D0[n-1]:
        res = max(res,2*W0[v]*WN[v])

print('{:.7f}'.format(res / W0[n-1]))