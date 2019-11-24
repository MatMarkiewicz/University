n = int(input())
Costs = dict()

def add_lca(u,v,w):
    while u != v:
        if u<v:
            u,v=v,u
        Costs[u] = Costs.get(u,0) + w
        u = u//2

def ret_lca(u,v):
    res = 0
    while u != v:
        if u<v:
            u,v=v,u
        res += Costs.get(u,0)
        u = u//2
    return res

for i in range(n):
    inpt = list(map(int,input().split()))
    if inpt[0] == 1:
        add_lca(inpt[1],inpt[2],inpt[3])
    else:
        print(ret_lca(inpt[1],inpt[2]))