import random
def simplify_sent(sent,max_l,max_a):
    sent = [x for x in sent.split(" ") if len(x) <= max_l]
    if len(sent) > max_a:
        new_idxs = random.sample(range(len(sent)),max_a)
        new_idxs.sort()
        sent = [sent[i] for i in new_idxs]
    return " ".join(sent)

tekst = "Podział peryklinalny inicjałów wrzecionowatych \
kambium charakteryzuje się ścianą podziałową inicjowaną \
w płaszczyźnie maksymalnej."

print(simplify_sent(tekst,10,5))

with open("dziady3.txt",encoding="UTF-8") as f:
    data = f.read().split(".")
    data = [simplify_sent(x,10,5) for x in data]
    with open("new_dziady3.txt","w+",encoding="UTF-8") as f2:
        f2.write(".".join(data))
