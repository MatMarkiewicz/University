# SyK Lista C

## Zadanie 1 (SO L11Z1)
Zdefiniuj zjawisko **zakleszczenia** (ang. deadlock), **uwięzienia** (ang. livelock) i **głodzenia** (ang. starvation). Rozważmy ruch uliczny – kiedy na skrzyżowaniach może powstać każde z tych zjawisk? Zaproponuj metodę (a) **wykrywania i usuwania** zakleszczeń (b) **zapobiegania** zakleszczeniom. Pokaż, że nieudana próba zapobiegania zakleszczeniom może zakończyć się wystąpieniem zjawiska uwięzienia lub głodzenia.

1. Zakleszczenie występuje, gdy każdy proces czeka na zdarzenie, które może zostać spowodowane wyłącznie przez inny proces. 
![](https://lh3.googleusercontent.com/proxy/MuBS7lCxGv_Hfe4Hcey2Eis32km9l6fMsA48UN99GKEiBN0Hx4uCh5R-Ju4KYlBb4xjmoQ3GoePSex6Ijg0YCjjwzroI1Uk5ylgRJBFh3yM8lWCDDxk5JJH-t6OCop8Q)
2. Uwięzienie to sytuacja, gdy proces nie może zdobyć wszystkich potrzebnych blokad, zwalnia te, które udało mu się zdobyć i próbuje od nowa, ale robi tak kilka procesów na raz i wszystko się zapętla.
![](https://cdn.discordapp.com/attachments/689526193849892867/721304205352108072/unknown.png)
3. Głodzenie występuje, gdy pewien proces czeka na zasób, który nie zostaje mu przydzielony. 
![](https://cdn.discordapp.com/attachments/689526193849892867/721305131890769950/unknown.png)

Wykrywanie i usuwanie: System stara się wykryć, czy wystąpiło zakleszczenie, a jeśli ono wystąpi stara się je usunąć. 
* Wykrywanie
    * każdy typ zasobów ma jedną instację
        Tworzymy graf zasobów i sprawdzamy, czy jest w nim cykl
        ![](https://media.geeksforgeeks.org/wp-content/cdn-uploads/gq/2015/06/deadlock.png)
    * zasoby mogą mieć kilka instacji 
        *  tworzymy 3 macierze:
            * Dostępne - wektor długości m zawierający ile jednostek danego typu zasobu jest dostępne
            * Zaalokowane - macierz nxm oznaczająca ile każdy proces ma zaalokowane instacji danego typu zasoby
            * Żądania - macierz nxm oznaczająca ile każdy proces żąda danego typu zasobu.
        * stosujemy następujący algorytm:
            * Aktywne i Zakończone to wektory długości n i m
            * Aktywne = Dostępne
            * Zakończone[i] = true jeśli i-ty proces nie ma żądań. 
            * Znajdujemy proces i, który żąda (Żądania[i]) mniej zasobów, niż mamy dostępne (Aktywne), ustawiami Zakończone[i] = true oraz do Aktywnych dodajemy Zaalokowane[i]
            * Jeśli nie ma takiego i - kończymy algorytm
            * Jeśli po zakończeniu algorytmu dla pewnego i Zakończone[i] == False, mamy zakleszczenie
    
* Usuwanie
    * Wywaszcamy zakleszczony proces, odbieramy mu na pewien czas zasoby
    * Zabijamy jeden z procesów blokujących niezbędne zasoby
    * Rollback - jeśli występuje zakleszczenie cofamy proces, który blokuje niezbędne zasoby do pewnego zapisanego stanu

Zapobieganie - system stara się nie dopuścić do wystąpienia zakleszczenia
* Ograniczamy ilość blokad na zasobach do niezbędnego minimum
* Proces powinien blokować wszystkie potrzebne mu zasoby przed startem.
* Proces może blokować zasoby tylko, gdy nie blokuje aktualnie innych zasobów
* Proces może blokować tylko jeden zasób jednocześnie
* Numerujemy zasoby, proces może zablokować proces tylko o numerze większym, niż największy numer zasobu, które aktualnie blokuje.

Jeśli proces będzie zwalniać zasoby, w sytuacji, gdy nie może skompletować wszystkich zasób, które potrzebuje może w prosty sposób prowadzić do uwięzienia.
W przypadku niektórych algorytmów zapobiegania zakleszczeniom pewien proces może nie dostawać zasobów, których potrzebuje, co prowadzi do jego głodzenia. 
    

## Zadanie 2 (SO L11Z2)
W poniższym programie występuje **sytuacja wyścigu** (ang. race condition) dotycząca dostępów do współdzielonej zmiennej «tally». Wyznacz jej najmniejszą i największą możliwą wartość.
```=cpp
1 const int n = 50;
2 shared int tally = 0;
3
4 void total() {
5     for (int count = 1; count <= n; count++)
6         tally = tally + 1;
7 }
8
9 void main() { parbegin (total(), total()); }
```
Dyrektywa «parbegin» rozpoczyna współbieżne wykonanie procesów. Maszyna wykonuje instrukcje arytmetyczne wyłącznie na rejestrach – tj. kompilator musi załadować wartość zmiennej «tally» do rejestru, przed wykonaniem dodawania. Jak zmieni się przedział możliwych wartości zmiennej «tally», gdy wystartujemy k procesów zamiast dwóch? Odpowiedź uzasadnij.

Cała operacja wygląda następująco:
1. wczytanie tally do rejestru (read)
2. inkrementacja rejestru (inc)
3. zapisanie rejestru do tally (write)

### Dla k=2
#### MAX

T1 | T2 | | Tally value
--- | --- | --- | ---
read | - | $\leftarrow$ | 0
inc | - | | 0
write | - | $\rightarrow$ | 1
- | read | $\leftarrow$ | 1
- | inc | | 1
- | write | $\rightarrow$ | 2
read | - | $\leftarrow$ | 2
inc | - | | 2
write | - | $\rightarrow$ | 3
- | read | $\leftarrow$ | 3
- | inc | | 3
- | write | $\rightarrow$ | 4
.|.|.|.
.|.|.|.
.|.|.|.
read | - | $\leftarrow$ | 98
inc | - | | 98
write | - | $\rightarrow$ | 99
- | read | $\leftarrow$ | 99
- | inc | | 99
- | write | $\rightarrow$ | 100

#### MIN

T1 | T2 | | Tally value
--- | --- | --- | ---
read | - | $\leftarrow$ | 0
inc | - | | 0
- | read | $\leftarrow$ | 0
- | inc | | 0
- | write | $\rightarrow$ | 1
- | read | $\leftarrow$ | 1
- | inc | | 1
- | write | $\rightarrow$ | 2
.|.|.|.
.|.|.|.
.|.|.|.
- | read | $\leftarrow$ | 48
- | inc | | 48
- | write | $\rightarrow$ | 49
write | - | $\rightarrow$ | 1
read | - | $\leftarrow$ | 1
- | read | $\leftarrow$ | 1
inc | - | | 1
write | - | $\rightarrow$ | 2
.|.|.|.
.|.|.|.
.|.|.|.
read | - | $\leftarrow$ | 49
inc | - | | 49
write | - | $\rightarrow$ | 50
- | inc | | 50
- | write | $\rightarrow$ | 2


### Dla k >= 2
#### MAX

T1    | T2  |     | Tk  |               | Tally value
---   | --- | --- | --- |---            | ---
read  | -   |     | -   | $\leftarrow$  | 0
inc   | -   |     | -   |               | 0
write | -   |     | -   | $\rightarrow$ | 1
-  | read   |     | -   | $\leftarrow$  | 1
-   | inc   |     | -   |               | 1
- | write   |     | -   | $\rightarrow$ | 2
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
-  | -   |     | read  | $\leftarrow$  | k-1
-   | -   |     | inc   |               | k-1
- | -  |     | write   | $\rightarrow$ | k
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
read  | -   |     | -   | $\leftarrow$  | (n-1)k
inc   | -   |     | -   |               | (n-1)k
write | -   |     | -   | $\rightarrow$ | (n-1)k + 1
-  | read   |     | -   | $\leftarrow$  | (n-1)k + 1
-   | inc   |     | -   |               | (n-1)k + 1
- | write   |     | -   | $\rightarrow$ | (n-1)k + 2
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
-  | -   |     | read  | $\leftarrow$  | (n-1)k + k-1
-   | -   |     | inc   |               | (n-1)k + k-1
- | -  |     | write   | $\rightarrow$ | nk

#### MIN

T1    | T2  |     | Tk  |               | Tally value
---   | --- | --- | --- |---            | ---
read  | -   |     | -   | $\leftarrow$  | 0
inc  | -   |     | -   |   | 0
-  | read   |     | -   | $\leftarrow$  | 0
-  | inc   |     | -   |  | 0
-  | write   |     | -   | $\rightarrow$  | 1
-  | read   |     | -   | $\leftarrow$  | 1
-  | inc   |     | -   |  | 1
-  | write   |     | -   | $\rightarrow$  | 2
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
 -  | read   |     | -   | $\leftarrow$  | n-1
-  | inc   |     | -   |   | n-1
-  | write   |     | -   | $\rightarrow$  | n
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
-  |  -  |     | read   | $\leftarrow$  | n*(k-2)
-  | -   |     | inc    |  | n*(k-2)
-  | -  |     | write   | $\rightarrow$  | n*(k-2) + 1
-  | -   |     | read   | $\leftarrow$  | n*(k-2) + 1
-  | -   |     | inc  |  | n*(k-2) + 1
-  | -   |     | write   | $\rightarrow$  | n*(k-2) + 2
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
 -  | -   |     | read   | $\leftarrow$  | n*(k-2) + 48
-  | -  |     | inc  |   | n*(k-2) + 48
-  | -   |     | write   | $\rightarrow$  | n*(k-2) + 49
write  | -   |     | -   | $\rightarrow$  | 1
read  | -   |     | -   | $\leftarrow$  | 1
-  | -   |     | read   | $\leftarrow$  | 1
inc  | -   |     | -   |   | 1
write  | -   |     | -   | $\rightarrow$  | 2
read  | -   |     | -   | $\leftarrow$  | 2
inc  | -   |     | -   |   | 2
write  | -   |     | -   | $\rightarrow$  | 3
.|.|.|.|.|.
.|.|.|.|.|.
.|.|.|.|.|.
read  | -   |     | -   | $\leftarrow$  | n-1
inc  | -   |     | -   |   | n-1
write  | -   |     | -   | $\rightarrow$  | n
-  | -  |     | inc  |   | n
-  | -   |     | write   | $\rightarrow$  | 2


Nie wiem, czy to dobrze jest.

## Zadanie 3 (SO L12Z3)
Przeanalizuj poniższy pseudokod wadliwego rozwiązania problemu producent-konsument. Zakładamy, że kolejka «queue» przechowuje do n elementów. Wszystkie operacje na kolejce są **atomowe** (ang. atomic). Startujemy po jednym wątku wykonującym kod procedury «producer» i «consumer». Procedura «sleep» usypia wołający wątek, a «wakeup» budzi wątek wykonujący daną procedurę. Wskaż przeplot instrukcji, który doprowadzi do:
* (a) błędu wykonania w linii 6 i 13 
* (b) zakleszczenia w liniach 5 i 12.
```=cpp
1 def producer():
2     while True:
3         item = produce()
4         if queue.full():
5             sleep()
6         queue.push(item)
7         if not queue.empty():
8             wakeup(consumer)

9 def consumer():
10     while True:
11         if queue.empty():
12             sleep()
13         item = queue.pop()
14         if not queue.full():
15             wakeup(producer)

16 consume(item)
```
*Wskazówka: Jedna z usterek na którą się natkniesz jest znana jako problem zagubionej pobudki (ang. lost wake-up problem)*

Operacja jest atomowa jeśli obserwator nie może zobaczyć wyników pośrednich.

1. Błędy w liniach 6 i 13
    * błąd w linii 6 (push do pełnej kolejki):
        * konsument sprawdza, że kolejka nie jest pełna (jest prawie pełna)
        * producent dodaje nowy element do kolejki, po czym idzie spać
        * konsument budzi producenta
        * producent próbuje dodać nowy element do pełnej kolejki
    * błąd w linii 13 (pop z pustej kolejki):
        * producent sprawdza, że kolejka nie jest pusta
        * konsument popuje z kolejki ostatni element, po czym idzie spać
        * producent budzi konsumenta
        * konsument wykonuje pop na pustej kolejce

2. Zakleszczenie w liniach 5 i 12
    * konsument sprawdza, że kolejka jest pusta
    * producent produkuje n elementów, za każdym razem budzi konsumenta, który jeszcze nie śpi
    * konsument idzie spać
    * producent idzie spać


## Zadanie 4 (SO L11Z3)
Poniżej znajduje się propozycja6 programowego rozwiązania problemu **wzajemnego wykluczania** dla dwóch procesów. Znajdź kontrprzykład, w którym to rozwiązanie zawodzi. Okazuje się, że nawet recenzenci renomowanego czasopisma „Communications of the ACM” dali się zwieść.
```=cpp
1 shared boolean blocked [2] = { false, false };
2 shared int turn = 0;
3
4 void P (int id) {
5     while (true) {
6         blocked[id] = true;
7         while (turn != id) {
8             while (blocked[1 - id])
9                 continue;
10             turn = id;
11         }
12         /* put code to execute in critical section here */
13         blocked[id] = false;
14     }
15 }
16
17 void main() { parbegin (P(0), P(1)); }
```

## Zadanie 5 (SO L11Z4)
[Algorytm Petersona](https://en.wikipedia.org/wiki/Peterson's_algorithm) rozwiązuje programowo problem wzajemnego wykluczania. Zreferuj poniższą wersję implementacji tego algorytmu dla dwóch procesów. Wykaż jego poprawność.
```=cpp
1 shared boolean flag [2] = { false, false };
2 shared int turn = 0;
3
4 void P (int id) {
5     while (true) {
6         flag[id] = true;
7         turn = 1 - id;
8         while (flag[1 - id] && turn == (1 - id))
9             continue;
10         /* put code to execute in critical section here */
11         flag[id] = false;
12     }
13 }
14
15 void main() { parbegin (P(0), P(1)); }
```
*Ciekawostka: Czasami ten algorytm stosuje się w praktyce dla architektur bez instrukcji atomowych np.: [tegrapenlock](https://elixir.bootlin.com/linux/latest/source/arch/arm/mach-tegra/sleep-tegra20.S).*

## Zadanie 6 (Chyba nie było na SO)
Podaj w pseudokodzie implementację **semafora** z operacjami «init», «down» i «up» używając wyłącznie muteksów i zmiennych warunkowych standardu POSIX.1. Dopuszczamy ujemną wartość semafora.
*Podpowiedź: struct semaphore { pthreadmutext critsec; pthreadcondt waiters; int count; };*

## Zadanie 7 (SO L12Z5)
Poniżej podano jedno z rozwiązań **problemu ucztujących filozofów** Zakładamy, że istnieją tylko leworęczni i praworęczni filozofowie, którzy podnoszą odpowiednio lewą i prawą pałeczkę jako pierwszą.
Pałeczki są ponumerowane zgodnie z ruchem wskazówek zegara. Udowodnij, że jakikolwiek układ n ≥ 5 ucztujących filozofów z co najmniej jednym leworęcznym i praworęcznym zapobiega zakleszczeniom i głodzeniu.
```=cpp
semaphore fork[N] = {1, 1, 1, 1, 1, ...};

1 void righthanded (int i) {
2     while (true) {
3         think();
4         P(fork[(i+1) mod N]);
5         P(fork[i]);
6         eat();
7         V(fork[i]);
8         V(fork[(i+1) mod N]);
9     }
10 }

13 void lefthanded (int i) {
14     while (true) {
15         think();
16         P(fork[i]);
17         P(fork[(i+1) mod N]);
18         eat();
19         V(fork[(i+1) mod N]);
20         V(fork[i]);
21     }
22 }
```

> Pięciu filozofów siedzi przy stole i każdy wykonuje jedną z dwóch czynności – albo je, albo rozmyśla. Stół jest okrągły, przed każdym z nich znajduje się miska ze spaghetti, a pomiędzy każdą sąsiadującą parą filozofów leży widelec, a więc każda osoba ma przy sobie dwie sztuki – po swojej lewej i prawej stronie. Ponieważ jedzenie potrawy jest trudne przy użyciu jednego widelca, zakłada się, że każdy filozof korzysta z dwóch. Dodatkowo nie ma możliwości skorzystania z widelca, który nie znajduje się bezpośrednio przed daną osobą.

Pokażemy, że dla n >= 5 nie będzie zakleszczenia ani głodzenia.


## Zadanie 8 (2pkt) (SO L13Z2)
Rozważmy zasób, do którego dostęp jest możliwy wyłącznie w kodzie otoczonym parą wywołań «acquire» i «release». Chcemy by wymienione operacje miały następujące właściwości:
* mogą być co najwyżej trzy procesy współbieżnie korzystające z zasobu,
* jeśli w danej chwili zasób ma mniej niż trzech użytkowników, to możemy bez opóźnień przydzielić zasób kolejnemu procesowi,
* jednakże, gdy zasób ma już trzech użytkowników, to muszą oni wszyscy zwolnić zasób, zanim zaczniemy dopuszczać do niego kolejne procesy,
* operacja «acquire» wymusza porządek „pierwszy na wejściu, pierwszy na wyjściu” (ang. FIFO).
Podaj co najmniej jeden kontrprzykład wskazujący na to, że poniższe rozwiązanie jest niepoprawne.
>mutex = semaphore(1) # implementuje sekcję krytyczną
>block = semaphore(0) # oczekiwanie na opuszczenie zasobu
>active = 0 # liczba użytkowników zasobu
>waiting = 0 # liczba użytkowników oczekujących na zasób
>must_wait = False # czy kolejni użytkownicy muszą czekać?
```=cpp
1 def acquire():
2 mutex.wait()
3 if must_wait: # czy while coś zmieni?
4 waiting += 1
5 mutex.signal()
6 block.wait()
7 mutex.wait()
8 waiting -= 1
9 active += 1
10 must_wait = (active == 3)
11 mutex.signal()
12 def release():
13 mutex.wait()
14 active -= 1
15 if active == 0:
16 n = min(waiting, 3);
17 while n > 0:
18 block.signal()
19 n -= 1
20 must_wait = False
21 mutex.signal()
```


