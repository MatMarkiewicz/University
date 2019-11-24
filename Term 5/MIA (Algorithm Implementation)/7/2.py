s = input()
bigger = 'a'
res = ''
for i in range(len(s)-1,-1,-1):
    if s[i] >= bigger:
        res = s[i] + res
        bigger = s[i]
print(res)