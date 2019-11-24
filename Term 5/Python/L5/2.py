import itertools
from texttable import Texttable

alf = "aąbcćdeęfghijklłmnńoóprsśtuwyzźż"

def to_num(st,d):
    return "".join([d[s] for s in st.lower()])

def kryptorytm(a,b,c,op):
    letters = set()
    for letter in (a+b+c).lower():
        letters.add(letter)
    letters = list(letters)
    perms = list(itertools.permutations(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']))
    for perm in perms:
        d = {a:i for a,i in zip(letters,perm)}
        if eval(f"{int(to_num(a,d))} {op} {int(to_num(b,d))} == {int(to_num(c,d))}"):
            return d

a,b,c,op = "KIOTO","OSAKA","TOKIO",'+'
ans = kryptorytm(a,b,c,op)
na,nb,nc = to_num(a,ans),to_num(b,ans),to_num(c,ans)
print("Rozwiązaniem jest: ",end="")
for char,n in ans.items():
    print(f"{char} = {n}, ",end="")
print("ponieważ:\n")

table = Texttable()
table.set_deco(Texttable.HLINES)
table.set_cols_align(["r", "r", "r", "r"])
table.add_rows([["", a, "     ", na],
                [op, b, op, nb],
                ["", c, "     ", nc]])
print(table.draw())

a,b,c,op = "REBUS","I","SUDOKU",'*'
ans = kryptorytm(a,b,c,op)
na,nb,nc = to_num(a,ans),to_num(b,ans),to_num(c,ans)
print("Rozwiązaniem jest: ",end="")
for char,n in ans.items():
    print(f"{char} = {n}, ",end="")
print("ponieważ:\n")

table = Texttable()
table.set_deco(Texttable.HLINES)
table.set_cols_align(["r", "r", "r", "r"])
table.add_rows([["", a, "     ", na]
                [op, b, op, nb],
                ["", c, "     ", nc]])
print(table.draw())
