def vat_faktura(lista):
    return 0.23*sum(lista)
    
def vat_paragon(lista):
    return sum([x*0.23 for x in lista])

zakupy = [0.2, 0.5, 4.59, 6]


print(vat_faktura(zakupy))
print(vat_paragon(zakupy))