nm = input("").split(" ")
n,m = int(nm[0]),int(nm[1])
c = input("").split(" ")
cats = [int(e) for e in c]
graph = [ [] for i in range(n+1)]
for i in range(n-1):
    ab = input("").split(" ")
    a,b = int(ab[0]),int(ab[1])
    graph[a].append(b)
    graph[b].append(a)

visited = [0] * (n+1)
ans = [0]

def DFS(i,cc,m):
    visited[i] = 1
    if cats[i-1]:
        cc += 1
    else:
        cc = 0
    if cc > m:
        return
    if len(graph[i]) == 1 and i != 1:
        ans[0] += 1
        return
    for e in graph[i]:
        if not visited[e]:
            DFS(e,cc,m)

def BFS():
    queue = [(cats[0], 1, 1)]
    sums = 0
    while queue:
        isLeaf = True
        level_cat, v, p = queue.pop(0)
        for j in graph[v]:
            if j == p:
                continue
            isLeaf = False
            if cats[j-1] == 0:
                queue.append((0, j, v))
            elif level_cat + 1 <= m:
                queue.append((level_cat + 1, j, v))
        if isLeaf:
            sums += 1
    return sums


print(BFS())