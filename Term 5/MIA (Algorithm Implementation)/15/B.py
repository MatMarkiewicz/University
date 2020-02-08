n = int(input())
print("? 1 2")
s1=int(input())
print("? 1 3")
s2=int(input())
print("? 2 3")
s3=int(input())
a3=int((s3-s1+s2)/2)
a2=s3-a3
a1=s2-a3
A = [a1,a2,a3]
for i in range(4,n+1):
    print(f'? 1 {i}')
    si = int(input())
    A.append(si-a1)
print("!"," ".join(list(map(str,A))))