n,m,k = map(int,input().split())
L = [int(input()) for _ in range(m)]
F = int(input())
print(sum([bin(x^F).count('1') <= k for x in L]))
