from bisect import bisect_left

n = int(input())
A = list(map(int,input().split()))

max_vals = []
result_lists = []

for i in range(n):
    val = -A[i]
    idx = bisect_left(max_vals,val)
    if idx == len(max_vals):
        max_vals.append(0)
        result_lists.append([])
    max_vals[idx] = val
    result_lists[idx].append(-val)

for res in result_lists:
    print(" ".join([str(i) for i in res]))
