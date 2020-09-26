# SyK lista 7 
## Zadanie 1 (ASK L7Z8)
Na podstawie rozdziału §7.12 podręcznika „Computer Systems: A Programmer’s Perspective” opisz proces **leniwego wiązania** (ang. lazy binding) symboli i odpowiedz na następujące pytania:
• Czym charakteryzuje się **kod relokowalny** (ang. Position Independent Code)?
• Do czego służą sekcje «.plt» i «.got» – jakie dane są tam przechowywane?
• Czemu sekcja «.got» jest modyfikowalna, a sekcje kodu i «.plt» są tylko do odczytu?
• Co znajduje się w sekcji «.dynamic»?
Zaprezentuj leniwe wiązanie na podstawie programu:
``` c=
/* lazy.c */
#include <stdio.h>

int main(void) {
    puts("first time");
    puts("second time");
    return 0;
}
```
skompilowanego poleceniem gcc -Os -Wall -ggdb -o lazy lazy.c. Uruchom go pod kontrolą debuggera GDB, ustaw punkty wstrzymań (ang. breakpoint) na linię 4 i 5. Po czym wykonując krokowo programn(stepi) pokaż, że gdy procesor skacze do adresu procedury «puts» zapisanego w «.got» – za pierwszym wywołaniem jest tam przechowywany inny adres niż za drugim.

*Wskazówka: Wykorzystaj rysunek 7.19. Dobrze jest zainstalować sobie nakładkę na debugger GDB dashboard1 lub GDB TUI.*

![](https://cdn.discordapp.com/attachments/689526193849892867/703930613236760636/unknown.png)

- GOT (Global Offset Table) zawiera adresy funkcji dynamicznie linkowanych, ale jego pierwsze 3 elementy są specjalne, jest to adres sekcji .dynamic, informacje dla linkera oraz punkt wejścia do linkera. Początkowo funkcje w .got nie są mapowane na ich właśćiwy kod - dzieje się tak dopiero po ich pierwszym wywołaniu. Dlatego .got jest modyfikowalny.
- PLT (Procedure Linkage Table) ma wpisy dla każdej funkcji w pliku relokowalnym oraz umożliwia zamiane jej adresu na adres faktyczny. Pierwszy element PLT też jest specjalny. 
- Kod relokowalny: Kod który nie jest przywiązany do konkretnego miejsca w pamięci.
- .dynamic: (z dokumentacji oracle): ![](https://i.imgur.com/kp5PVFd.png)

- Leniwe wiązanie: proces w którym rozwiązywanie symboli jest odwlekane w czasie, aż dany symbol zostanie użyty. O ile funkcje mogą być wiązane na żadanie, tak odniesienia do danych już nie.
  
![](https://cdn.discordapp.com/attachments/689526193849892867/703941883721941032/unknown.png) 
![](https://cdn.discordapp.com/attachments/689526193849892867/703941936184295464/unknown.png)

- Mając jakąś procedurę w pliku relokowalnym i wywołując ją pierwszy raz, np addvec wskaźnik instrukcji znajdzie się na pierwszej instrukcji PLT[2], ponieważ to ten wpis odpowiada za addvec. Ta intrukcja to bezwarunkowy skok do GOT[4], gdzie aktualnie znajduje się adres drugiej instrukcji z PLT[2], więc GOT "cofa nas" do PLT. Ta instrukcja to push ID dla addvec na stos. Następnie skaczemy do PLT[0], która pushuje na stos kolejne informacje do identyfikacji (GOT[1]) oraz skacze do linkera (to, gdzie on jest zapisane jest w GOT[2]). Mając na stosie te 2 informacje linker jest w stanie obliczyć adres addvec. Żeby nie powtarzać tego wszystkiego za każdym wywołaniem addvec, nadpisujemy GOT[4] adresem addvec.
  Jeśli wywołamy addvec po raz drugi ponownie zostaniemy przekierowani do pierwszej intrukcji PLT[2], czyli do skoku do GOT[4], ale tym razem nie będzie tam adresu, który wróci nas do PLT[2], ale będzie tam adres addvec. 

- Część z debuggowaniem
    * Ubuntu
    ![](https://cdn.discordapp.com/attachments/690922931139903519/703974109045850112/unknown.png)
    <br/>
    ![](https://cdn.discordapp.com/attachments/690922931139903519/703973783492362320/unknown.png)
    * Debian
    ![](https://i.imgur.com/RqHBb8E.png)
    <br/>
    ![](https://i.imgur.com/qyL5PQ2.png)

---

## Zadanie 2 (ASK L7Z4)
Rozważmy program składający się z dwóch plików źródłowych:
``` cpp=
/* str-a.c */
#include <stdio.h>

char *somestr(void);

int main(void) {
    char *s = somestr();
    s[5] = ’\0’;
    puts(s);
    return 0;
}
```
```cpp=
/* str-b.c */
char *somestr(void) {
    return "Hello, world!";
}
```
Po uruchomieniu program kończy się z błędem dostępu do pamięci. Dlaczego? Gdzie została umieszczona stała znakowa "Hello, world!"? Popraw ten program tak, by się poprawnie zakończył. Gdzie został umieszczony ciąg znaków po poprawce? Nie wolno modyfikować sygnatury procedury «somestr» i pliku «str-a.c», ani korzystać z dodatkowych procedur.

Napis "Hello world" trafił do sekcji rodata (read only data), ponieważ nie było przypisany do żadnej zmiennej, a jedynie zwracany. W linii 8 pliku str-a.c chcemy zmodyfikować ten string, co powoduje błąd dostępu do pamięci.

Zmieniamy plik str-b.c w następujący sposób:
 
```cpp=
char temp[] = "Hello, world!";
char *somestr(void) {
    return temp;
}
```

Dzięki temu ciąg znaków zostanie umieszczony w sekcji data i będziemy mogli go edytować.
PS. zrobienie `char *temp = "Hello, world!";` nadal umieści
zmienną temp w read only memory.

---

## Zadanie 3 
Korzystając z **dyrektyw asemblera** opisanych w GNU as: Assembler Directives stwórz plik źródłowy (z rozszerzeniem .s) w którym
1. zdefiniujesz globalną funkcję foobar,
2. zdefiniujesz lokalną strukturę podaną niżej:
```c=
static const struct {
char a[3]; int b; long c; float pi;
}
baz = { "abc", 42, -3, 1.4142 };
```
3. zarezerwujesz miejsce dla tablicy long array[100]?

Pamiętaj, że dla każdego zdefiniowanego symbolu należy uzupełnić odpowiednio tablicę .symtab o typ symbolu i rozmiar danych, do których odnosi się symbol. Z pliku źródłowego stwórz plik relokowalny. Analizując go przekonaj się o poprawności rozwiązania.

*Wskazówka Ktoś, a raczej coś może stworzyć rozwiązanie za Ciebie, a Ty musisz je tylko zrozumieć*

**Dyrektywa Assemblera** - wiadomość do assemblera, przekazująca assemblerowi coś, czego potrzebuje, aby wykonać proces assemblerowania.
Nie jest częścią samego programu, nie jest konwertowana na kod maszynowy.

1:
```c=
// ex3.c
int x = 5;
void foobar(void) {
    x++;
}
```
```asm=
// ex3.s
.globl foobar
.type foobar, @function
// kod foobar
.size foobar, .-foobar
```
2:
```c=
// ex3.c
static const struct {
char a[3]; int b; long c; float pi;
}
baz = { "abc", 42, -3, 1.4142 };
```
```asm=
// ex3.s
.section .rodata
.align 16        
.type baz, @object
.size baz, 24
baz:
.ascii "abc"
.zero 1 // zero to padding
.long 42
.quad -3
.long 1068827777 // taka reprezentacja danego floata, dunno
// moze tez byc .float
.zero 4
```
3:
```c=
// ex3.c
long array[100];
void arrayFill(int x) {
    for (int i = 0; i < 100; x++) {
        array[i] = i + x;
    }
}
```
```
// ex3.s
// kompilator wygeneruje:
.comm array, 800, <offset> (u mnie wychodzilo zawsze 32?)
// ale mozna tez tak:
array: .fill 800
```

![](https://cdn.discordapp.com/attachments/690922931139903519/704303571285573652/unknown.png)
Gdzie xs to array 

---

## Zadanie 4

Jakie konstrukcje językowe w C są blokadami optymalizacji (ang. optimization blockers)? Porównaj funkcje combine1 i combine4 ze slajdów i wyjaśnij, dlaczego wydajniejsza wersja musiała zostać stworzona ręcznie.

Blokadami optymalizacji są:
* wywołania procedur
    * mogą mieć efekty uboczne
    * funkcja dla tej samej wartości nie musi zwracać zawsze tej samej wartości
* dostępy do pamięci

```cpp=
void combine1(vec_ptr v, data_t *dest)
{
    long int i;
    *dest = IDENT;
    for (i = 0; i < vec_length(v); i++) {
        data_t val;
        get_vec_element(v, i, &val);
        *dest = *dest OP val;
    }
}
```

```cpp=
void combine4(vec_ptr v, data_t *dest)
{
    long i;
    long length = vec_length(v);
    data_t *d = get_vec_start(v);
    data_t t = IDENT;
    for (i = 0; i < length; i++)
        t = t OP d[i];
    *dest = t;
}
```

Wydajniejsza wersja musiała zostać stworzona ręcznie, gdyż:
1. Optymalizator (?) nie mógł sam wyrzucić wywołania vec_length, ponieważ nie wiedział, czy funkcja ta nie ma efektów ubocznych. 
2. Podobnie nie można było pozbyć się wywołań funkcji get_vec_element.
3. W combine4 wprowadzono zmienną tymczasową, żeby wyniku nie zapisywać za każdym razem pod adresem docelowym. Optymalizator nie mógł zrobić tego samemu, ponieważ nie mógł założyć, że te wywołania w każdej iteracji nie powodują innych zachowań programu.


---

## Zadanie 5
Na podstawie rozdziału §5.7 podręcznika „Computer Systems: A Programmer’s Perspective” i rysunku 5.11 wyjaśnij zasadę działania procesora o architekturze **superskalarnej**. Jak działa **spekulatywne wykonywanie** instrukcji? Co to znaczy, że poszczególne jednostki funkcjonalne procesora działają w sposób potokowy?

Architekturza **superskalarna** to taka, w której procesor może wywoływać kilka instrukcji w jednym cyklu.

![](https://cdn.discordapp.com/attachments/689526193849892867/703667600227303474/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/703670801424974004/unknown.png)

Czytane są instrukcje z instruction cache, nie tylko te, które maja być teraz wykonywane, ale również te, które będą wykonane w przyszłości. Problemem są instrukcje warunkowe, w ich przypadku wykorzystywany jest system do predykcji, czy warunek będzie spełniony, czy nie. Następnie instrukcje są dekodowane na zbiór operacji podstawowych (primitive operations (sometimes referred to as microoperations)) Każda taka instrukcja to podstawowa operacja arytmetyczna (np. dodawanie) / czytanie / zapisywanie do dysku.  
Następnie zbiór takich instrukcji jest przekazywany do Execution Unit, który składa się z kilku jednostek funkcjonalnych. Wynik nie jest nigdzie zapisywany do czasu, aż będzie pewne, że predykcja skoku była prawidłowa. W przeciwnym razie obliczenia są zapominane i wszystko cofa się do instrukcji warunkowej, a predyktor dostaje informacje o tym, że popełnił błąd. 

![](https://cdn.discordapp.com/attachments/689526193849892867/703676410178306139/unknown.png)

Na przykładzie mnożenia widzimy, że issue time to 1, oznacza to, że w każdym cyklu można rozpocząć 1 operację mnożenia. Jest to możliwe dzięki użyciu pipeliningu. Oznacza to, że operacja została podzielona na etapy, w przypadku mnożenia floatów są to: obliczenie wykładnika, obliczenie ułamka i zaokrąglenie wyniku.

---

## Zadanie 6
Rozpatrujemy procesor o charakterystyce podanej w tabeli 5.12 podręcznika „Computer Systems: A Programmer’s Perspective”. Zdefiniuj miarę wydajności CPE (ang. cycles per element/operation), następnie wyjaśnij pojęcie granicy opóźnienia (ang. latency bound) oraz granicy przepustowości (ang. throughput bound) procesora. Skąd biorą się wartości w tabelce na stronie 560?

![](https://cdn.discordapp.com/attachments/689526193849892867/703676410178306139/unknown.png)

**CPE** to miara wydajności dla programów operujących na wektorach albo listach. Mówi ona jak dużo cykli było potrzebne na wykonanie programu operującego na liście o danej długości. 

**Granica opóźnienia** - pojawia się, gdy ciąg operacji musi zostać wykonany w ściśle określonej sekwencji, ponieważ wynik jednej operacji jest potrzebny do rozpoczęcia kolejnej. Taka granica może ograniczać wydajność programu, gdy zależności danych ograniczają możliwości procesora do wykorzystania instrukcji równoległych.

**Granica przepustowości** - oznacza moc obliczeniową funkcjonalnych jednostek procesora. Ta granica wyznacza krańcową granicę wydajności programu.

<!-- The **latency bound** is encountered when a series of operations must be performed in strict sequence, because the result of one operation is required before the next one can begin. This bound can limit program performance when the data dependencies in the code limit the ability of the processor to exploit instruction-level parallelism.

The **throughput bound** characterizes the raw computing capacity of the processor’s functional units. This bound becomes the ultimate limit on program performance. -->

**Tego nie przeklejać:**
Na stronie 560 nie ma żadnej tabelki. Nie ma to jak kurwa precyzowanie pytań. W następnym zadaniu jest mowa o tabelce 5.21 ze strony 573, u mnie to jest na stronie 515, więc strona 560 pwi powinna u mnie oznaczać 502, na której mam taką tabelkę:

![](https://cdn.discordapp.com/attachments/689526193849892867/703689705560080474/unknown.png)

Granica opóźnienia wyznacza minimalna wartość CPE dla każdej funkcji wykonywującej łączące operacje w śćiśle określonej sekwencji. Granica przepustowości wyznacza minimalną granicę dla CPE na podstawie maksymalnej szybkości z jaką procesor może wykonywać obliczenia. Np, jeśli mamy tylko jeden multyplikator mający 'issue time' 1 cyklu, to procesor nie może wykonać więcej operacji mnożenia niż jedna na cykl. Choć procesor ma trzy jednostki potrafiące wykonywać dodawania na liczbach całkowitych, a 'issue time' takiej operacji to 0.33, to konieczność wczytywania elementów z pamięci tworzy dodatkową granicę przepustowości CPE równą 1 dla funkcji łączonych.

<!-- The latency bound gives a minimum value for the CPE for any function that must perform the combining operation in a strict sequence. The throughput bound gives a minimum bound for the CPE based on the maximum rate at which the functional units can produce results. For example, since there is only one multiplier, and it has an issue time of 1 clock cycle, the processor cannot possibly sustain a rate of more than one multiplication per clock cycle.We noted earlier that the processor has three functional units capable of performing integer addition, and so we listed the issue time for this operation as 0.33. Unfortunately, the need to read elements from memory creates an additional throughput bound for the CPE of 1.00 for the combining functions. -->

---

## Zadanie 7
Z czego wynika wysoka wydajność funkcji combine6 (tabelka 5.21, str. 573)? Jak zoptymalizować ten kod by dojść do granicy przepustowości procesora?
```cpp=
/* Unroll loop by 2, 2-way parallelism */
void combine6(vec_ptr v, data_t *dest)
{
    long int i;
    long int length = vec_length(v);
    long int limit = length-1;
    data_t *data = get_vec_start(v);
    data_t acc0 = IDENT;
    data_t acc1 = IDENT;

/* Combine 2 elements at a time */
for (i = 0; i < limit; i+=2) {
    acc0 = acc0 OP data[i];
    acc1 = acc1 OP data[i+1];
}

/* Finish any remaining elements */
for (; i < length; i++) {
    acc0 = acc0 OP data[i];
}
*dest = acc0 OP acc1;
}
```
Figure 5.21 Unrolling loop by 2 and using two-way parallelism. This approach makes
use of the pipelining capability of the functional units.

Wysoka wydajnośc wynika z faktu, że kod jest napisany w sposób pozwalający wykonywać kilka operacji równolegle (pętla została w części rozwinięta w taki sposó, że acc0 i acc1 nie zależą od siebie, dlatego mogą się liczyć równolegle). 

![](https://cdn.discordapp.com/attachments/689526193849892867/703694038917840986/unknown.png)

Zgodnie z ksiażką rozwinięcie tak 5-ciu zmiennych prowadzi do osiągnięcia granicy wydajności procesora.

---

## Zadanie 8 (ASK L9Z1)
Rozważmy dysk o następujących parametrach: jeden talerz; jedna głowica; 400 tysięcy ścieżek na powierzchnię; 2500 sektorów na ścieżkę; 7200 obrotów na minutę; czas wyszukiwania: 1ms na przeskoczenie o 50 tysięcy ścieżek.
1. Jaki jest średni czas wyszukiwania? - (wejście na właściwą ścieżkę) 
$\frac{1}{3} * 4000000 \; \text{ścieżek} * \frac{1 ms}{50000 ścieżek} = \frac{8}{3}ms$ 
1/3 to wartość całki, która ma chyba odpowiadać za średnią odległość, reszta z treści zadania

2. Jaki jest średni czas opóźnienia obrotowego? - (znalezienie sektora) 
$\frac{1}{2*RPM} = \frac{60 \frac{s}{m} * 1000 \frac{ms}{s}}{2 * 7200 \frac{1}{m}} \approx 4.17ms$

3. Jaki jest czas transferu sektora? 
$\frac{1}{RPM * (\text{ilość sektorów na ścieżkę})} = \frac{60 \frac{s}{m} * 1000 \frac{ms}{s}}{7200 \frac{1}{m} * 2500} \approx 0.0003ms$

4. Jaki jest całkowity średni czas obsługi żądania?
$\frac{8}{3}ms + 4.17ms + 0.0003ms = 6.84ms$


---

## Zadanie 9 (ASK L9Z2)
Rozważmy dysk o następujących parametrach: 360 obrotów na minutę, 512 bajtów na sektor, 96 sektorów na ścieżkę, 110 ścieżek na powierzchnię. Procesor czyta z dysku całe sektory. Dysk sygnalizuje dostępność danych zgłaszając przerwanie na każdy przeczytany bajt. Jaki procent czasu procesora będzie zużywała obsługa wejścia-wyjścia, jeśli wykonanie procedury przerwania zajmuje 2.5µs? Należy zignorować czas wyszukiwania ścieżki i sektora.  
Czas transferu:
$\frac{1}{96 \frac{sektorów}{ścieżkę}} * \frac{1}{360 RPM}  * 60 \frac{s}{m} * 1000 \frac{ms}{s} \approx 1.736 ms$
Cas przerwań:
$512 * 2.5µs = 1.28ms$

$\frac{\text{czas przerwań}}{\text{czas transferu}} = \frac{1.28ms}{1.736ms} *100\% = 73.7\%$

Do systemu dodajemy kontroler DMA. Przerwanie będzie generowane tylko raz po wczytaniu sektora do pamięci. Jak zmieniła się zajętość procesora?  

$\frac{\text{czas przerwań}}{\text{czas transferu}} = \frac{2.5µs}{1.736ms} *100\% = 0.144\%$

*Wskazówka W tym zadaniu procedura obsługi przerwania zajmuje się przetworzeniem przeczytanych danych i będzie wywołana za każdym razem, gdy zgłoszono przerwanie.*



---

## Zadanie 10 (ASK L9Z4)
W przeważającej większości systemów implementujących moduły DMA, procesor ma niższy  priorytet dostępu do pamięci głównej niż moduły DMA. Dlaczego?
*Wskazówka: Co się może stać, jeśli urządzenia nie mają gwarancji wykonywania transferów w regularnych odstępach czasu?*

Niektóre urządzenia z DMA nie mają wystarczająco RAMu, by móc przechować dane, które chcą zapisać. Przykładem może być karta sieciowa, która musi mieć zapewnioną regularną możliwość transferu danych, ponieważ inaczej dane te przepadną. Procesor ma RAM i licznik instrukcji, dlatego on może wstrzymać się z transferem danych. 