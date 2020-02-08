T = int(input())

def comp(i,j):
    print(f'? {A[i]+1} {A[j]+1}')
    res = input()
    return res == '>'

for _ in range(T):
    Min = []
    Max = []
    n = int(input())
    A = list(range(n))
    for i in range(n//2):
        if comp(2*i,2*i+1):
            Max.append(2*i)
            Min.append(i*2+1)
        else:
            Max.append(i*2+1)
            Min.append(i*2)
    if n%2:
        Max.append(n-1)
        Min.append(n-1)
    max_ = Max[-1]
    min_ = Min[-1]
    for m in Max[:-1]:
        if comp(m,max_):
            max_ = m
    for m in Min[:-1]:
        if not comp(m,min_):
            min_ = m
    
    print(f'! {min_+1} {max_+1}')