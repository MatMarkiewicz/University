s = input()
t = input()

N = 5005
M = 1000000007
DP = [[0 for i in range(N)] for j in range(N)]

for i in range(len(s)):
    for j in range(len(t)):
        DP[i+1][j+1] = DP[i+1][j]
        if s[i] == t[j]:
            DP[i+1][j+1] = (DP[i+1][j+1] + DP[i][j] + 1)%M

ans = 0
for i in range(len(s)+1):
    ans = (ans + DP[i+1][len(t)])%M

print(ans)