import itertools

class Formula:
    def  __init__(self, l, r, op):
        self.left = l
        self.right = r
        self.op = op
    def __str__(self):
        return f"({self.left.__str__()} {self.op} {self.right.__str__()})" 

class Impl(Formula):
    def __init__(self,l,r):
        super().__init__(l,r,"=>")     
    def calc(self,zmienne):
        return not(self.left.calc(zmienne) and not (self.right.calc(zmienne)))

class Iff(Formula):
    def __init__(self,l,r):
        super().__init__(l,r,"<=>")     
    def calc(self,zmienne):
        return self.left.calc(zmienne) == self.right.calc(zmienne)

class And(Formula):
    def __init__(self,l,r):
        super().__init__(l,r,"∧")            
    def calc(self,zmienne):
        return self.left.calc(zmienne) and self.right.calc(zmienne)

class Or(Formula):
    def __init__(self,l,r):
        super().__init__(l,r,"v")       
    def calc(self,zmienne):
        return self.left.calc(zmienne) or self.right.calc(zmienne)

class Neg(Formula):
    def __init__(self,r):
        super().__init__("",r,"~")      
    def calc(self,zmienne):
        return not self.right.calc(zmienne)

    def __str__(self):
        return f"~{self.right.__str__()}" 

class True_(Formula):
    def __init__(self):
        super().__init__("","","T")        
    def calc(self,zmienne):
        return True
    def __str__(self):
        return f"{self.op}" 

class False_(Formula):
    def __init__(self):
        super().__init__("","","┴")    
    def calc(self,zmienne):
        return False
    def __str__(self):
        return f"{self.op}" 

class Variable(Formula):
    def __init__(self,x):
        super().__init__(x,"","")
    def calc(self,variables):
        return variables[self.left]
    def __str__(self):
        return f"{self.left}" 

x = Impl( Variable("x"),And( Variable("y"), True_() ) )
#print(x)
#print(x.calc({"x":True,"y":True}))

def variables(form):
    if isinstance(form,Variable):
        return set(form.left)
    elif isinstance(form,Neg):
        return variables(form.right)
    elif isinstance(form,(Impl,Iff,Or,And)):
        return variables(form.left)|variables(form.right)
    return set()

#print(variables(x))



def is_tautology(form):
    vs = list(variables(form))
    all_values = list(itertools.product([False, True], repeat=len(vs)))
    return all([form.calc({vs[i] : x[i] for i in range(len(x))}) for x in all_values])

def test(f):
    if is_tautology(f):
        print(f"{f} jest tautologią")
    else:
        print(f"{f} nie jest tautologią")

taut1 = Or(Variable("x"),Neg(Variable("x")))
taut2 = Impl(And(Impl(Neg(Variable("x")),Variable("y")),Impl(Neg(Variable("x")),Neg(Variable("y")))),Variable("x"))
f2 = Impl(And(Impl(Neg(Variable("x")),Variable("y")),Impl(Neg(Variable("x")),Variable("y"))),Variable("x"))
taut3 = Iff(Impl(Variable("x"),Variable("y")),Impl(Neg(Variable("y")),Neg(Variable("x"))))
f3 = Iff(Iff(Variable("x"),Variable("y")),Impl(Neg(Variable("y")),Neg(Variable("x"))))

test(x)
test(True_())
test(taut1)
test(taut2)
test(f2)
test(taut3)
test(f3)
