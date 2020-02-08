n = int(input())
bs = []
ws = []
k = 1
for i in range(n):
    c,s = map(int,input().split())
    if c:
        bs.append([s,k])
    else:
        ws.append([s,k])
    k+=1

used_b,used_w=0,0
lb,lw = len(bs),len(ws)
while used_b < lb and used_w < lw:
    if bs[used_b][0]<ws[used_w][0]:
        print(bs[used_b][1], ws[used_w][1], bs[used_b][0])
        ws[used_w][0] -= bs[used_b][0]
        used_b += 1
    else:
        print(bs[used_b][1], ws[used_w][1], ws[used_w][0])
        bs[used_b][0] -= ws[used_w][0]
        used_w += 1
while used_b < lb-1:
    used_b += 1
    print(bs[used_b][1], ws[lw-1][1], 0)
while used_w < lw-1:
    used_w += 1
    print(bs[lb-1][1], ws[used_w][1], 0)
