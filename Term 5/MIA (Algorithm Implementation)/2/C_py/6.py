from collections import defaultdict 

nm = input("").split(" ")
n,m = int(nm[0]),int(nm[1])
g = [dict() for j in range(n)]
for i in range(m):
    data = input("").split(" ")
    a,b,c = int(data[0]),int(data[1]),int(data[2])
    g[a][b] = c
    g[b][a] = c

class Graph: 
    def minDistance(self,dist,queue): 
        minimum = float("Inf") 
        min_index = -1
        for i in range(len(dist)): 
            if dist[i] < minimum and i in queue: 
                minimum = dist[i] 
                min_index = i 
        return min_index 

    def dijkstra(self, graph, src,n,m): 
  
        row = n
        col = m
        dist = [float("Inf")] * row 
        parent = [-1] * row 
        dist[src] = 0
        queue = [] 
        for i in range(row): 
            queue.append(i) 
        while queue: 
            u = self.minDistance(dist,queue)     
            queue.remove(u) 
            for i,c in graph[u].items(): 
                if i in queue: 
                    if dist[u] + c < dist[i]: 
                        dist[i] = dist[u] + c 
                        parent[i] = u 
        del dist
        del queue
        return parent
  
G = Graph() 
parents = G.dijkstra(g,1,n,m) 

for i in range(n):
    if parents[i] != -1:
        g[i][parents[i]] = -1
del parents

vd = [False] * n

def find_path(graph, start, end, path=[]):
    path = path + [start]
    vd[start] = True
    if start == end:
        return path
    for node,c in graph[start].items():
        if c>= 0 and not vd[node]:
            newpath = find_path(graph, node, end, path)
            if newpath: return newpath
    return None

path = find_path(g,0,1,[])
if not path:
    print("impossible")
else:
    l = len(path)
    if path[l-1] != 1:
        print("impossible")
    else:
        print(f"{l} ",end="")
        for i in range(l):
            print(f"{path[i]} ",end = "")