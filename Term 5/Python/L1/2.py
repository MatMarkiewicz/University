
def change(n):
    n0 = n
    t = [20,10,5,2,1]
    t2 = []
    for x in t:
        t2.append((x,n//x))
        n = n%x
    t3 = filter(lambda x : x[1] > 0,t2)
    print(f"Do wydania {n0}zł potrzeba ", end = "")
    for e in t3:
        print(f"{e[1]} * {e[0]}zł, ", end = "")

change(123)