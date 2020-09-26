# SyK, lista A
## **Zadanie 1 SO L1Z1**
Wyjaśnij różnice między **powłoką** (ang. shell), **system operacyjnym** i **jądrem systemu operacyjnego** (ang. kernel). W tym celu dobierz kilka przykładów powszechnie wykorzystywanego oprogramowania. Jakie są główne zadania systemu operacyjnego z punktu widzenia programisty?

Kernel to część systemu operacyjnego, która działa w trybie uprzywilejowanym. Jest odpowiedzialny m.in za komunikację z hardwarem, obsługą I/O. przykładami kerneli są: Solaris, Windows NT, Linux Kernel, FreeBSD

>Ze skryptu:
>jądro systemu operacyjnego (kernel)
>* znajduje się bezpośrednio nad warstwą sprzętową
>* udostępnia interfejs do korzystania z hardware w postaci wywołań systemowych – syscalli (wywołania te mogą być wołane z poziomu usera, kiedy wymagane są działania w kernel mode – dostęp do wszystkich zasobów)
>* dostarcza środowiska uruchomieniowego dla programów


Shell to program, który umożliwia komunikację użytkownika z kernelem. Pozwala na wykonywanie m.in. komend, które wpisujemy w terminalu oraz skryptów. Dawniej był to jedyny sposób na komunikację człowieka z komputerem. Przykładami shellów są bash, zsh, Windows shell

>Ze skryptu:
>powłoka - interpreter poleceń użytkownika kierowanych do kernela
>* jest podstawowym interfejsem pomiędzy userem a sysopkiem
>* powłoka, bo jest nakładką na kernel
>* nie jest częścią systemu operacyjnego
>* powłoka wykorzystuje emulator terminala jako std IO
>* przykłady powłok linuksowych: sh shell i bash shell (domyślna powłoka w niektórych dystrybucjach linuksa)
>* dwa rodzaje:
>    * powłoka tekstowa - interpreter poleceń uruchamiany w trybie tekstowym, potocznie zwany konsolą
>    * powłoka graficzna - ma zwykle postać menadżera plików, kontrolowana za pomocą myszy. Eksplorator – domyślna powłoka systemu MS Windows

System operacyjny jest częścią softwaru odpowiedzialną za zarządzanie hardwarem. Jego najważniejszymi zadaniami są kontola zasobów i ich sprawiedliwe udostępnianie, dostarczenie środowiska uruchomieniowego dla programistów oraz nadzoruje wykonanie programów. Przykładami systemów są: Windows, Linux, MacOS

>Ze skryptu:
>system operacyjny - oprogramowanie działające w trybie jądra
>SO spełniają dwie niepowiązane ze sobą funkcje:
>* dostarczają programistom aplikacji (i programom aplikacyjnym) czytelnego, abstrakcyjnego zbioru zasobów będących odpowiednikami sprzętu
>* zarządzają tymi zasobami sprzętowymi>
>    * pamięć (fizyczna, tablica stron)
>    * procesor (translacja adresów, przerwania, cache, TLB)
>    * urządzenia IO
>    * kanały DMA
>
>Jakie są główne zadania systemu operacyjnego z punktu widzenia programisty?
>* zarządza pamięcią (przydzielanie jej, ochrona dostępu do jej fragmentów, pamięć wirtualna)
>* zapewnia ładną abstrakcję zasobów i zarządza nimi efektywnie
>* zapewnia interakcję z userem

## **Zadanie 2 SO L1Z2**
Czym jest **zadanie** w **systemach wsadowych**? Jaką rolę pełni **monitor**? Na czym polega **planowanie zadań**? Zapoznaj się z rozdziałem „System Supervisor” dokumentu IBM 7090/7094 IBSYS Operating System. Wyjaśnij pobieżnie znaczenie poleceń **języka kontroli zadań** (ang. Job Control Language) użytych na rysunku 3 na stronie 13. Do jakich zastosowań używa się dziś systemów wsadowych?
Wskazówka: Bardzo popularnym systemem realizującym szeregowanie zadań wsadowych jest SLURM.

Pierwsze systemy wsadowe wykorzystywały 3 komutery, pierwszy z nich czytał karty oraz zapisywał odczytane zadania na taśmy magnetyczne, następnie drugi, większy był odpowiedzialny za obliczenia, których wynik był ponownie zapisany na taśmy magnetyczne. Ostatni z komputerów był odpowiedzialny za odczytanie wyniku z taśm i wypisane go za pomocą drukarki. 

![](https://i.imgur.com/rJboExQ.png)

Główna idea polega na pobraniu zbioru zadań do wykonania wraz z ich danymi wejściowymi. Zadania wykonywane są jeden po drugim w pewnej kolejności.

Zadaniem nazywamy program, bądź zbiór programów, które mają zostać wykonane.

Monitor pełnił rolę prymitywnego systemu operacyjnego. Odczytywał on kolejne zadania z taśmy wejściowej, a następnie je uruchamiał. Dzięki temu człowiek nie musiał obsługiwać każdego z tych programów osobno. Posiadał on m.in. ochronę pamięci oraz czasomierz.

Planowanie zadań to ustalenie kolejności w której zadania powinny być wykonywane. Początkowo stosowane było FIFO, z czasem wprowadzono inne rozwiązania, np. bazujące na priorytetach zadań. 

![](https://i.imgur.com/keKjKoR.png)

Język kontroli zadań to prymitywny język, który interpretował monitor

Niektóre z poleceń:
* JOB - początek nowego zadania
* IBSYS - System supervisor, przekazanie kontrolii do systemu
* RELEASE - zwolenie jednoski z jej obecnej funkcji
* EXECUTE - precyzuje, który podsystem na wykonać następne części zadania
* STOP - koniec zadań
* FORTRAN - załadowanie kompilatora języka fortran

Obecnie systemy wsadowe stosuje się tam, gdzie chcemy zautmatyzować wykonanie pewnego ciągu programów. Przykładem jest SLURM (Simple Linux Utiliy for Resource Management) - system kolejkowy który obsługuje obliczenia naukowe na superkomputerach. 

>Ze skryptu:
>Czym jest zadanie w systemach wsadowych? Jaką rolę pełni monitor? Na czym polega planowanie zadań?
>
>**zadanie** - program lub zbiór programów, który dla danych wejściowych produkował dane wyjściowe (rozp. Od karty $JOB)
>
>**system wsadowy** – idea ich działania polegała na pobraniu pełnego zasobnika zadań w pokoju wprowadzania danych i zapisaniu ich na taśmie magnetycznej za pomocą mniejszego komputera (IBM 1401 czytał karty, kopiował taśmy i drukował wyniki, ale nie nadawał się do obliczeń). Do obliczeń wykorzystywano większe i droższe komputery, np. IBM 7094.
>
>**monitor** – protoplasta systemu operacyjnego; odczytywał kolejne zadania z taśmy wejściowej (interpretował control language) i je uruchamiał (eliminowało to konieczność obsługi pojedynczych programów przez człowieka). W monitorze były sterowniki, IO, zegar systemowy, ochrona pamięci.
>
>**planowanie zadań** – ustalanie kolejności wykonywanych zadań. Na początku do komputera wrzucało się „paczkę z zadaniami”, a jego planowanie to było zwykłe FIFO. Potem wprowadzono sortowanie np. na podstawie priorytetów zapisanych w JCL.
>
>Wyjaśnij znaczenie poleceń języka kontroli zadań
>
>**język kontroli zadań** – prymitywny język poleceń dla monitora opisujący zadanie
>* $JOB - nowe zadanie, określa czas działania w minutach
>* $FORTRAN – załadowanie kompilatora języka Fortran z taśmy systemowej, bezpośrednio za nią następował program do skompilowania
>* $LOAD - załaduj kod z taśmy
>* $RUN - uruchom program
>* $END - zakończ zadanie
>* $IBSYS - System Supervisor jest wołany do pamięci rdzenia (core storage) i otrzymuje kontrolę
>* $RELEASE – causes the unit assigned to the specified system unit function to be released from the function
>* $IBEDT – System Supervisor woła System Editor do core storage z System Library Unit i przekazuje mu kontrolę
>* $EXECUTE – precyzuje, który subsystem ma przeczytać i zinterpretować następne karty (po karcie execute)
>* $STOP - określa koniec stosu zadań
>
>Do jakich zastosowań używa się dziś systemów wsadowych?
>
>Wiele dzisiejszych systemów wsadowych automatyzuje zadania, dzięki czemu interakcja z człowiekiem nie jest wymagana, chyba że coś pójdzie nie tak. Przykłady:
>* payroll system: systemy wsadowe są idealne do tworzenia listy płac pracowników, wykonywanie obliczeń potrzebnych do wypłat pracownikom
>* zarzadzanie ogromnymi bazami danych (np. w systemach rezerwacji miejsc lotniczych)
>* w bankach transakcje o danej godzinie – są zbierane te wsady transakcji
>* SLURM (dawniej Simple Linux Utiliy for Resource Management) to system kolejkowy (resource manager, job scheduler) działający np. na maszynach w ICM (centrum obliczeniowe UW) służących do obliczeń naukowych na komputerach dużej mocy
>
>**wieloprogramowe systemy wsadowe** – rozwiązanie polegające na podzieleniu pamięci na kilka części i umieszczeniu w każdej z nich osobnego zadania. Podczas gdy jedno zadanie oczekiwało na zakończenie operacji IO, drugie mogło korzystać z procesora
>
>**systemy z podziałem czasu** – odmiana systemów wieloprogramowych, w których każdy użytkownik posiadał podłączony do komputera terminal, który zapewniał użytkownikom interaktywną obsługę komputera. Podobnie jak system wieloprogramowy system ten może wykonywać wiele zadań jednocześnie. Istotną różnica między tymi systemami jest to, że system z podziałem czasu nie czeka na przestój jakiegoś programu, aby uruchomić inny, ale uruchamia wiele zadań jednocześnie. My - użytkownicy - mamy wrażenie, że zadania te wykonują się jednocześnie, ale jest to tylko nasze złudzenie. Tak naprawdę procesor przełącza się pomiędzy poszczególnymi zadaniami, ale przełączenia te następują tak szybko, że użytkownicy mogą na bieżąco współpracować z wszystkimi zadaniami w trybie rzeczywistym.
>
>**system interaktywny** – pozwala wpływać użytkownikowi na SO podczas pracy innego programu

## **Zadanie 3 SO L1Z5**
Jaka była motywacja do wprowadzenia **wieloprogramowych** systemów wsadowych? W jaki sposób wieloprogramowe systemy wsadowe wyewoluowały w systemy z **podziałem czasu** (ang. time-sharing)? Podaj przykład historycznego systemu **interaktywnego**, który nie jest wieloprogramowy.

Wieloprogramowe systemy wsadowe zostały wprowadzone, by lepiej wykorzystywać komputer. Pozwalały one na przejście do wykonywania innego programu w czasie, gdy poprzedni program czekał np. na zakończenie operacji I/O.

Takie podejście z czasem wyewoluowało do systemów z podziałem czasu. System nadal przełączał się pomiędzy zadaniami, ale nie działo się to tylko w przypadku, gdy jedeno z zadań oczekiwało na zakończenie pewnych operacji, tylko działo się to regularnie, co określony czas. Dzięki temu wielu programistów mogło mieć własne terminale i uruchamiać swoje programy, mając wrażenie, że ich program działa w tym samym czasie, co program drugiej osoby. 

System interaktywny to taki, który pozwala wpływać użytkownikowi na system operacyjny w czasie pracy innego programu. 
Przykładem systemu interaktywnego, który nie jest wieloprogramowy jest np. MS DOS.


## **Zadanie 4 \(P\) SO L1Z6**
Uruchom program «1_ls» pod kontrolą narzędzia «ltrace -S». Na podstawie śladu wykonania programu zidentyfikuj, które z **wywołań systemowych** są używane przez procedury: «opendir», «readdir», «printf» i «closedir». Do czego służy wywołanie systemowe «brk»? Używając debuggera «gdb» i polecenia «catch syscall brk» zidentyfikuj, która funkcja używa «brk».

>Ze skryptu
>wywołanie systemowe:
>* mechanizm wydawania wywołań systemowych jest w dużym stopniu zależny od maszyny i często musi być wyrażony w kodzie asemblera. Z tego powodu trzeba korzystać z biblioteki procedur, co pozwala na wydawanie wywsysów z poziomu programów w języku C
>* każdy komputer z pojedynczym procesorem jest zdolny do uruchamiania tylko jednej instrukcji naraz. Co się dzieje, gdy proces uruchamia program użytkownika w user mode i wymaga usługi systemowej (np. czytania danych z pliku):
>    * wykonanie rozkazu pułapki w celu przekazania sterowania do sysopka
>    * sysopek dowiaduje się, czego chce proces wywołujący poprzez inspekcję parametrów
>    * sysopek realizuje wywołane systemowe i zwraca sterowanie do następnej instrukcji za wywsysem


Lista poleceń:
```
ltrace -S ./1_ls *nazwa_katalogu*

gdb ./1_ls
 > catch syscall brk
 > run *nazwa_katalogu*
 > c
```

Przebieg wywołań:
![](https://cdn.discordapp.com/attachments/689526193849892867/715947534085914695/unknown.png)

* «opendir» -> SYS_openat
* «readdir» -> SYS_getdents
* «printf» -> SYS_write
* «closedir» -> SYS_close


>brk() and sbrk() change the location of the program break, which defines the end of the process's data segment.

Brk używa się do allokowania i deallokowania pamięci dla procesu.

![](https://cdn.discordapp.com/attachments/689526193849892867/715953187378692206/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/715953822316363776/unknown.png)

SYS_brk jest używany przez start (który jest wykonywany przed main) oraz opendir.


## **Zadanie 5 \(P\) SO L1Z7**
Pod kontrolą narzędzia «strace» uruchom program «2_cat» korzystający bezpośrednio z wywołań systemowych do interakcji ze **standardowym wejściem i wyjściem**. Pokaż, że program oczekuje na odczyt na **deskryptorze pliku** 0 i pisze do deskryptora 1. Naciśnij kombinację klawiszy «CTRL+D» kończąc wejściowy strumień danych – co zwróciło «read»? Zmodyfikuj program tak, by czytał z pliku podanego w linii poleceń. Co się stanie, jeśli przekażesz **ścieżkę** do katalogu zamiast do pliku regularnego?

Standardowe wejście i wyjście to standardowe kanały komunikacji między programem i otoczeniem. 
Deskryptor to liczba identyfikująca plik. Standardowe wejście ma deskryptor równy 0, a standardowe wyjście ma deskryptor równe 1.
Ścieżka pliku określa lokalizację pliku w systemie plików.

Lista poleceń:
```
strace ./2_cat

ctr+D

make
./2_cat *nazwa_pliku*
./2_cat *nazwa_katalogu*
```

![](https://cdn.discordapp.com/attachments/689526193849892867/715956803858464831/unknown.png)

Widzimy wszystkie wywołania systemowe aż do napotkania reada. Jest to read(0,...), więc próbuje przeczytać coś ze standardowego wejścia. Jeśli podamy mu ciąg znaków i zakończymy go enterem program przejdzie dalej, wypisując m.in. to co mu podaliśmy na standardowe wyjście.

![](https://cdn.discordapp.com/attachments/689526193849892867/715957788160950332/unknown.png)

Wartości, które zwraca read to ilość bajtów, które udało mu się odczytać. Po naciśnięciu ctr+D (EOF) read zwraca 0, program kończy działanie.

Oryginalne program:
```cpp=
#include "apue.h"

#define BUFFSIZE 4096

int main(void) {
  int n;
  char buf[BUFFSIZE];

  while ((n = read(STDIN_FILENO, buf, BUFFSIZE)) > 0)
    if (write(STDOUT_FILENO, buf, n) != n)
      err_sys("write error");

  if (n < 0)
    err_sys("read error");

  exit(0);
}
```

Modyfikacja programu:
```cpp=
#include "apue.h"

#define BUFFSIZE 4096
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[]) {
  int n;
  char buf[BUFFSIZE];

  if (argc != 2)
    err_quit("usage: ls directory_name");

  int fd = open(argv[1], O_RDONLY);

  while ((n = read(fd, buf, BUFFSIZE)) > 0)
    if (write(STDOUT_FILENO, buf, n) != n)
      err_sys("write error");


  if (n < 0)
    err_sys("read error");

  exit(0);
}
```

Po modyfikacji program odczytuje plik, wypisując jego zawartość na standardowe wyjście. Jeśli podamy mu katalog, zwróci błąd.

## **Zadanie 6 \(P\) SO L2Z1**
W systemach uniksowych wszystkie procesy są związane relacją **rodzic-dziecko**. Uruchom polecenie «ps -eo user,pid,ppid,pgid,tid,pri,stat,wchan,cmd». Na wydruku zidentyfikuj **identyfikator procesu**, **identyfikator grupy procesów**, **identyfikator rodzica** oraz **właściciela** procesu. Kto jest rodzicem procesu init? Wskaż, które z wyświetlonych zadań są **wątkami jądra**. Jakie jest znaczenie poszczególnych znaków w kolumnie STAT? Wyświetl drzewiastą reprezentację **hierarchii procesów** poleceniem pstree – które z zadań są wątkami?

relacja rodzic-dziecko - proces rodzic tworzy nowy uruchomiony proces - dziecko poprzez forka(proces dziecko staje się duplikatem rodzica)
![](https://i.imgur.com/VUFBzr3.png)

po polsku xd
![](https://i.imgur.com/yoTULPO.png)

w skrócie: fork robi kopie bieżącego procesu

- identyfikator procesu - PID
identyfikator danego procesu, używany do jego identyfikacji, co ważne w tym samym czasie PID nie może być przydzielony dwóm różnym procesom
- identyfikator grupy procesów - PGID
Grupa procesów jest to taki zbiór procesów, który posiada jednakowy parametr PGID. Standardowo PGID jest dziedziczony z procesu macierzystego ale funkcja setpgrp może go ustawić na PID procesu bieżącego. 
- identyfikator rodzica, PID procesu macierzystego - PPID
- właściciel - USER


![](https://i.imgur.com/GbFdiNf.png)

wątki jądra - (to te w nawiasach kwadratowych)
W niektórych systemach operacyjnych wyróżnia się zarówno wątki trybu użytkownika, jak i **wątki trybu jądra**. W systemie Solaris terminem wątek określa się wątek, istniejący w trybie użytkownika, a wątek trybu jądra określa się jako lekki proces. W systemie Windows wprowadza się pojecie włókna , zwanego też lekkim wątkiem (ang. fiber, lightweight thread), które odpowiada wątkowi trybu użytkownika, podczas gdy termin wątek odnosi się do wątku trybu jądra. Takie rozróżnienie umożliwia operowanie pewną liczbą wątków trybu jądra, a w ramach realizowanych przez te wątki programów może następować przełączanie pomiędzy różnymi wątkami trybu użytkownika bez wiedzy jądra systemu. Wątek trybu jądra można więc traktować jako wirtualny procesor dla wątku trybu użytkownika.

W systemie Linux wszelkie aktywności wykonywane są przez procesy, które operują na pamięci operacyjnej, plikach i urządzeniach. Procesy tworzą drzewo którego korzeniem jest proces **init**. Proces ten tworzony jest przy starcie systemu. Czyta on pliki konfiguracyjne ( zawarte w pliku /etc/init.d ) i uruchamia dalsze procesy. Init ma PID równe 1. Rodzicem inita jest jądro (PID 0).

Z man ps:
![](https://i.imgur.com/7ivQQFj.png)
te ważne:
STAT – status procesu. Oznaczenia statusu procesu:
- R – proces jest aktualnie wykonywany (running),
- S – proces uśpiony, oczekiwanie na jego uruchomienie (sleep),
- T – proces zatrzymany (stopped, np. CTRL-Z)
- Z – zombie process - proces niewłaściwie zamknięty przez proces nadrzędny (proces rodzica bądź proces macieżysty)

hierarchia procesów - procesy tworzą więc hierarchię która może być przedstawiona jako drzewo
![](https://i.imgur.com/1J0sMfR.png)

Wątki to te w wasiąstych nawiasach.
![](https://i.imgur.com/ySmsuNg.png)

---
Lista poleceń:
```
ps -eo user,pid,ppid,pgid,tid,pri,stat,wchan,cmd
man ps
pstree
man pstree
```

![](https://cdn.discordapp.com/attachments/689526193849892867/716232771399319642/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/716234887853637652/unknown.png)


## **Zadanie 7 \(P\) SO L2Z3**
Znajdź pid procesu X-serwera, a następnie używając polecenia «pmap» wyświetl zawartość jego przestrzeni adresowej. Zidentyfikuj w niej poszczególne zasoby pamięciowe – tj. stos, stertę, **segmenty programu**, **pamięć anonimową**, **pliki odwzorowane w pamięć**. Należy wyjaśnić znaczenie kolumn wydruku!
chodzi o to: https://en.wikipedia.org/wiki/X_Window_System
PID tego procesu: pidof Xorg
![](https://i.imgur.com/s6clebj.png)

![](https://i.imgur.com/D2zwvfZ.png)

![](https://i.imgur.com/kY5xkCB.png)

- stos:
![](https://i.imgur.com/J4OP3hm.png)
- sterta: 
no generalnie powinno być [heap] ale u mnie tego nie było
- segmenty programu:
???
Segment kodu (znany również jako text segment albo po prostu text) – obszar pamięci zawierający kod maszynowy przeznaczony do wykonania przez procesor komputera. Segment kodu może być umieszczony w pamięci operacyjnej komputera poprzez załadowanie fragmentu (sekcji w przypadku formatu pliku ELF) pliku wykonywalnego zawierającego instrukcje maszynowe.
W niektórych architekturach komputerów segment kodu jest przechowywany w obszarze pamięci tylko do odczytu, dzięki czemu w przypadku konieczności usunięcia segmentu kodu z pamięci operacyjnej przez mechanizm pamięci wirtualnej nie ma potrzeby zapisywania zawartości segmentu kodu do pamięci masowej. Przywrócenie segmentu kodu do pamięci operacyjnej następuje przez ponowne pobranie go z pliku wykonywalnego.
Segment kodu zapisany w pamięci tylko do odczytu może być używany przez kilka procesów (np. przez kilka równocześnie wykonywanych kopii tego samego programu lub w formie biblioteki współdzielonej).
- pamięć anonimową: 
![](https://i.imgur.com/gReLRvo.png)
Pamięć dzielona – rodzaj pamięci, z której może jednocześnie korzystać wiele programów. Służy do umożliwienia komunikacji pomiędzy nimi lub uniknięcia redundantnych kopii. W zależności od kontekstu, programy mogą być uruchamiane na pojedynczym lub wielu osobnych procesorach. Pamięć wykorzystywana do komunikacji w obrębie pojedynczego programu, na przykład pomiędzy jego wieloma wątkami, zwykle nie jest nazywana pamięcią dzieloną.

- pliki odwzorowane w pamięć:
![](https://i.imgur.com/V7NyPkP.png)
Plik pamięci odwzorowany jest segmentem pamięci wirtualnej , które zostały przypisane do bezpośredniego bajt dla bajcie korelację z pewnej części pliku lub zasobu plikopodobny. Ten zasób jest zazwyczaj plik, który jest fizycznie obecny na dysku, ale może być również urządzeniem, wspólny przedmiot pamięci lub innych zasobów, że system operacyjny może odwoływać poprzez deskryptor pliku . Po obecne, to korelacja między pliku i miejsca pamięci umożliwia aplikacjom traktować odwzorowaną część jak gdyby był pamięci podstawowej .

--- 

Lista poleceń
```
pidof Xorg
pmap -X *wynik*
```

![](https://cdn.discordapp.com/attachments/689526193849892867/716240778669850684/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/716242589577248808/unknown.png)

## **Zadanie 8 \(P\) SO L2Z4**
Używając programu «lsof» wyświetl **zasoby plikopodobne** podpięte do procesu przeglądarki «firefox». Wyjaśnij znaczenie poszczególnych kolumn wykazu, po czym zidentyfikuj **pliki zwykłe**, **katalogi**, **urządzenia**, **gniazda** (sieciowe lub domeny uniksowej) i **potoki**. Przekieruj wyjście z programu «lsof», przed i po otwarciu wybranej strony, odpowiednio do plików «before» i «after». Czy poleceniem «diff -u before after» jesteś w stanie zidentyfikować nowo utworzone połączenia sieciowe?

zasoby plikopodobne - dekryptory pliku 

pliki zwykłe - regular file is one type of file that may be stored in a file system. It is called "regular" primarily to distinguish it from other special types of files.Most files used directly by a human user are regular files. For example, executable files, text files, and image files are regular files. When data is read from or written to a regular file, the kernel performs that action according to the rules of the filesystem. For instance, writes may be delayed, journaled, or subject to other special operations
![](https://i.imgur.com/oJRXAeK.png)


Lista poleceń
```
lsof -c firefox >> before
*otwieramy stronę*
lsof -c firefox >> after
diff -u before after
diff -u before after | grap IPv4
```

![](https://cdn.discordapp.com/attachments/689526193849892867/716247580266201189/unknown.png)

pliki zwykłe to te z typ reg, katalogi to te z typem dir, urządzenia (pliki urządzeń, reprezentujące sterownik urządzenia) to te z typem CHR, gniazda mają typ socket, ale IPv4 to też rodziaj gniazda, podobnie inet itp, potoki mają typ pipes, ale u siebie widzę tylko fifo special type (A FIFO special file is similar to a pipe, except that it is created in a different way. Instead of being an anonymous communications channel, a FIFO special file is entered into the file system by calling mkfifo)

