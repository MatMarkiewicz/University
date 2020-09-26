# SyK Lista 5

## Zadanie 1
Zdefiniuj pojęcie wyrównania danych w pamięci (ang.data alignment). Dlaczego dane typów prostych  (np.short,int,double)  powinny  być  w  pamięci  odpowiednio  wyrównane?  Jaki  związek  z  wyrównywaniem  danych  mają wypełnienia(ang.padding)  w  danych  typu  strukturalnego.  Odpowiadając  na powyższe pytanie podaj przykład struktury, której rozmiar w bajtach (wyliczony przez operator sizeof) jest większy niż suma rozmiaru pól składowych. Czemu służy wypełnienie wewnętrzne(ang.internal padding) a czemu wypełnienie zewnętrzne(ang.external padding)?

Dziejsze procesory wykonują operacje czytania i pisania po pamięci najbardziej efektywnie, gdy dane są 'wyrównane naturalnie', czyli gdy adres danej znajduje się na wielokrotności jej rozmiaru.

Wyrównanie danych oznacza rozmieszczenie danych w pamięci w taki sposob, aby każda z nich znajdowała się na adresie o wielokrotności jej rozmiaru.

Wypełnienie to włożenie pustych danych między elementy tak, aby każdy element był wyrównany.

Przykład struktury, która waży więcej niż jej pola:
```
typedef struct {
    bool x;
    int y;
} s;

// sizeof(s) == 8
```

Wypełnienie wewnętrzne służy do wyrównania elementów wewnątrz struktury, a
wypełnienie zewnętrzne do wyrównania całej struktury (wypełnienie po ostatnim elemencie) względem największego elementu wewnątrz niej.


---

## Zadanie 2
Dana jest funkcja o sygnaturze «int16_t you(int8_t index)» i fragmencie kodu podanym
poniżej. Funkcja ta została skompilowana z flagą -O0, a jej kod asemblerowy również jest podany. Nieznana jest natomiast funkcja «int16_t set_secret(void)». Jaki argument należy podać wywołując you, by odkryć wartość sekretu?

```
int16_t you(int8_t index) {
    struct {
        int16_t tbl[5];    // 2*5
        int8_t tmp;        // 1
                           // padding 1
        int16_t secret;    // 2
    } str;             // wielkość to 14

    str.secret = set_secret();
    // ...
    return str.tbl[index];
}

you: pushq %rbp
movq %rsp, %rbp
subq $24, %rsp
movl %edi, %eax
movb %al, -20(%rbp)    // tu wrzucamy index
call set_secret
movw %ax, -2(%rbp)     // zapisujemy wynik set_secret we właściwym miejscu w strukturze
// ...
movsbl -20(%rbp), %eax    // wrzucamy index do raxa
cltq
movzwl -14(%rbp,%rax,2), %eax // zwracamy [rbp-14+rax*2] 
leave
ret
```
Zatem żeby poznać wartość secret powinniśmy wywołać funkcję you z argumentem równym 6, ponieważ sekret jest zapisany pod rbp-2, stąd mamy równanie  
rbp-14+rax*2=rbp-2,  
stąd rax=6.

---

## Zadanie 3
Przeczytaj poniższy kod w języku C i odpowiadający mu kod w asemblerze, a następnie wywnioskuj jakie są wartości stałych «A» i «B».
```
typedef struct {
  int32_t x[A][B];    // A*B*4
                      // padding 0 lub 4
  int64_t y;          // 8
} str1;

typedef struct {
  int8_t array[B];    // 1*B
                      // padding 0, 1, 2 lub 3
  int32_t t;          // 4
                      // brak paddingu
  int16_t s[A];       // 2*A
                      // padding 0, 2, 4 lub 6
   int64_t u;         // 8
} str2;

void set_val(str1 *p, str2 *q) {
  int64_t v1 = q->t;
  int64_t v2 = q->u;
  p->y = v1 + v2;
}

set_val:
movslq 8(%rsi),%rax    // B + padding = 8 -> B należy do {5, 6, 7, 8}
addq 32(%rsi),%rax     // 8+4+padding+2*A+B=32 to chyba nie jest nam potrzebne
movq %rax,184(%rdi)    // A*B*4+{0, 4}=184
ret
```
Czyli $A*B*4=184$ lub $A*B*4+4=184$, gdzie $5<=B<=8$
* $A*B=46$ 
ale 46 nie jest podzielna przez 5, 6 ,7 ani 8, więc ta odpowiedź odpada
* lub $A*B=45$
$5|45$ zatem $A= 9$ i $B = 5$

---

## Zadanie 4
Przeczytaj poniższy kod w języku C i odpowiadający mu kod w asemblerze, a następnie wywnioskuj jaka jest wartość stałej «CNT» i jak wygląda definicja struktury «a_struct»
```
typedef struct {
    int32_t first;           // 4
                             // padding 
    a_struct a[CNT];         // a_struct_size * CNT
    int32_t last;            // 4
} b_struct;

void test (int64_t i, b_struct *bp) {
    int32_t n = bp->first + bp->last;
    a_struct *ap = &bp->a[i];
    ap->x[ap->idx] = n;
}

test:
movl   0x120(%rsi),%ecx      // ecx = bp.last
addl   (%rsi),%ecx           // ecx (n) = bp.first + bp.last
leaq   (%rdi,%rdi,4),%rax    // rax = 5i
leaq   (%rsi,%rax,8),%rax    // rax = bp + 40i (adres)
movq   0x8(%rax),%rdx        // rdx = bp + 40i + 8 (wartość)
movslq %ecx,%rcx
movq   %rcx,0x10(%rax,%rdx,8)// bp + 16 + 40i + 8*idx     = n
                             // bp + 40i + 8 + 8*idx + 8  = n
                             // bp->a[i] + 8*idx + 8      = n
                             // bp->a[i]->x[idx]          = n
retq
```

0 - 3: first
4 - ?: padding?
? - ? + size(A) * CNT: a_struct[]
288 - 291: last

Z instrukcji ```leaq   (%rsi,%rax,8),%rax    // rax = bp + 40i```  wiadomo, że size(A) = 40.
Z instrukcji ```movq   0x8(%rax),%rdx        // rdx = bp + 40i + 8``` widać, że padding kończy się w bp+8.
Zatem A*CNT = 288 - 8 = 280, czyli CNT = 280 / 40 = 7.

```
typedef struct {
    long long idx;
    long long x[4]; 
} a_struct;
```

---

## Zadanie 5
Zdefiniuj semantykę operatora «?:» z językaC. Jakie zastosowanie ma poniższa funkcja.
```
int32_t cread(int32_t *xp) {
    return (xp ? *xp : 0);
}
```
Używając  serwisu godbolt.org (kompilatorx86-64 gcc 8.2)  sprawdź,  czy  istnieje  taki  poziom  optymalizacji  (-O0, -O1, -O2 lub -O3),  że  wygenerowany  dla cread kod  asemblerowy  nie  używa  instrukcji  skoku. Jeśli nie, to zmodyfikuj funkcję cread tak, by jej tłumaczenie na asembler spełniało powyższy warunek.

Semantyka:
```cond ? x : y``` oznacza 
```
if (cond) return x;
else return y;
```

Sidenote: Podany na liście kod nie działa poprawnie -- xp castowane na boola zawsze daje true. Należy użyć xp == NULL.

```
#include <iostream>

int cread(int *xp) {
    int defaultVal = 0;
    int * yp = &defaultVal;
    int * res = (xp != NULL ? xp : yp);
    return *res;
}
```
Wtedy po kompilacji mamy:
![](https://i.imgur.com/4aCs9Vi.png)

---


## Zadanie 6
W  języku C struktury  mogą  być  zarówno  argumentami  funkcji,  jak  i  wartościami  zwracanymi przez funkcje. Za pomocą serwisu godbolt.org zapoznaj się z tłumaczeniem do asemblera funkcji przyjmujących  pojedynczy  argument  każdego  z  poniższych  typów  strukturalnych.  Następnie  zapoznaj  się  z  tłumaczeniem funkcji zwracających wartość każdego z tych typów. Jakie reguły dostrzegasz?

```
struct first {
    int val1;
};

struct second {
    int val2;
    int val1;
};

struct third {
    int val3;
    int val2;
    int val1;
};

struct fourth {
    int val4;
    int val3;
    int val2;
    int val1;
};

struct fifth {
    short val6;
    short val5;
    int val3;
    int val2;
    int val1;
};

struct sixth {
    int val7;
    int val4;
    int val3;
    int val2;
    int val1;
};

struct seventh {
    int val8[10000];
    int val4;
    int val3;
    int val2;
    int val1;
};
```

Testowane na
```
struct <<x>> foo(struct <<x>> a) {
    return a;
}
```
First i Second dają spodziewany krótki kilkulinijkowy wynik (wyjęcie elementu ze stosu i wrzucenie go do raxa). Przy flagach -O(1/2/3) zostaje to skrócone do dwulinijkowca
![](https://i.imgur.com/ftUnQNL.png)

Third, Fourth, Fifth do samego przeniesienia argumentów wymagają już po dwa rejestry.
![](https://i.imgur.com/AsXh57j.png)
![](https://i.imgur.com/c167Unb.png)
![](https://i.imgur.com/6xdiuLx.png)

Sixth ma już za dużo danych wg. kompilatora, więc będa one przenoszone za pomocą stosu zamiast rejestrów rax i rdx.
![](https://i.imgur.com/PjYvPgm.png)

Seventh już w ogóle nie radzi sobie sam ze struktura i zaprzęga do pomocy memcpy
![](https://i.imgur.com/UpgBBd8.png)

Widać zatem, że im większe struktury, tym bardziej assembler musi się napracowac, aby być w stanie je obsłużyć. Jeśli struct jest wystarczająco dużych rozmiarów, to może się on nie zmieścić w pamięci podręcznej L1 i trafi do L2 lub RAMu, co znacząco zmniejszy wydajność operacji. Zatem należy powstrzymywać się przed przekazywaniem / zwracaniem dużych struktur.

---

## Zadanie 7
W poniższej funkcji zmienna field jest polem bitowym typu int32_to rozmiarze 4. Jaką wartość wypisze ta funkcja na ekranie i dlaczego? Co się stanie, gdy zmienimy typ pola field na uint32_t? Na obydwa te pytania odpowiedz analizując tłumaczenia tej funkcji na język asemblera.
```
void set_field(void) {
    struct {
        int32_t field : 4;
    } s;
    s.field = 10;
    printf("Field value is: %d\n", s.field);
}
```
Pole bitowe oznacza, że zamiast całej wartości bierzemy tylko jej n bitów, czyli wartość jest wtedy and-owana z maską bitową skladającą się z n jedynek i interpretowana jako liczba n-bitowa. 

(10 binarnie to 1010)

Dla in32_t: -6
Dla uint32_t: 10

---

## Zadanie 8
Język C dopuszcza  deklaracje  tablic  wielowymiarowych  z  opuszczonym  rozmiarem  pierwszego wymiaru.  Taka  deklaracja  może  wystąpić  w  nagłówku  funkcji,  np.  ```void process(int32_t A[][77],size_t len)```.  Nie  można  natomiast  opuszczać  rozmiarów  innych  wymiarów,  np. ```«void bad(int32_tA[77][], size_t len)```  nie  jest  poprawną  deklaracją.  Wyjaśnij,  dlaczego  tak  jest  odwołując  się  do  sposobu, w jaki kompilator tłumaczy odwołania do tablic z C na asembler.

A\[SIZE1]\[SIZE2] oznacza, że mamy SIZE1 segmentów, każdy o długośći SIZE2 (razy rozmiar typu tablicy...). Mając A\[]\[SIZE] znamy rozmiar segmentów, więc wiemy o ile bajtów trzeba przesunąc wskaźnik z A do A\[x]\[y]: (x*SIZE+y). Mając A\[SIZE]\[] nie wiadomo o ile należy się przesuwać, bo nie wiadomo jaki rozmiar ma każdy segment.
