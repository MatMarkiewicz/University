import math
from texttable import Texttable

results = []
all_votes = 0
with open("wybory.txt",encoding="UTF-8") as f:
    data = f.readlines()
    for line in data:
        if line[1] == ".":
            if results:
                results[-1][2].sort()
            line = line.split(" ")
            name_of_party = " ".join(line[1:-1])
            votes_to_party = int(line[-1])
            results.append([votes_to_party,name_of_party,[]])
            all_votes += votes_to_party
        else:
            line = line.split(" ")
            name_of_candidate = " ".join(line[1:-1])
            votes_to_candidate = int(line[-1])
            results[-1][2].append([votes_to_candidate,name_of_candidate])

def assign(res,all_votes,n):
    new_res = res
    threshold = all_votes * 0.05
    new_res = [x for x in new_res if x[0] >= threshold]
    I_table = [(x[0]/i,x[1]) for x in new_res for i in range(1,n)]
    I_table.sort()
    I_table.reverse()
    dict_of_res = {}
    assign = []
    for e in new_res:
        dict_of_res[e[1]] = e[2]
    for i in range(n):
        assign.append([I_table[i][1],dict_of_res[I_table[i][1]].pop()[1]])
    return assign

asn = assign(results,all_votes,12)
asn.sort()
asn = [["Partia","Kandydat"]] + asn
table = Texttable()
table.add_rows(asn)
print(table.draw())
