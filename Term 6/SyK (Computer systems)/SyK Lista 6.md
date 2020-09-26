# SyK Lista 6

## Zadanie 1
Poniżej podano zawartość pliku main.c:
```cpp=
#include "stdio.h"

static int global = 15210;

static void set_global(int val) {
    global = val;
}

int main(void) {
    printf("before: %d\n", global);
    set_global(15213);
    printf("after: %d\n", global);
    return 0;
}
```
Polecenie gcc main.c -o main jest równoważne ciągowi poleceń
cpp -o main_p.c main.c; gcc -S main_p.c; as -o main.o main_p.s; gcc -o main main.o.
- Jaka jest rola poszczególnych poleceń w tym ciągu?
cpp -o preprocessor pliku wejściowego
gcc -S zamienia plik otrzymanego z preprocessora w plik assemblerowy
as -o kompiuje plik assemblerowy do pliku binarnego
gcc -o tworzy plik wykonywalny

- Skąd pochodzi kod, który znalazł się w pliku main_p.c?
Jest to kod wygenerowany przez C preprocessor (cpp), preprocessor odpowiada <span>m.</span>in. za rozwiajanie makr, i obsługę dyrektyw.
- Co zawiera plik main_p.s. Zauważ etykiety odpowiadające zmiennej global i obydwu funkcjom. W jaki sposób przyporządkować etykiecie jej typ?
main_p.s zawiera 'zassemblerowany' kod pliku main.c. Typ etykiety znajduje się tuż nad nią:
![](https://i.imgur.com/Y806OBW.png)


- Poleceniem objdump -t wyświetl tablicę symboli pliku main.o. Jakie położenie wg. tej tablicy mają symbole global i set_global?
![](https://cdn.discordapp.com/attachments/689526193849892867/700693886263361577/unknown.png)
- Poleceniem objdump -h wyświetl informacje o sekcjach w pliku main.o. Dlaczego adres sekcji .text i .data to 0? Jakie są adresy tych sekcji w pliku wykonywalnym main?

![](https://cdn.discordapp.com/attachments/689526193849892867/700694952409169930/unknown.png)
W main.exe:
![](https://cdn.discordapp.com/attachments/689526193849892867/700695077076598814/unknown.png)

Może chodzi o to?
![](https://i.imgur.com/YuS32iD.png)


## Zadanie 2
Poniżej podano zawartość pliku swap.c:
```cpp=
extern int buf[];

int *bufp0 = &buf[0];
static int *bufp1;
int intvalue = 0x77;

static void incr() {
    static int count = 0;
    count++;
}

void swap() {
    int temp;
    incr();
    bufp1 = &buf[1];
    temp = *bufp0;
    *bufp0 = *bufp1;
    *bufp1 = temp;
}
```
Wygeneruj plik relokowalny «swap.o», po czym na podstawie wydruku polecenia «readelf -t -s» dla każdego elementu tablicy symboli podaj:
• adres symbolu względem początku sekcji,
• typ symbolu – tj. «local», «global», «extern»,
• rozmiar danych, na które wskazuje symbol,
• numer i nazwę sekcji – tj. «.text», «.data», «.bss» – do której odnosi się symbol.
Co przechowują sekcje «.strtab» i «.shstrtab»?

![](https://media.discordapp.net/attachments/689526193849892867/701131660028018808/unknown.png?width=806&height=671)


plik relokowalny - zawiera kod i dane w formie, którą można łączyć z innymi relokowalnymi plikami obiektowymi w celu utworzenia pliku wykonywalnego. Każdy plik .o jest wytwarzany z dokładnie jednego pliku źródłowego (.c)

| Element    | Numer i nazwa sekcji | Typ           | Rozmiar | Adres symbolu |
| ---------- | -------------------- | ------------- | ------- | ------------- |
| count.1798 | 5 (bss)              | local         | 4       | 0...0         |
| swap       | 1 (text)             | global        | 30      | 0...0         |
| bufp0      | 3 (data)             | global        | 8       | 0...0         |
| buf        | UND ()               | global (extern) | 0       | 0...0         |

strtab - string table - przechowuje stringi
shstrtab - section header string - offset oraz rozmiar każdej sekcji.


## Zadanie 3
Rozważmy program skompilowany z opcją -Og składający się z dwóch plików źródłowych:
```cpp=
/* foo.c */

void p2(void);
int main() {
    p2();
    return 0;
}
```
```cpp=
/* bar.c */
#include <stdio.h>

char main;

void p2() {
    printf("0x%x\n", main);
}
```
Po uruchomieniu program drukuje pewien ciąg znaków i kończy działanie bez zgłoszenia błędu. Czemu tak się dzieje? Skąd pochodzi wydrukowana wartość? Zauważ, że zmienna main w pliku bar.c jest niezainicjowana. Co by się stało, gdybyśmy w funkcji p2 przypisali wartość pod zmienną main? Co by się zmieniło gdybyśmy w pliku bar.c zainicjowali zmienną main w miejscu jej definicji? Odpowiedzi uzasadnij posługując się narzędziem objdump.

*Wskazówka: Może się przydać opcja -d polecenia objdump*

![](https://media.discordapp.net/attachments/689526193849892867/700667661843169300/unknown.png)

Jak skompilujemy z flagą -Og to wtedy objdup -d wygląda tak:

![](https://i.imgur.com/ycMacDv.png) 
(0x48 zamiast 0x55)


Program nie zgłasza błędów, ponieważ zarówno p2, jak i main ma jedną silną oraz jedną słabą deklarację, więc wybierane są silne z nich.
Program wypisuje 0x55(0x48). Ta wartość to pierwszy bajt maina z foo. 
Jak inicjujemy main to się nie kompiluje, bo 'multiple definition of main'. 
Jak w p2 wpiszemy np. main = 'a', to program skompiluje się, jednak próba wykonania spowoduje naruszenie ochrony pamięci.

## Zadanie 4
```cpp=
extern int buf[];

int *bufp0 = &buf[0];
static int *bufp1;
int intvalue = 0x77;

static void incr() {
    static int count = 0;
    count++;
}

void swap() {
    int temp;
    incr();
    bufp1 = &buf[1];
    temp = *bufp0;
    *bufp0 = *bufp1;
    *bufp1 = temp;
}
```
Które wiersze w kodzie z zadania drugiego będą wymagać dodania wpisu do tablicy relokacji?

*Wskazówka: Zastanów się jakie dodatkowe informacje należy umieścić w plikach relokowalnych, by umieć powiązać miejsca wywołania procedur z położeniem procedury w skonsolidowanym pliku wykonywalnym. Mogą przydać się opcje -d oraz -d -r narzędzia objdump.*

![](https://cdn.discordapp.com/attachments/689526193849892867/701139463086014564/unknown.png)

Musimy widzieć, gdzie w pamięci znajduje się buf, bufp0, aby można się było do nich odnosić wewnątrz funkcji swap. Dodatkowo musimy wiedzieć gdzie znajduje się static int count, żeby móc go inkrementować 

```cpp=
extern int buf[];

int *bufp0 = &buf[0];
static int *bufp1;
int intvalue = 0x77;

static void incr() {
    static int count = 0;
    count++;
}

void swap() {
    int temp;
    incr();             // <-
    bufp1 = &buf[1];    // <-
    temp = *bufp0;      // <-
    *bufp0 = *bufp1;    // <-
    *bufp1 = temp;
}
```

## Zadanie 5
Wpis w tablicy symboli dla zmiennej buf w pliku swap.o wskazuje, że zmienna ta znajduje się w sekcji COMMON. Zmodyfikuj deklarację zmiennej buf w pliku swap.c tak, by wpis w tablicy symboli dla buf wskazywał na UNDEF. Jaka jest rola tych wpisów w procesie tworzenia pliku wykonywalnego przez linker?

Wpis w tablicy symboli dla zmiennej buf w piku swap.o wskazuje, że zmienna ta znajduje się w sekcji UNDEF. W pliku swap.c mamy:
```cpp=
extern int buf[];
```
więc symbol ten powinien znaleźć się w sekcji UNDEF, ponieważ używamy externa. Jeśli zmienimy plik swap.c na:
```cpp=
int buf[2];
```
wtedy symbol ten znajduje się w sekcji COMMON (trafiają tam rzeczy, które w przyszłości znajdą się w bss lub data, o czym zadecyduje linker)

![](https://cdn.discordapp.com/attachments/689526193849892867/701133932489343066/unknown.png)

Jeśli niezainicjalizowane zminne globalne trafiają początkowo do sekcji COMMON, wówczas mogą być one zdefiniowane w więcej niż jednym pliku, pomimo, że nie używamy externa. Linker na dalszym etapie zadecyduje, czy zmienne te trafiają do sekcji data, czy do sekcji bss.

## Zadanie 6
Dla podanych poniżej plików żródłowych wygeneruj pliki relokowalne przekazując kompilatorowi opcję «-fno-common».Następnie wykonaj konsolidację na dwa sposoby:
```
ld -M=merge-1.map -r -o merge-1.o foo.o bar.o
ld -M=merge-2.map -r -o merge-2.o bar.o foo.o
```
Posiłkując się narzędziem «objdump» podaj rozmiary sekcji «.data» i «.bss» plików «bar.o» i «foo.o». Wskaż rozmiar i pozycje symboli względem początków odpowiednich sekcji. Wyjaśnij znaczenie opcji «-fno-common» przekazywanej do kompilatora.
```cpp=
/* bar.c */
int bar = 42;
short dead[15];
```
```cpp=
/* foo.c */
long foo = 19;
char code[17];
```
Na czym polega **częściowa konsolidacja** z użyciem opcji «-r» do polecenia «ld»? Czym różni się sposób wygenerowania plików «merge-1.o» i «merge-2.o»? Na podstawie **mapy konsolidacji** (wygenerowanej opcją «-M=main.map») porównaj pozycje symboli i rozmiary sekcji w plikach wynikowych. Z czego wynikają różnice skoro konsolidator nie dysponuje informacjami o typach języka C?

![](https://i.imgur.com/Pa9g84d.png)

- Rozmiary sekcji:
    | Plik  | data | bss  |
    | ----- | ---- | ---- |
    | bar.o | 0x4  | 0x1e |
    | foo.o | 0x8  | 0x11 |

![](https://media.discordapp.net/attachments/689526193849892867/700671451795030066/unknown.png)

- Rozmiar i pozycje symboli względem początków odpowiednich sekcji:
    bar.o:
    | symbol | rozmiar | sekcja | przesunięcie |
    | ------ | ------- | ------ | ------------ |
    | dead   | 0x1e    | bss    | 0            |
    | bar    | 0x4     | data   | 0            |


    foo.o:
    | symbol | rozmiar | sekcja | przesunięcie |
    | ------ | ------- | ------ | ------------ |
    | code   | 0x11    | bss    | 0            |
    | foo    | 0x8     | data   | 0            |

- \-fno-common - dzięki tej opcji kompilator umieszcza niezaincjowane zmienne globalne w bss. Nie sprawdza, czy w więcej niż 1 pliku mamy zmienną o tej samej nazwie, bo linker tego nie rozstrzyga (nie sprawdza, wpycha od razu do bss)

- W merge-1.o mamy następującą kolejność argumentów: foo.o, bar.o. Natomiast w merge-2.o kolejność jest odwrotna.

    | mapa       | rozmiar .data | rozmiar .bss | poz. foo | fill | poz. bar | poz. code | fill | poz. dead |
    | ---------- | ------------- | ------------ | -------- | ---- | -------- | --------- | ---- | --------- |
    | merge1.map | 0xc           | 0x3e         | 0x00     | -    | 0x08     | 0x00      | 0xf  | 0x20      |
    | merge2.map | 0x10          | 0x31         | 0x8      | 0x4  | 0x00     | 0x20      | 0x2  | 0x00      |

- \-r tylko łączy sekcje (merguje sekcje z kiku plików), ale nie rozwiązuje relokacji na adresy. Przy każdej sekcji jest informacja o koniecznym wyrównaniu.

    ![](https://media.discordapp.net/attachments/689526193849892867/700672354203730040/unknown.png)

- Mapa konsolidacji (definicja z docsów Microsofta):
![](https://i.imgur.com/8N2okz7.png)

- Różnice wynikają z tego, że argumenty (pliki) są podane odwrotnie, przez co sekcje text i bss mają różne rozmiary



## Zadanie 7
**Plik wykonywalny** powstały w wyniku kompilacji poniższych plików źródłowych powinien być nie dłuższy niż 1KiB. Na podstawie **nagłówka pliku ELF** wskaż w zdeasemblowanym pierwszą instrukcję, którą wykona procesor po wejściu do programu. Na podstawie **nagłówków programu** wskaż pod jaki adres wirtualny zostanie załadowany **segment** z sekcją «.text».
```
1 /* start.c */
2 int is_even(long);
3
4 void _start(void) {
5     asm volatile(
6         "syscall"
7         : /* no output */
8         : "a" (0x3c /* exit */),
9         "D" (is_even(42)));
10 }
```
```
1 /* even.c */
2 int is_odd(long n);
3
4 int is_even(long n) {
5     if (n == 0)
6         return 1;
7     else
8         return is_odd(n - 1);
9 }
```
```
1 /* odd.c */
2 int is_even(long n);
3
4 int is_odd(long n) {
5     if (n == 0)
6         return 0;
7     else
8         return is_even(n - 1);
9 }
```
Wskaż w kodzie źródłowym miejsca występowania **relokacji**. Zidentyfikuj je w wydruku polecenia «objdump -r -d», po czym pokaż jak zostały wypełnione w pliku wykonywalnym. Na podstawie rozdziału §7.7 podręcznika „Computer Systems: A Programmer’s Perspective” zreferuj algorytm relokacji. Wydrukuj tabele relokacji plików relokowalnych, fragment mapy konsolidacji opisujący złączoną sekcję «.text», po czym oblicz ręcznie wartości, które należy wpisać w miejsce relokacji.

TODO (było na ask, ale nie mam w zeszycie :O)

## Zadanie 8
Używając narzędzi do analizy plików relokowalnych w formacie ELF i bibliotek statycznych, tj. objdump, readelf i ar odpowiedz na następujące pytania:
1. Ile plików zawierają biblioteki libc.a i libm.a (katalog /usr/lib/x86_64-linux-gnu)?
2. Czy polecenie «gcc -Og» generuje inny kod wykonywalny niż «gcc -Og -g»?
3. Z jakich bibliotek współdzielonych korzysta interpreter języka Python (plik /usr/bin/python)?

Odpowiedzi:

1. ``` 
    ar -t /usr/lib/x86_64-linux-gnu/libc.a | wc -l 
    wynik: 1690
    ar -t /usr/lib/x86_64-linux-gnu/libm.a | wc -l 
    wynik: 471
    ```
2. -g zawiera dodatkowe symbole dla debuggera zapisane w exec

3. ```readelf -d /usr/bin/python```
    libpthread.so.0, libc.so.6, libdl.so.2, libutil.so.1, libz.so.1, libm.so.6



