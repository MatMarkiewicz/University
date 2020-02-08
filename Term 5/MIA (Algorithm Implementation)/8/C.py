input()
res = 1
for a in map(int,input().split()):
    res ^= (a-1)%2
    print(res+1)