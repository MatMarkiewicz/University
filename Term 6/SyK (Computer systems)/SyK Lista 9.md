# SyK lista 9

## **Zadanie 1**
Opisz różnice między **przerwaniem sprzętowym** (ang. hardware interrupt), **błędem** (ang. fault)i **pułapką** (ang. trap). Dla każdego z tych rodzajów **wyjątków** (ang. exceptions) podaj co najmniej trzy przykłady zdarzeń, które je wyzwalają. W jakim scenariuszu błąd nie spowoduje błędu czasu wykonania(przerwania działania) programu?

Przerwanie sprzętowe, błąd i pułapka to typy wyjątków synchronicznych(zależne od przebiegu programu).

Pułapka: zachodzi wtedy, gdy program z sam z siebie wywoołuje instrukcję wyjątku, po to by system operacyjny sam z siebie wykonał jakąś usługę. Przykład: funkcja printf() ma zaszytą pułapkę wywołającą odpowiednią procedurę z tablicy wyjątków. Dodatkowo breakpoints traps, system calls.
![](https://i.imgur.com/Z5txxYL.png)

Błąd: niezamierzony, może ale nie musi kończyć się zakończem programu. Przykład: dzielenie przez zero, błędny dostęp do pamięci, protection fault (kończy działanie programu)
![](https://i.imgur.com/y95OpHn.png)

Przerwanie sprzętowe: niezamierzony błąd, z którego nie można się wycofać - bezwględne zakończenie programu. Przykładem są użycia zabronionych instrukcji, parity error, machine check.
![](https://i.imgur.com/wJcsSlO.png)

![](https://i.imgur.com/CjPhMpm.png)

## **Zadanie 2**
Opisz mechanizm **obsługi przerwań** bazujący na **wektorze przerwań** (ang. interrupt vector table). Co robi procesor przed pobraniem pierwszej instrukcji **procedury obsługi przerwania** (ang. interrupt handler) i po natrafieniu na instrukcję powrotu z przerwania? Dlaczego procedura obsługi przerwania powinna być wykonywana w **trybie nadzorcy** i używać odrębnego stosu?

![](https://i.imgur.com/yaxPHx1.png)
![](https://i.imgur.com/6sVkBo1.png)

Po napotkaniu na wyjątek przechodzimy w tryb nadzorcy, zapamiętujemy kontekst procesora na stosie. Z tablicy wyjątków znajdujemy adres kodu obsługującego dany wyjątek i zaczynamy go wykonywać. Na końcu tego kodu może być powrót do poprzedniej instrukcji / powrót do następnej instrukcji (zapamietaliśmy na stosie gdzie byliśmy przed obsługą wyjątków) lub zakończenie działania. 
Tryb nadzorczy pozwala na wykonywanie wszystkich instrukcji procesora. System operacyjny nie może kontynuować korzystania z pamięci dostępnej dla użytkownika, gdy obsługuje przerwanie, program może być wadliwy, złośliwy lub gorzej. Może w dowolnym momencie zastąpić dowolną część swojej przestrzeni adresowej. Obejmuje to stos. Stos jest często krytyczną częścią wykonywania programu, więc system operacyjny nie ma innego wyjścia, jak przełączyć się na inny stos, którego program trybu użytkownika nie może uszkodzić.


## **Zadanie 3** (ASK Z2L12)
Wzorując się na slajdach do wykładu „Virtual Memory Systems” (strony 10–21) powtórz proces translacji adresów i adresowania pamięci podręcznej dla adresów: 0x027c, 0x03a9 i 0x0040 zakładając poniższy stan TLB, pamięci podręcznej i tablicy stron.

![](https://i.imgur.com/VAB3Jrj.png)
![](https://i.imgur.com/wHGMC1i.png)
![](https://i.imgur.com/Y7K2qBv.png)
a) 0x027c
0000 0010 0111 1100

| TLBT(ag) | TLBI(ndex)| Offset |
| -------- | -------- | -------- |
|   00 0010  |   01  |   11 1100 |
VPN:9 -> PPN:17

| CT(ag) | CI(ndex) | CO(ffset) |
| -------- | -------- | -------- |
| 01 0111 (z PPN)  |  1111   | 00   |
 F ma tag 14 a nie 17 więc nie mamy hita(musimy sprawadzić odpowiednią rzeczy z pamięci)
 
 b) 0x03a9
 0000 0011 1010 1001
| TLBT(ag) | TLBI(ndex)| Offset |
| -------- | -------- | -------- |
|   00 0011  |   10  |   10 1001 |
TLB miss
VPN: 0E -> PPN: 11

| CT(ag) | CI(ndex) | CO(ffset) |
| -------- | -------- | -------- |
|  01 0001 |  1010  | 01  |
A ma tag 2D a my chcemy 0x11, sytuacja taka sama jak w a

c) 0x0040
0000 0000 0100 0000
| TLBT(ag) | TLBI(ndex)| Offset |
| -------- | -------- | -------- |
|   00 0000  |   01  |   00 0000 |
TLB miss
VPN: 01 -> page fault

## **Zadanie 4**  (ASK Z3L12)
W tym zadaniu będziemy analizowali w jaki sposób system operacyjny musi aktualizować **tablicę stron** wraz z kolejnym dostępami do pamięci głównej. Załóż, że strony są wielkości 4KiB, TLB jest **w pełni asocjacyjne** z zastępowaniem LRU. Jeśli potrzebujesz **wtoczyć** (ang. swap-in) stronę z dysku użyj następnego numeru **ramki** (ang. page frame) większego od największego istniejącego w tablicy stron.
Dla poniższych danych podaj ostateczny stan TLB i tablicy stron po wykonaniu wszystkich dostępów do pamięci. Dla każdej operacji dostępu do pamięci wskaż czy było to trafienie w TLB, trafienie w tablicę stron, czy też **błąd strony**.

![](https://i.imgur.com/7yN5F9M.png)

4KiB = 4096B
$2^{\text{page.offset.bits}}=4096 \rightarrow$ VPO na 12 bitach, na największy adres potrzebujemy 16 bitów, więc VPN na 16 - 12 = 4 bitach

| VPN | VPO | TLB hit? | Page hit? | Segfault |
| --- | --- | -------- | --------- | -------- |
| 0001    | 0010 0011 1101    |     nie     |  nie         |    nie, tylko swap-in     |
|  0000   | 1000 1011 0011    |   nie       |     tak      |     nie     |
| 0011    | 0110 0101 1100    |    nie      |      tak     |     nie     |
|  1000   |   0111 0001 1011  |    nie      |       nie    |    nie, tylko swap-in    |
| 1011    |  1110 1110 0110   |   nie       |       tak    |     nie     |
| 0011    |  0001 0100 0000   |     tak     |        nie (tak?)   |    nie      |
|  1100   |  0000 0100 1001   |    nie      |      nie     |     tak    |


| VPN | Valid? | PPN |
| --- | ------ | --- |
| 0   | 1 |   5   |
| 1   | 1 |   13  |
| 2   | 0 | dysk  |
| 3   | 1 |   6   |
| 4   | 1 |   9   |
| 5   | 1 |   11  |
| 6   | 0 |  dysk |
| 7   | 1 |   4   |
| 8   | 1 |  14  |
| 9   | 0 |  dysk |
| 10  | 1 |   3   |
| 11  | 1 |   12  |
| 12  | 0 |   brak  |

| Valid? | Tag  | LRU | PPN |
| ------ | ---  | --- | --- |
|   1    |  8  |  2  |  14 |
|   1    |   3  |  0  |   6 |
|   1    |   0 |  3  |  5 |
|   1    |   11 |  1  |  14 |

## **Zadanie 5**  (ASK Z4L12)
Niech system posługuje się 32-bitowymi adresami wirtualnymi, rozmiar strony ma 4KiB, a rozmiar wpisu tablicy stron zajmuje 4 bajty. Dla procesu, który łącznie używa 1GiB swojej przestrzeni adresowej podaj rozmiar tablicy stron: (a) jednopoziomowej, (b) dwupioziomowej, gdzie katalog tablicy stron (czyli tablica stron pierwszego poziomu) ma 1024 wpisy. Dla drugiego przypadku – jaki jest maksymalny i minimalny rozmiar tablicy stron?

32-bitowe adresy wirtualne -> max adres $2^{32}$
rozmiar strony $4KiB = 2^{12}B$
rozmiar wpisu $4=2^{2}B$ bajty
przestrzeń adresowa 1GiB = $2^{30}B$ = $1024^{3}B$
a) $\frac{2^{32}*2^{2}}{2^{12}}=2^{22}B = 4MB$
b) 12 bitów na offset -> na pierwszą i drugą tablicę jest po 10 bitów
$\frac{2^{30}}{2^{10}*2^{12}}= 2^{8}$ tablic II poziomu
minimalny rozmiar tablicy stron:
poziom II: $2^{8}*2^{10}*2^{2} = 2^{20}B = 1 MiB$
poziom I: $2^{10}*2^{2} = 2^{12} = 4 KiB$
1MiB + 4 KiB
maksymalny rozmiar tablicy stron:
wszystkie tablice w drugim poziomie są używane
poziom II: $2^{10}*2^{10}*2^{2} = 2^{22}B = 4 MiB$
poziom I: $2^{10}*2^{2} = 2^{12} = 4 KiB$
4MiB + 4 KiB

## **Zadanie 6** 
Zdefiniuj format czteropoziomowej tablicy stron zaimplementowany w procesorach architektury x86-64. W jaki sposób tłumaczone są adresy wirtualne na fizyczne? Jaką przewagę ma taka taka tablica nad tablicą jednopoziomową? Opisz dokładnie format pola w tablicach każdego poziomu i wyjaśnij znaczenie bitów pomocniczych.

*Wskazówka: Przeczytaj rodział 7.9.1 z podręcznika CSAPP3e. Szczegóły można znaleźć w rodziale 4.5 wolumenu 3 dokumentacji procesorów Intel.*

![](https://i.imgur.com/q3Y3ohD.png)

![](https://i.imgur.com/MCMX6eP.png)

![](https://i.imgur.com/tEgVNzA.png)

Figure 9.23 shows the format of an entry in a level 1, level 2, or level 3 page table. When P = 1 (which is always the case with Linux), the address field contains a 40-bit physical page number (PPN) that points to the beginning of the appropriate page table. Notice that this imposes a 4 KB alignment requirement on page tables.
Figure 9.24 shows the format of an entry in a level 4 page table. When P = 1, the address field contains a 40-bit PPN that points to the base of some page in physical memory. Again, this imposes a 4 KB alignment requirement on physical pages.

![](https://i.imgur.com/OdqpbaW.png)

Figure 9.25 shows how the Core i7 MMU uses the four levels of page tables to translate a virtual address to a physical address. The 36-bit VPN is partitioned into four 9-bit chunks, each of which is used as an offset into a page table. The CR3 register contains the physical address of the L1 page table. VPN1 provides an offset to an L1 PTE, which contains the base address of the L2 page table. VPN2 provides an offset to an L2 PTE, and so on.

## **Zadanie 7**  (ASK Z8L12)
Na wykładzie przyjęliśmy, że translacja adresów jest wykonywana przed dostępem do pamięci podręcznej. Taki schemat określa się mianem pamięci podręcznej **indeksowanej** i **znakowanej adresami fizycznymi** (ang. physically-indexed, physically-tagged). Wyjaśnij jak zrównoleglić dostęp do TLB i pamięci podręcznej, stosując schemat pamięci indeksowanej wirtualnie i znakowanej fizycznie.
Wskazówka: Posłuż się slajdem 34 do wykładu „Virtual Memory: Concepts”, ale wytłumacz to szczegółowo!
![](https://i.imgur.com/pG1puXT.png)

Z mojego zeszytu z ask:
VPN jest tłumaczony na PPN a VPO = PPO, koszystając z faktu, że CI oraz CO pochodzą tylko z PPO możemy wziąć VPO przed tłumaczeniem i w trakcie tłumaczenia odczytać już odpowiedni set z L1 cache i przygotować go do porównywania z CT, czyli z PPN, który w tym samym czasie jest tłumaczony

![](https://i.imgur.com/7PQpxeO.png)