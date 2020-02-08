n = int(input())
a,b = 0,0
l = []
for _ in range(n):
    inpt = list(map(int,input().split()))[1:]
    li = len(inpt)
    if li%2:
        l.append(inpt[li//2])
    a += sum((inpt[:li//2]))
    b += sum((inpt[(li + 1)//2:]))
l.sort(reverse=True)
a += sum(l[::2])
b += sum(l[1::2])
print(a, b)
