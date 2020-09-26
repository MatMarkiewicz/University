# SyK L3

## Zad. 1 
*Podkreślone wartości oznaczają, że może chodzić o adres*
1. **0x100**
2. 0x13
3. **0x108**
4. 0xFF
5. 0xAB
6. 0x11
7. **0x110**
8. 0x11
9. 0x13

## Zad. 2
Indeks | Adres | Wartość
--- | --- | ---
1. | 0x100 | 0x100
2. | %rdx | 0x10
3. | %rax | 0x10
4. | 0x110 | 0x14
5. | %rcx | 0x0
6. | %rax | 0xAB00
7. | %rdx | 0x10
8. | %rdx | 0x16

## Zad. 3
Sufiks | #Bajtów
--- | ---
b | 1
w | 2
l | 4
q | 8

1. mov**l** %eax,(%rsp) - %eax ma 4 bajty
2. mov**w** (%rax),%dx - %dx ma 2 bajty
3. mov**b** $0xFF, %bl - %bl ma 1 bajt
4. mov**b** (%rsp,%rdx,4),%dl - %dl ma 1 bajt
5. mov**q** (%rdx),%rax - %rax ma 8 bajtów
6. mov**w** %dx,(%rax) - %dx ma 2 bajty
 

## Zad. 4
1. jest ok
2. %rax ma 8 bajtów, a **b** przenosi 1
3. może być tylko jedno wyciągnięcie adresu **()** w pojedyńczej instrukcji
4. nie ma takiego adresu jak %sl (ani na slajdach z wykładu, ani na *online gcc assembler*)
5. nie można czegoś włożyć do wartości
6. powinno być (%rdx)
7. %si ma 2 bajty, a **b** przenosi 1

## Zad. 5
1. x + 6
2. x + y
3. x + 4y
4. 7 + x + 8x == 7 + 9x
5. 10 + 0 + 4y ==  10 + 4y
6. 9 + x + 2y

## Zad. 6
Korzystamy z: A - B == A + (-B)
```
neg %rdi
add %rsi, %rdi
```

## Zad. 7
```
leaq    (%rdi,%rsi), %rax; czyli rax = x + y
movq    %rax, %rdx
sarq    $31, %rdx;         czyli rdx = (x + y) >> 31
xorq    %rdx, %rax
subq    %rdx, %rax;        czyli (rax ^ rdx) - rdx
ret
```
* Dla dodatniej sumy x + y wynikiem będzie ona sama -- rdx == 0, a dla dowolnego z: z ^ 0 == z
* Dla ujemnej sumy x + y:
    rdx == -1
    Dla dowolnego z: z ^ -1 == ~z, więc rax == ~(x + y)
    Dla dowolnego ż: -ż == ~ż + 1, więc rax - rdx == ~(x + y) - (-1) == -(x + y)

Zatem wynikiem jest abs(x + y)

## Zad. 8
```
movsbw  %dil, %di           mov z roszerzeniem o znak, zmienia int8 na int16 (pozostałe bity rejestru bez zmian)
movl    %edi, %edx          zapisanie wartości int16 m w rejestrze rdi (górne 32 bity się zerują)
sall    $4, %edx            shift arytmetyczny w lewo, oblicza m<<4, czyli 16*m (górne 32 bity się zerują)
subl    %edi, %edx          odjęcie od m<<4 wartości m, czyli obliczenie 15m (górne 32 bity się zerują)
leal    0(,%rdx,4), %eax    obliczenie 4*15m = 60m (górne 32 bity się zerują)
movsbw  %sil, %si           mov z roszerzeniem o znak, zmienia int8 na int16 (pozostałe bity rejestru bez zmian)
addl    %esi, %eax          dodanie wartości int16 60m + int16 s 
```
Operacje na dolnych 32 bitach rejestrów 64 bitowych zerują górne 32 bity. Sytuacja ta nie występuje podczas operacji na dolnych 16, lub 8 bitach. Operacja movsbw pozwala nam rozszerzyć wartość zapisaną na 8 bitach do 16 bitów poprzez wpisanie w górne 8 bity wartości z ósmego bita. Dzięki temu możemy wykonać konwersję int8 do int16. 
Funkcja oblicza wartość s + 60m zapisaną jako int16.

## Zad. 9
1.
Hex | sign | exp | f | exp in hex
--- | --- | --- | --- | --- |
0xC0D20004 | 1 | 10000001 | 101D20040 | 2^2
+ 0x72407020 | 0 | 11100100 | 10007020 | 2^101
Wynik to 0x72407020, ponieważ mając 2^101 - 2^2 wynik zaokrągla się do 2^101

2.
Hex | sign | exp | f |
--- | --- | --- | --- |
0xC0D20004 | 0 | 10000001 | 10111000000000000000100
+ 0x40DC0004 | 1 | 10000001 | 00010100000000000000100
= | 0 | 10000001 | 00010100000000000000100
Normalizujemy do 2^(-2)
Hex | sign | exp | f |
--- | --- | --- | --- |
0x3EA00000 | 0 | 01111101 | 010

3.
Hex | sign | exp | f |
--- | --- | --- | --- |
0x5FBE4000 | 0 | 10111111 | 0111110010...
+ 0x3FF80000 | 0 | 01111111 | 11110...
= | 1 | 10111111 | 1011110010...
+ 0x5FBE4000 | 0 | 10111111 | 0111110010...
= 0xEF400000 | 1 | 10111110 | 100...