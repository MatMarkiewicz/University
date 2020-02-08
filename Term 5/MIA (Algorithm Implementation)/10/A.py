from itertools import permutations

inpt_ = list(input())

def swap1(s):
    return [s[1],s[2],s[3],s[0],s[4],s[5]]
def swap2(s):
	return [s[4],s[1],s[5],s[3],s[2],s[0]]

s = set()
for perm in permutations(inpt_):
    perm = list(perm)
    m = ['Z'] * 6
    for i in range(4):
        for j in range(4):
            for k in range(4):
                m = min(m,perm)
                perm = swap2(perm)
            perm = swap1(perm)
        perm = swap2(perm)
    s.add("".join(m))
print(len(s))
