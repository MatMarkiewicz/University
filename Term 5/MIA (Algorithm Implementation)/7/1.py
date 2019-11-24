n = int(input())
s = input()
ones = 0
for l in s:
    if l == '1':
        ones += 1
zeros = len(s) - ones
print(abs(ones-zeros))
