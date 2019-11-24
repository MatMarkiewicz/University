N = 100010
G = [ [] for i in range(N)]
n = int(input())
for i in range(1,n):
    a = int(input())
    G[a].append(i+1)
    G[i+1].append(a)

for i in range(1,n+1):
    if len(G[i]) == 1:
        continue
    c = 0
    for e in G[i]:
        if len(G[e]) == 1:
            c+=1
    if c<3:
        print("No")
        exit()

print("Yes")