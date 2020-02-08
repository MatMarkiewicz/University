n,m = map(int,input().split())
R = list(map(int, input().split()))
A = [[] for i in range(n+1)]
G = [[] for i in range(m)]
C = [-1] * m
V = [0] * m
for i in range(m):
    X = list(map(int, input().split()))
    for j in range(1,len(X)):
        x = X[j]
        A[x].append(i)
        if len(A[x]) == 2:
            a,b = A[x]
            G[a].append((b,1-R[x-1]))
            G[b].append((a,1-R[x-1]))

def BFS(v):
    C[v],V[v],i = 0,1,0
    queue = [v]
    while i < len(queue):
        u = queue[i]
        i+=1
        for w in G[u]:
            if C[w[0]] == -1:
                C[w[0]] = C[u] ^ w[1]
                queue.append(w[0])
                V[w[0]] = 1
            else:
                if C[w[0]] != C[u] ^ w[1]:
                    return False
    return True

f = True
for i in range(m):
    if C[i] == -1 and not BFS(i):
        f = False
        break

if f:
    print('YES')
else:
    print('NO')
