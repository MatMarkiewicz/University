def sqrt(n):
    s = 0
    i = 1
    while n >= s:
        s += 2*i - 1
        i += 1
    return i - 2

print(sqrt(49))
print(sqrt(10000))
print(sqrt(10001))
print(sqrt(120))
print(sqrt(121))
print(sqrt(122))