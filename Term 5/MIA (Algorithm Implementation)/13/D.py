n,m,k = map(int,input().split())
DP = [[0 for _ in range(3002)] for __ in range(3002)]
W = [[0 for _ in range(20)] for __ in range(20)]

for i in range(m):
    u,v = map(int,input().split())
    u,v = u-1,v-1
    W[u][v] = 1
    W[v][u] = 1

def ones(i):
    return bin(i).count('1')

for s in range(2**n):
    if ones(s)==2:
        a,b=-1,-1
        for j in range(n):
            if (s&(1<<j)):
                if a==-1:
                    a=j
                else:
                    b=j
        DP[s][s] = W[a][b]
    elif ones(s)>2:
        t = s
        while t:
            for i in range(n):
                if (t&(1<<i)):
                    for j in range(n):
                        if (s&(1<<j)) and W[i][j] and (~t&(1<<j)):
                            DP[s][t] += DP[s^(1<<i)][t^(1<<i)] + DP[s^(1<<i)][t^(1<<i)^(1<<j)]
            DP[s][t] /= ones(t)
            t = (t-1)&s


res = 0
for s in range(2**n):
    if ones(s) == k:
        res += DP[(2**n)-1][s]

print(int(res))