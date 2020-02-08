n = int(input())
color = {c:i for i,c in enumerate('RGBYW')}
cards = {(color[c],int(v)-1) for c,v in input().split()}
m = len(cards)

def can_distinguish(a,b):
    k = {(c if (a >> c)&1 else -1, v if (b >> v)&1 else -1) for c,v in cards}
    return len(k) == m

res = min(bin(a).count('1')+bin(b).count('1') for a in range(32) for b in range(32) if can_distinguish(a,b))
print(res)