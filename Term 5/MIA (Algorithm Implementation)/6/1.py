n = int(input())
a = 0
b = 1
m = int(1e9 + 7)
for i in range(n-1):
    a,b = b,(a+b+2)%m
print(b)