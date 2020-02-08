n = int(input())
act_q,max_q,act_time=0,0,0
for i in range(n):
    t,c = map(int,input().split())
    act_q = max(0,act_q-t+act_time) + c
    act_time = t
    max_q = max(act_q,max_q)
print(act_time + act_q,max_q)