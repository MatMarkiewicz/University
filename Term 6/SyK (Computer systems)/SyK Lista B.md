# SyK Lista B

## Zadani 1
Podaj główne motywacje projektantów systemów operacyjnych do wprowadzenia **procesów** i **wątków**? Wymień główne różnice między nimi – rozważ współdzielone **zasoby**.

> Ze skryptu
> Proces
> * abstrakcja działającego programu
> * w każdym systemie wieloprogramowym procesor szybko przełącza się pomiędzy procesami, poświęcając każdemu z nich po kolei dziesiątki albo setki milisekund. Chociaż w dowolnym momencie procesor realizuje tylko jeden proces, w ciągu sekundy może obsłużyć ich wiele, co daje iluzję współbieżności
>
>Wątek
> * procesy są wykorzystywane do grupowania zasobów, wątki są podmiotami zaplanowanymi do wykonywania przez procesor
> * zawiera licznik programu, który śledzi to, jaka instrukcja będzie wykonywana w następnej kolejności
> * posiada rejestry zawierające jego bieżące robocze zmienne
> * ma do dyspozycji stos zawierający historię działania – po jednej ramce dla każdej procedury, której wykonywanie się rozpoczęło, ale jeszcze nie zakończyło
> * wielowątkowość (wątki) działa tak samo jak wieloprogramowość (procesy) - procesor przełącza się w szybkim tempie pomiędzy wątkami, dając iluzję, że wątki działają równolegle
> * różne wątki procesu nie są tak niezależne, jak rożne procesy – wszystkie posługują się tą samą przestrzenią adresową, więc współdzielą te same zmienne globalne. Jeden wątek może odczytać, zapisać, a nawet wyczyścić stos innego wątku (nie ma zabezpieczeń).
> * procesy potencjalnie należą do różnych użytkowników i mogą być dla siebie wrogie – proces zawsze należy do jednego użytkownika, który przypuszczalnie stworzył wiele wątków, a zatem powinny współpracować, a nie walczyć ze sobą
> * stany: działający, zablokowany, gotowy, zakończony
>
> Zasoby – wszystko to, co trzeba uzyskać, wykorzystać i zwolnić, np. urządzenia, rekordy danych, pliki itp.
> * zasób z wywłaszczaniem – można odebrać procesowi korzystającemu z niego bez skutków ubocznych, np. pamięć
> * zasób bez możliwości wywłaszczania – nie można go zabrać bieżącemu właścicielowi bez szkody dla obliczeń, np. nagrywarki Blu-ray
> 

Wprowadzenie procesów umożliwia szybkie przełączanie się między nimi, co sprawia wrażenie wykonywania kilku zadań równolegle. Procesy nie współdzielą między sobą zasobów, dzięki temu nie ma ryzyka, że błąd w jednym procesie zakłóci inne procesy. Proces zawalnia swoje zasoby po zakończeniu działania. Stworzenie wątku jest też szybsze.

Wątki to podmioty, które będą wykonywane przez procesor. Posiadają licznik instrukcji, rejestry, stos. Przełączanie się między wątkami również umożliwia iluzję wykonywania wielu rzeczy jednocześnie. Wątki współdzielą jednak przestrzeń adresową, co może być zaletą, np. łatwo jest przekazać dane. 

Dzięki wprowadzeniu wątków i procesów uzyskujemy większą wydajność oraz responsywność. 


## Zadanie 2
Wymień mechanizmy sprzętowe niezbędne do implementacji **wywłaszczania** (ang. preemption). Jak działa **algorytm rotacyjny** (ang. round-robin)? Jakie zadania pełni **planista** (ang. scheduler) i **dyspozytor** (ang. dispatcher)? Który z nich realizuje **politykę**, a który **mechanizm**?

> Ze skryptu
> **planista krótkoterminowy** (ang. short-term) - podejmuje decyzje ponad kilka tysięcy razy na sekundę. Uruchamiany, gdy trzeba przełączyć się na inny wątek (blokada, oczekiwanie na wej.-wyj., wywłaszczenie). Uzupełnia podstawowe statystyki o procesach.
> **planista długoterminowy** (ang. long-term) uruchamiany co najwyżej kilka razy na sekundę. Wykonuje przeliczenie priorytetów na podstawie danych historycznych (loadavg) i różnych heurystyk. Często zintegrowany z planistą krótkoterminowym jako algorytm iteracyjny.
> **dyspozytor** (ang. dispatcher) - to moduł zajmujący się przydziałem czasu procesora dla wątku wybranego przez planistę. Odpowiada za zmianę kontekstu, aktualizuje statystyki – liczbę zmian kontekstu, czas wykonywania.
> 
>polityka – zestaw reguł, które system ma przestrzegać, np. polityka zamykania drzwi. Pytanie: jak zaaranżować elementy?
>mechanizm – praktyczna realizacja polityki, np. instalowanie zamków w drzwiach i otwieranie ich kluczem. Pytanie: jak można użyć elementów?

Wywłaszczenie polega na przerwaniu aktualnie wykonywanego zadania (proces/wątek), aby umożliwić działanie innemu. Aby wywłaszenie były możliwe potrzebyjemy mechanizmu umożliwiającego odmierzenie czasu, wybieranie następnego procesu do wykonywania oraz przydzielania czasu procesora wraz ze zmiana kontekstu.

Algorytm rotacyjny jest odpowiedzialny za odmierzanie równych odstępach czasu, co umożliwia zarządzanie czasem korzystania w procesora. Algorytm ten nie uwzględnia priorytetów procesów, przydziela każdemu równy czas, robiąc to w kółko.

Planista jest odpowiedzialny za wybieranie następnego procesu (kolejności procesów), który będzie wykonywany. 

Dyspozytor daje kontrolę CPU procesowi wybranemu przez planistę. Jest odpowiedzialny za przełączanie kontekstu.

Planista reazlizuje politykę, a dyspozytor mechzanizm.


## Zadanie 3 P
Do czego służy system plików proc(http://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/proc.html) w systemie Linux? Znajdź identyfikator PID jednego ze swoich procesów, po czym wydrukuj zawartość katalogu /proc/PID. Wyświetl plik zawierający **argumenty wywołania**, **zmienne środowiskowe** i opis przestrzeni adresowej badanego procesu (maps). Wyjaśnij znaczenie kolumn (man proc) i wskaż, gdzie znajduje się sterta, stos, segment text, data oraz bss oraz procedury dynamicznego konsolidatora

system plików proc - wirtualny system plików, pseudo-system informacji o procesie. Nie zawiera „prawdziwych” plików, ale informacje o systemie uruchomieniowym(??? runtime system) (np. pamięć systemowa, podłączone urządzenia, konfiguracja sprzętu itp.). Z tego powodu można go traktować jako centrum kontroli i informacji dla jądra. W rzeczywistości całkiem sporo narzędzi systemowych to po prostu wywołania plików w tym katalogu.
Przykłady: „lsmod” = „cat / proc / modules”
„lspci” = „cat / proc / pci” 
Zmieniając pliki znajdujące się w tym katalogu, można nawet czytać / zmieniać parametry jądra (sysctl) podczas działania systemu.


> /proc is very special in that it is also a virtual filesystem. It's sometimes referred to as a process information pseudo-file system. It doesn't contain 'real' files but runtime system information (e.g. system memory, devices mounted, hardware configuration, etc). For this reason it can be regarded as a control and information centre for the kernel. In fact, quite a lot of system utilities are simply calls to files in this directory. For example, 'lsmod' is the same as 'cat /proc/modules' while 'lspci' is a synonym for 'cat /proc/pci'. By altering files located in this directory you can even read/change kernel parameters (sysctl) while the system is running.


![](https://cdn.discordapp.com/attachments/689526193849892867/718849004133154837/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/718850730777378832/unknown.png)

text - /bin/sleep z r-xp
data - /bin/sleep z rw-p
bss - pusta ścieżka

## Zadanie 4
Na podstawie slajdu 25 przedstaw **stany procesu** w systemie Linux. Jakie akcje lub zdarzenia **synchroniczne** i **asynchronicznych** wyzwalają zmianę stanów? Kiedy proces opuszcza stan **zombie**? Wyjaśnij, które przejścia mogą być rezultatem działań podejmowanych przez: jądro systemu operacyjnego, kod sterowników, proces użytkownika albo administratora.

![](https://i.imgur.com/E9Sz7mQ.png)

* Stopped - proces został zatrzymany i może być wznowiony tylko za pomocą akcji z innego procesu, np. proces, który jest debuggowany może mieć ten stan
* Ready - proces jest gotowy do bycia wykonywanym, czeka na wybranie przez planiste
* Executing - proces jest aktualnie wykonywany
* Zombie - proces został zakończony, ale z jakiegoś powodu nadal musi być trzymany na liście procesów
* Interruptible - stan zablokowany, w którym proces czeka na jakiś event, np. operację IO, dostępność zasobów albo sygnał z innego procesu
* Uninterruptible - stan zablokowany, ale w tym przypadku proces czeka bezpośrednio na odpowiednie warunki sprzętowe, stąd nie może być wznowiony przez sygnał.

Proces pozosaje w stanie zombie do póki jego rodzic nie odczyta kod wyjścia tego procesu.

Różne zmiany stanów mogą być wywoływane przez różne sygnały / zdarzenia. Np. przejście ze stanu executing do ready może się odbyć ponieważ proces zostaje zwyczajnie przełączony (wykorzystał wsój aktualny czas, zostanie wznowiony gdy zostanie ponownie wybrany przez planistę). Przejście do stanu zombie możliwe jest tylko przy zakończeniu procesu. Przykładem zdarzenie synchronicznego może być np czekanie na dane, czyli coś, co jest związane z wykonywaniem instrukcji. Przykładem zdarzenia asynchronicznego jest np. otrzymanie sygnału STOP, czyli zdarzenie zewnętrzne.

---

> Z prezentacji
> * synchroniczne → związane z wykonaniem instrukcji
> * asynchroniczne → zdarzenia zewnętrzne: budzik,
przerwanie (CTRL+C), zakończenie procesu potomnego

TODO:
które przejścia mogą być rezultatem działań podejmowanych przez: jądro systemu operacyjnego, kod sterowników, proces użytkownika albo administratora.

## Zadanie 5
Jaką rolę pełnią **sygnały** w systemach uniksowych? W jakich sytuacjach jądro wysyła sygnał procesowi? Kiedy jądro **dostarcza** sygnały do procesu? Co musi zrobić proces by **wysłać sygnał** albo **obsłużyć sygnał**? Których sygnałów nie można **zignorować** i dlaczego? Podaj przykład, w którym obsłużenie sygnału SIGSEGV lub SIGILL może być świadomym zabiegiem programisty.

Sygnały odpowiadają za komunikację pomiędzy procesami, tłumaczenie wyjątków procesora i pułapek, obsługę sytuacji wyjątkowych (a raczej o informowaniu o nich) oraz umożliwiają zarządzanie procesami. Jądro może wysłać procesowi sygnał zabicia, lub zatrzymania. Jądro sprawdza, czy należy dostarczyć sygnał a) przed wejściem w stan uśpenia, b) po wyjściu ze stanu uśpienia c) przed powrotem do przestrzeni użytkowanika. 
Proces może wysłać sygnał do dowolnego innego procesu za pomocą wywołania kill(pid,sygnał), może również wysłać sygnał do samego siebie z pewnym opóźnieniem, lub interwałem odpowiednio za pomocą alarmu / ularamu. Proces może również obsługiwać sygnały, tworząc procedurę obsługi danego sygnału, podając jednocześnie funkcję, która ma być użyta do obsługi tego sygnału.
Nie można ignorować np. sygnału zabicia procesu (bo inaczej byłby nie do zabicia). SIGILL - użytkownik nacisnął DEL, żeby przerwać proces, możemy chcieć wykonać jeszcze jakąś akcję przed przerwaniem (?). SIGSEGV - odniesienie do niepoprawnego adresu pamięci - możemy uruchomić nowy proces, po czym zabić obecny, żeby zadanie nadal było wykonywane, pomimo wystąpienia błędu (?).


## Zadanie 6 P
Uruchom program *«xeyes»* po czym użyj na nim polecenia *«kill»*, *«pkill»* i *«xkill»*. Który sygnał jest wysyłany domyślnie? Przy pomocy kombinacji klawiszy *«CTRL+Z»* wyślij *«xeyes»* sygnał «SIGSTOP», a następnie wznów jego wykonanie. Przeprowadź inspekcję pliku «/proc/PID/status» i **wyświetl maskę** sygnałów zgłoszonych procesowi (ang. pending signals). Pokaż jak będzie się zmieniać, gdy będziemy wysyłać wstrzymanemu procesowi po kolei: *«SIGUSR1»*, *«SIGUSR2»*, *«SIGHUP»* i *«SIGINT»*. Co opisują pozostałe pola pliku *«status»* dotyczące sygnałów? Który sygnał zostanie dostarczony jako pierwszy
po wybudzeniu procesu?

Domyślnie jest wysyłany SIGTERM dla kill i xkill oraz SIGHUP dla pkill.

> The collection of signals that are currently blocked is called the signal mask. Each process has its own signal mask. When you create a new process (see Creating a Process), it inherits its parent’s mask. You can block or unblock signals with total flexibility by modifying the signal mask.

![](https://cdn.discordapp.com/attachments/689526193849892867/718854182374998016/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/718855159551229962/unknown.png)

```=
xeyes 
cat /proc/pid/status
kill -s USR1 pid
cat /proc/pid/status
kill -s USR2 pid
cat /proc/pid/status
kill -1 pid
cat /proc/pid/status
kill -2 pid
cat /proc/pid/status
kill -s CONT pid
```

Przed
![](https://cdn.discordapp.com/attachments/689526193849892867/718860539652210759/unknown.png)

SIGUSR1
![](https://cdn.discordapp.com/attachments/689526193849892867/718860595008372777/unknown.png)

SIGUSR2
![](https://cdn.discordapp.com/attachments/689526193849892867/718860708670079076/unknown.png) 

SIGHUP
![](https://cdn.discordapp.com/attachments/689526193849892867/718860829197467668/unknown.png) 

SIGINT
![](https://cdn.discordapp.com/attachments/689526193849892867/718860940317163590/unknown.png) 

Po wznowieniu
![](https://cdn.discordapp.com/attachments/689526193849892867/718861460310196314/unknown.png)


              * Name: Command run by this process.

              * Umask: Process umask, expressed in octal with a leading
                zero; see umask(2).  (Since Linux 4.7.)

              * State: Current state of the process.  One of "R (running)",
                "S (sleeping)", "D (disk sleep)", "T (stopped)", "T (tracing
                stop)", "Z (zombie)", or "X (dead)".

              * Tgid: Thread group ID (i.e., Process ID).

              * Ngid: NUMA group ID (0 if none; since Linux 3.13).

              * Pid: Thread ID (see gettid(2)).

              * PPid: PID of parent process.

              * TracerPid: PID of process tracing this process (0 if not
                being traced).

              * Uid, Gid: Real, effective, saved set, and filesystem UIDs
                (GIDs).

              * FDSize: Number of file descriptor slots currently allocated.

              * Groups: Supplementary group list.

              * NStgid: Thread group ID (i.e., PID) in each of the PID
                namespaces of which [pid] is a member.  The leftmost entry
                shows the value with respect to the PID namespace of the
                process that mounted this procfs (or the root namespace if
                mounted by the kernel), followed by the value in succes‐
                sively nested inner namespaces.  (Since Linux 4.1.)

              * NSpid: Thread ID in each of the PID namespaces of which
                [pid] is a member.  The fields are ordered as for NStgid.
                (Since Linux 4.1.)

              * NSpgid: Process group ID in each of the PID namespaces of
                which [pid] is a member.  The fields are ordered as for NSt‐
                gid.  (Since Linux 4.1.)

              * NSsid: descendant namespace session ID hierarchy Session ID
                in each of the PID namespaces of which [pid] is a member.
                The fields are ordered as for NStgid.  (Since Linux 4.1.)

              * VmPeak: Peak virtual memory size.

              * VmSize: Virtual memory size.

              * VmLck: Locked memory size (see mlock(2)).

              * VmPin: Pinned memory size (since Linux 3.2).  These are
                pages that can't be moved because something needs to
                directly access physical memory.

              * VmHWM: Peak resident set size ("high water mark").

              * VmRSS: Resident set size.  Note that the value here is the
                sum of RssAnon, RssFile, and RssShmem.

              * RssAnon: Size of resident anonymous memory.  (since Linux
                4.5).

              * RssFile: Size of resident file mappings.  (since Linux 4.5).

              * RssShmem: Size of resident shared memory (includes System V
                shared memory, mappings from tmpfs(5), and shared anonymous
                mappings).  (since Linux 4.5).

              * VmData, VmStk, VmExe: Size of data, stack, and text seg‐
                ments.

              * VmLib: Shared library code size.

              * VmPTE: Page table entries size (since Linux 2.6.10).

              * VmPMD: Size of second-level page tables (added in Linux 4.0;
                removed in Linux 4.15).

              * VmSwap: Swapped-out virtual memory size by anonymous private
                pages; shmem swap usage is not included (since Linux
                2.6.34).

              * HugetlbPages: Size of hugetlb memory portions (since Linux
                4.4).

              * CoreDumping: Contains the value 1 if the process is cur‐
                rently dumping core, and 0 if it is not (since Linux 4.15).
                This information can be used by a monitoring process to
                avoid killing a process that is currently dumping core,
                which could result in a corrupted core dump file.

              * Threads: Number of threads in process containing this
                thread.

              * SigQ: This field contains two slash-separated numbers that
                relate to queued signals for the real user ID of this
                process.  The first of these is the number of currently
                queued signals for this real user ID, and the second is the
                resource limit on the number of queued signals for this
                process (see the description of RLIMIT_SIGPENDING in
                getrlimit(2)).

              * SigPnd, ShdPnd: Mask (expressed in hexadecimal) of signals
                pending for thread and for process as a whole (see
                pthreads(7) and signal(7)).

              * SigBlk, SigIgn, SigCgt: Masks (expressed in hexadecimal)
                indicating signals being blocked, ignored, and caught (see
                signal(7)).

              * CapInh, CapPrm, CapEff: Masks (expressed in hexadecimal) of
                capabilities enabled in inheritable, permitted, and effec‐
                tive sets (see capabilities(7)).

              * CapBnd: Capability bounding set, expressed in hexadecimal
                (since Linux 2.6.26, see capabilities(7)).

              * CapAmb: Ambient capability set, expressed in hexadecimal
                (since Linux 4.3, see capabilities(7)).

              * NoNewPrivs: Value of the no_new_privs bit (since Linux 4.10,
                see prctl(2)).

              * Seccomp: Seccomp mode of the process (since Linux 3.8, see
                seccomp(2)).  0 means SECCOMP_MODE_DISABLED; 1 means SEC‐
                COMP_MODE_STRICT; 2 means SECCOMP_MODE_FILTER.  This field
                is provided only if the kernel was built with the CON‐
                FIG_SECCOMP kernel configuration option enabled.

              * Speculation_Store_Bypass: Speculation flaw mitigation state
                (since Linux 4.17, see prctl(2)).

              * Cpus_allowed: Hexadecimal mask of CPUs on which this process
                may run (since Linux 2.6.24, see cpuset(7)).

              * Cpus_allowed_list: Same as previous, but in "list format"
                (since Linux 2.6.26, see cpuset(7)).

              * Mems_allowed: Mask of memory nodes allowed to this process
                (since Linux 2.6.24, see cpuset(7)).

              * Mems_allowed_list: Same as previous, but in "list format"
                (since Linux 2.6.26, see cpuset(7)).

              * voluntary_ctxt_switches, nonvoluntary_ctxt_switches: Number
                of voluntary and involuntary context switches (since Linux
                2.6.23).




## Zadanie 7 P
Wbudowanym poleceniem powłoki «time» zmierz **czas wykonania** długo działającego procesu, np. polecenia «find /usr». Czemu suma czasów user i sys (a) nie jest równa real (b) może być większa od real? Poleceniem «ulimit» nałóż **ograniczenie** na **czas wykonania** procesów potomnych powłoki tak, by limit się wyczerpał. Uruchom ponownie wybrany program – który sygnał wysłano do procesu?

* real to czas jaki minął od początku do końca wykonywania, wlicza się w niego czas w którym proces oczekuje na bycie wykonywanym
* user - czas wykorzystania CPU jako user-mode
* sys - czas wykorzystania CPU po stronie jądra

user + sys != real, ponieważ do user i sys nie wliczamy czas oczekiwania na bycie wykonywanym

user + sys > real, gdy proces jest wykonywany na kilku jednostkach obliczeniowych na raz

```
time find /usr
ulimit -a
ulimit -t 1
ulimit -a
time find /usr (time find /*)
echo $?
kill -l 137
```

![](https://cdn.discordapp.com/attachments/689526193849892867/718862205617176617/unknown.png)

![](https://cdn.discordapp.com/attachments/689526193849892867/718864120895635467/unknown.png)

## Zadanie 8 P
Zaprezentuj sytuację, w której proces zostanie **osierocony**. W terminalu uruchom dodatkową kopię powłoki bash. Z jej poziomu wystartuj w tle8 program xclock i sprawdź, kto jest jego rodzicem. Poleceniem kill wyślij sygnał SIGKILL do uruchomionej wcześniej powłoki i sprawdź, kto stał się nowym rodzicem procesu xclock. Wyjaśnij przebieg i wyniki powyższego eksperymentu. Co się stanie, gdy zamiast SIGKILL wyślemy powłoce sygnał SIGHUP?

## Zadanie 9 P
Wyświetl wykaz uruchomionych procesów wraz z ich **priorytetem** oraz wartością nice. Poleceniem renice spróbujemy wpłynąć na decyzje planisty zadań. Celem wygenerowania sztucznego obciążenia procesora uruchom polecenie echo "" | awk ’{for(;;) {}}’ w kilku terminalach jednocześnie. Wystartuj przeglądarkę firefox i z użyciem renice zmniejsz jej priorytet. Jak zmienił się **czas reakcji procesu**? Czy możesz przywrócić wartość nice do poprzedniego stanu?
![](https://i.imgur.com/BrkLKWL.png)

nice - od -20 do 19 (20 najwyższy priorytet, 19 najniższy, 0 domyślny)
priorytet - od 1 do 99(domyślne wartości), 100-139 dla przestrzeni użytkownika 

![](https://i.imgur.com/J1dn03g.png)


https://www.tecmint.com/set-linux-process-priority-using-nice-and-renice-commands/

![](https://i.imgur.com/bOu1ng8.png)

![](https://i.imgur.com/0qIVxGN.png)

![](https://i.imgur.com/KMMMa0c.png)

no mogę wrócić do starej wartości nice:
![](https://i.imgur.com/5zeYUXn.png)

---

```
ps -eo pid,ni,pri,comm
echo "" | awk ’{for(;;) {}}’
ps renice -n -20 -p pid
ps renice -n 19 -p pid
ps renice -n 0 -p pid
```

![](https://cdn.discordapp.com/attachments/689526193849892867/719507121414209596/unknown.png)

---
