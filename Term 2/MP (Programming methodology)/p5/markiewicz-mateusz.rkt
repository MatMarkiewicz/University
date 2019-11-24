#lang racket

;; pomocnicza funkcja dla list tagowanych o określonej długości
(define (tagged-tuple? tag len p)
  (and (list? p)
       (= (length p) len)
       (eq? (car p) tag)))

(define (tagged-list? tag p)
  (and (pair? p)
       (eq? (car p) tag)
       (list? (cdr p))))

;; reprezentacja danych wejściowych (z ćwiczeń)
(define (var? x)
  (symbol? x))

(define (var x)
  x)

(define (var-name x)
  x)

;; przydatne predykaty na zmiennych
(define (var<? x y)
  (symbol<? x y))

(define (var=? x y)
  (eq? x y))

(define (literal? x)
  (and (tagged-tuple? 'literal 3 x)
       (boolean? (cadr x))
       (var? (caddr x))))

(define (literal pol x)
  (list 'literal pol x))

(define (literal-pol x)
  (cadr x))

(define (literal-var x)
  (caddr x))

(define (clause? x)
  (and (tagged-list? 'clause x)
       (andmap literal? (cdr x))))

(define (clause . lits)
  (cons 'clause lits))

(define (clause-lits c)
  (cdr c))

(define (cnf? x)
  (and (tagged-list? 'cnf x)
       (andmap clause? (cdr x))))

(define (cnf . cs)
    (cons 'cnf cs))

(define (cnf-clauses x)
  (cdr x))

;; oblicza wartość formuły w CNF z częściowym wartościowaniem. jeśli zmienna nie jest
;; zwartościowana, literał jest uznawany za fałszywy.
(define (valuate-partial val form)
  (define (val-lit l)
    (let ((r (assoc (literal-var l) val)))
      (cond
       [(not r)  false]
       [(cadr r) (literal-pol l)]
       [else     (not (literal-pol l))])))
  (define (val-clause c)
    (ormap val-lit (clause-lits c)))
  (andmap val-clause (cnf-clauses form)))

;; reprezentacja dowodów sprzeczności

(define (axiom? p)
  (tagged-tuple? 'axiom 2 p))

(define (proof-axiom c)
  (list 'axiom c))

(define (axiom-clause p)
  (cadr p))

(define (res? p)
  (tagged-tuple? 'resolve 4 p))

(define (proof-res x pp pn)
  (list 'resolve x pp pn))

(define (res-var p)
  (cadr p))

(define (res-proof-pos p)
  (caddr p))

(define (res-proof-neg p)
  (cadddr p))

;; sprawdza strukturę, ale nie poprawność dowodu
(define (proof? p)
  (or (and (axiom? p)
           (clause? (axiom-clause p)))
      (and (res? p)
           (var? (res-var p))
           (proof? (res-proof-pos p))
           (proof? (res-proof-neg p)))))

;; procedura sprawdzająca poprawność dowodu
(define (check-proof pf form)
  (define (run-axiom c)
    (displayln (list 'checking 'axiom c))
    (and (member c (cnf-clauses form))
         (clause-lits c)))
  (define (run-res x cpos cneg)
    (displayln (list 'checking 'resolution 'of x 'for cpos 'and cneg))
    (and (findf (lambda (l) (and (literal-pol l)
                                 (eq? x (literal-var l))))
                cpos)
         (findf (lambda (l) (and (not (literal-pol l))
                                 (eq? x (literal-var l))))
                cneg)
         (append (remove* (list (literal true x))  cpos)
                 (remove* (list (literal false x)) cneg))))
  (define (run-proof pf)
    (cond
     [(axiom? pf) (run-axiom (axiom-clause pf))]
     [(res? pf)   (run-res (res-var pf)
                           (run-proof (res-proof-pos pf))
                           (run-proof (res-proof-neg pf)))]
     [else        false]))
  (null? (run-proof pf)))


;; reprezentacja wewnętrzna

;; sprawdza posortowanie w porządku ściśle rosnącym, bez duplikatów
(define (sorted? vs)
  (or (null? vs)
      (null? (cdr vs))
      (and (var<? (car vs) (cadr vs))
           (sorted? (cdr vs)))))

(define (sorted-varlist? x)
  (and (list? x)
       (andmap (var? x))
       (sorted? x)))

;; klauzulę reprezentujemy jako parę list — osobno wystąpienia pozytywne i negatywne. Dodatkowo
;; pamiętamy wyprowadzenie tej klauzuli (dowód) i jej rozmiar.
(define (res-clause? x)
  (and (tagged-tuple? 'res-int 5 x)
       (sorted-varlist? (second x))
       (sorted-varlist? (third x))
       (= (fourth x) (+ (length (second x)) (length (third x))))
       (proof? (fifth x))))

(define (res-clause pos neg proof)
  (list 'res-int pos neg (+ (length pos) (length neg)) proof))

(define (res-clause-pos c)
  (second c))

(define (res-clause-neg c)
  (third c))

(define (res-clause-size c)
  (fourth c))

(define (res-clause-proof c)
  (fifth c))

;; przedstawia klauzulę jako parę list zmiennych występujących odpowiednio pozytywnie i negatywnie
(define (print-res-clause c)
  (list (res-clause-pos c) (res-clause-neg c)))

;; sprawdzanie klauzuli sprzecznej
(define (clause-false? c)
  (and (null? (res-clause-pos c))
       (null? (res-clause-neg c))))

;; pomocnicze procedury: scalanie i usuwanie duplikatów z list posortowanych
(define (merge-vars xs ys)
  (cond [(null? xs) ys]
        [(null? ys) xs]
        [(var<? (car xs) (car ys))
         (cons (car xs) (merge-vars (cdr xs) ys))]
        [(var<? (car ys) (car xs))
         (cons (car ys) (merge-vars xs (cdr ys)))]
        [else (cons (car xs) (merge-vars (cdr xs) (cdr ys)))]))

(define (remove-duplicates-vars xs)
  (cond [(null? xs) xs]
        [(null? (cdr xs)) xs]
        [(var=? (car xs) (cadr xs)) (remove-duplicates-vars (cdr xs))]
        [else (cons (car xs) (remove-duplicates-vars (cdr xs)))]))

(define (rev-append xs ys)
  (if (null? xs) ys
      (rev-append (cdr xs) (cons (car xs) ys))))

;; procedura pomocnicza wyszukująca wspólną zmienną dla podanych list zmiennych

(define (common-var list-of-pos-vars list-of-neg-vars)
  ;; procedura szukająca współlnej zmiennej na liście pozytywnych i negatywnych zmiennych podanych jako argument
  ;; procedura zwraca pierwszą znalezioną zmienną, lub false, jeśli na listach nie występuje żadna wspólna zmienna 
  (cond [(or (null? list-of-pos-vars) (null? list-of-neg-vars)) #f]
        [(var=? (car list-of-pos-vars) (car list-of-neg-vars)) (car list-of-pos-vars)]
        [(var<? (car list-of-pos-vars) (car list-of-neg-vars)) (common-var (cdr list-of-pos-vars) list-of-neg-vars)]
        [else (common-var list-of-pos-vars (cdr list-of-neg-vars))]))


(define (clause-trivial? c)
  ;; procedura sprawdza, czy podana klauzula jest trywialna
  ;; klauzula jest trywialna, gdy zawiera jednocześnie pozytywne i negatywne wystąpienie zmiennej
  (if (common-var (res-clause-pos c) (res-clause-neg c))
      #t
      #f))
        
(define (resolve c1 c2)
  ;; procedura do przeprowadzenia rezolucji dwóch klauzul
  ;; procedura zwraca false, gdy klauzule nie mają zmiennej względem której można przeprowadzić rezolucję
  ;; jeśli taka zmienna wystepuje, przeprowadzana jest względem niej rezolucja
  ;; procedura zwraca wówczas nową klauzule zachowującą niezmienniki struktury danych
  (let* ((pos1 (res-clause-pos c1))
         (pos2 (res-clause-pos c2))
         (neg1 (res-clause-neg c1))
         (neg2 (res-clause-neg c2))
         (common-var-p1n2 (common-var pos1 neg2))
         (common-var-n1p2 (common-var pos2 neg1)))
    (cond [(and (not common-var-p1n2)
                (not common-var-n1p2)) false]
          [common-var-p1n2 (res-clause (remove-duplicates-vars (merge-vars (remove common-var-p1n2 pos1) pos2))
                                             (remove-duplicates-vars (merge-vars neg1 (remove common-var-p1n2 neg2)))
                                             (proof-res common-var-p1n2 (res-clause-proof c1) (res-clause-proof c2)))]
          [else (res-clause (remove-duplicates-vars (merge-vars pos1 (remove common-var-n1p2 pos2)))
                            (remove-duplicates-vars (merge-vars (remove common-var-n1p2 neg1) neg2))
                            (proof-res common-var-n1p2 (res-clause-proof c2) (res-clause-proof c1)))])))


(define (resolve-single-prove s-clause checked pending)
  ;; procedura do rezolucji klauzul z pojedynczymi literałami
  (define opposed-clause?
    ;; procedura sprawdzająca, czy klauzula składa się wyłacznie z dopełnienia s-clause
    (lambda (c) (and (equal? (res-clause-pos c) (res-clause-neg s-clause))
                     (equal? (res-clause-neg c) (res-clause-pos s-clause)))))
  (define (find-opposed-clause clauses)
    ;; procedura szukająca klauzuli zawierającej wyłącznie dopełnienie s-clause
    ;; jeśli takiej klauzuli nie ma zwracany jest fałsz
    (cond [(null? clauses) #f]
          [(opposed-clause? (car clauses)) (car clauses)]
          [else (find-opposed-clause (cdr clauses))]))
  (define (easier? c1 c2)
    ;; sprawdzenie, czy pierwsza z klauzul podanych jako argumenty jest łatwiejsza od drugiej
    ;; c1 jest łatwiejsza od c2, gdy c1 zawiera wszystkie literały c2
    (and (andmap (lambda (e) (member e (res-clause-pos c1))) (res-clause-pos c2))
         (andmap (lambda (e) (member e (res-clause-neg c1))) (res-clause-neg c2))))
  (define resolve-single-clause
    ;; procedura zastępująca klauzule ich rezolwentami, jeśli to możliwe
    (lambda (c) (let ((resolve (resolve c s-clause)))
                  (if resolve
                      resolve
                      c))))
  ;; jeśli w checked lub pending jest dopełnienie s-clause zwracany jest dowód sprzeczności
  ;; ponieważ takie klauzule rezolwują się do klauzuli pustej
  ;; w przeciwnym wypadku klauzule na listach checked i pending zastępowane są swoimi rezolwentami
  ;; usuwane są klauzule łatwiejsze od s-clause, lista pending jest sortowana
  ;; do listy checked zostaje dodana klauzula s-clause
  (let ((opposed-clause-in-checked (find-opposed-clause checked))
        (opposed-clause-in-pending (find-opposed-clause pending)))
    (cond [opposed-clause-in-checked (list 'unsat (res-clause-proof (resolve opposed-clause-in-checked s-clause)))]
          [opposed-clause-in-pending (list 'unsat (res-clause-proof (resolve opposed-clause-in-pending s-clause)))]
          [else (resolve-prove (cons s-clause (filter (lambda (c) (not (easier? c s-clause))) (map resolve-single-clause checked)))
                               (sort-clauses (filter (lambda (c) (not (easier? c s-clause))) (map resolve-single-clause pending))))])))
           

;; wstawianie klauzuli w posortowaną względem rozmiaru listę klauzul
(define (insert nc ncs)
  (cond
   [(null? ncs)                     (list nc)]
   [(< (res-clause-size nc)
       (res-clause-size (car ncs))) (cons nc ncs)]
   [else                            (cons (car ncs) (insert nc (cdr ncs)))]))

;; sortowanie klauzul względem rozmiaru (funkcja biblioteczna sort)
(define (sort-clauses cs)
  (sort cs < #:key res-clause-size))

;; główna procedura szukająca dowodu sprzeczności
;; zakładamy że w checked i pending nigdy nie ma klauzuli sprzecznej
(define (resolve-prove checked pending)
  (cond
   ;; jeśli lista pending jest pusta, to checked jest zamknięta na rezolucję czyli spełnialna
   [(null? pending) (generate-valuation (sort-clauses checked))]
   ;; jeśli klauzula ma jeden literał, to możemy traktować łatwo i efektywnie ją przetworzyć
   [(= 1 (res-clause-size (car pending)))
    (resolve-single-prove (car pending) checked (cdr pending))]
   ;; w przeciwnym wypadku wykonujemy rezolucję z wszystkimi klauzulami już sprawdzonymi, a
   ;; następnie dodajemy otrzymane klauzule do zbioru i kontynuujemy obliczenia
   [else
    (let* ((next-clause  (car pending))
           (rest-pending (cdr pending))
           (resolvents   (filter-map (lambda (c) (resolve c next-clause))
                                     checked))
           (sorted-rs    (sort-clauses resolvents)))
      (subsume-add-prove (cons next-clause checked) rest-pending sorted-rs))]))

;; procedura upraszczająca stan obliczeń biorąc pod uwagę świeżo wygenerowane klauzule i
;; kontynuująca obliczenia

(define (subsume-add-prove checked pending new)
  (define (easier? c1 c2)
    ;; sprawdzenie, czy pierwsza z klauzul podanych jako argumenty jest łatwiejsza od drugiej
    ;; c1 jest łatwiejsza od c2, gdy c1 zawiera wszystkie literały c2
    (and (andmap (lambda (e) (member e (res-clause-pos c1))) (res-clause-pos c2))
         (andmap (lambda (e) (member e (res-clause-neg c1))) (res-clause-neg c2))))
  (cond
    [(null? new)                 (resolve-prove checked pending)]
    ;; jeśli klauzula do przetworzenia jest sprzeczna to jej wyprowadzenie jest dowodem sprzeczności
    ;; początkowej formuły
    [(clause-false? (car new))   (list 'unsat (res-clause-proof (car new)))]
    ;; jeśli klauzula jest trywialna to nie ma potrzeby jej przetwarzać
    [(clause-trivial? (car new)) (subsume-add-prove checked pending (cdr new))]
    ;; jeśli nowa klauzula jest łatwiejsza od którejś z już obecnych, możemy ją usunąć
    [(or (ormap (lambda (c) (easier? (car new) c)) checked)
         (ormap (lambda (c) (easier? (car new) c)) pending)) (subsume-add-prove checked pending (cdr new))]
    [else
     ;; z list checked i pending usuwamy klauzule łatwiejsze od sprawdzanej
     ;; do listy pending wstawiamy w odpowiednie miejsce sprawdzaną klauzule
     (subsume-add-prove (filter (lambda (c) (not (easier? c (car new)))) checked)
                        (insert (car new) (filter (lambda (c) (not (easier? c (car new)))) pending))
                        (cdr new))]))

;;; Współpraca i pomoc w przygotowaniu tej części pracowni z Małgorzatą Zacharską

;; procedury pomocnicze do generowania częściowego wartościowania
;; wartościowanie to lista list dwuelementowych, gdzie pierwszy element listy to zmienna, a drugi to jej wartość

;; konstruktur
(define single-var-evaluation list)

;; selektory
(define single-var-evaluation-var first)
(define single-var-evaluation-val second)

(define (generate-valuation resolved)
  ;; procedura generuje częściowe wartościowanie na podstawie podanej listy klauzul
  ;; rozpatrywana jest najmniejsza klauzula, jeśli jest ona jednoliterałowa, wartościowanie
  ;; dobierane jest zgodnie z tym literałem, jeśli nie ma klauzuli jednoliterałowej
  ;; wartościowanie dobierane jest na podstawie pierwszej ze zmiennych w najmniejszej klauzuli
  ;; ponieważ wybór zmiennej jest wówczas dowolny.
  ;; procedura wywołuje się iteracyjnie z uproszczoną o nowe wartościowanie listą klauzul
  ;; oraz całkowitym wartosciowaniem poszerzonym o nowe, pojedyncze wartościowanie
  (define (simplify clauses evaluation)
  ;; procedura usuwa z klauzul na liście clauses wystapienia zwartościowanego literału
  ;; procedura sortuje również otrzymaną listę oraz usuwa z niej puste klauzule
  (let ((svevar (single-var-evaluation-var evaluation))
        (sveval (single-var-evaluation-val evaluation)))
    (sort-clauses (filter (lambda (c) (not (= 0 (res-clause-size c))))
                          (if sveval                              
                              (filter (lambda (c) (not (member svevar (res-clause-pos c))))
                                      (map (lambda (c) (res-clause (res-clause-pos c)
                                                                   (filter (lambda (v) (not (eq? svevar v))) (res-clause-neg c))
                                                                   (res-clause-proof c))) clauses))
                              (filter (lambda (c) (not (member svevar (res-clause-neg c))))
                                      (map (lambda (c) (res-clause (filter (lambda (v) (not (eq? svevar v))) (res-clause-pos c))
                                                                   (res-clause-neg c)
                                                                   (res-clause-proof c))) clauses)))))))
  (define (iter r e)
    (if (null? r)
        e
        (let* ((smaller-clause (car r))
               (rest-of-clauses (cdr r))
               (new-evaluation (if (not (null? (res-clause-pos smaller-clause)))
                                   (single-var-evaluation (car (res-clause-pos smaller-clause)) true)
                                   (single-var-evaluation (car (res-clause-neg smaller-clause)) false))))
          (iter (simplify rest-of-clauses new-evaluation) (cons new-evaluation e)))))
  (list `sat (iter resolved null)))
                           
;; procedura przetwarzające wejściowy CNF na wewnętrzną reprezentację klauzul
(define (form->clauses f)
  (define (conv-clause c)
    (define (aux ls pos neg)
      (cond
       [(null? ls)
        (res-clause (remove-duplicates-vars (sort pos var<?))
                    (remove-duplicates-vars (sort neg var<?))
                    (proof-axiom c))]
       [(literal-pol (car ls))
        (aux (cdr ls)
             (cons (literal-var (car ls)) pos)
             neg)]
       [else
        (aux (cdr ls)
             pos
             (cons (literal-var (car ls)) neg))]))
    (aux (clause-lits c) null null))
  (map conv-clause (cnf-clauses f)))

(define (prove form)
  (let* ((clauses (form->clauses form)))
    (subsume-add-prove '() '() clauses)))

;; procedura testująca: próbuje dowieść sprzeczność formuły i sprawdza czy wygenerowany
;; dowód/waluacja są poprawne. Uwaga: żeby działała dla formuł spełnialnych trzeba umieć wygenerować
;; poprawną waluację.
(define (prove-and-check form)
  (let* ((res (prove form))
         (sat (car res))
         (pf-val (cadr res)))
    (if (eq? sat 'sat)
        (valuate-partial pf-val form)
        (check-proof pf-val form))))

;;; TESTY

;; Testowe klauzule oraz formuły

;; przykładowe klauzule potrzebne do testów
(define test-clause1 (clause (literal true (var 'q)) (literal false (var 'r))))
(define test-clause2 (clause (literal true (var 'p)) (literal false (var 's))))
(define test-clause3 (clause (literal false (var 's)) (literal false (var 'r))))
(define test-clause4 (clause (literal false (var 'p)) (literal false (var 'q))))
(define test-clause5 (clause (literal true (var `s))))

(define test-clause6 (clause (literal false (var 'p)) (literal true (var 'q))))

(define test-clause7 (clause (literal true (var 'p)) (literal false (var 'q))))

(define test-clause8 (clause (literal false `p) (literal true `q) (literal false `s) (literal true `x)))
(define test-clause9 (clause (literal false `s) (literal true `x) (literal false `y)))
(define test-clause10 (clause (literal false `p) (literal true `r) (literal false `t) (literal false `u)))
(define test-clause11 (clause (literal true `x) (literal false `w)))
(define test-clause12 (clause (literal true `x)  (literal false `y) (literal true `z)))
(define test-clause13 (clause (literal true `p) (literal false `q) (literal true `s) (literal false `z)))
(define test-clause14 (clause (literal false `r) (literal false `u) (literal false `y)))
(define test-clause15 (clause (literal true `p) (literal false `q) (literal false `u) (literal false `w)))
(define test-clause16 (clause (literal true `q) (literal false `s) (literal false `w) ))
(define test-clause17 (clause (literal true `y) (literal false `z)))
(define test-clause18 (clause (literal true `p) (literal true `s) (literal true `w)))
(define test-clause19 (clause (literal false `q) (literal false `s) (literal true `y) ))
(define test-clause20 (clause (literal false `p) (literal false `s) (literal true `w) (literal true `y)))
(define test-clause21 (clause (literal true `q) (literal true `t) (literal false `y)))
(define test-clause22 (clause (literal false `r) (literal false `z)))
(define test-clause23 (clause (literal true `p) (literal true `x) (literal false `z)))
(define test-clause24 (clause (literal false `t) (literal true `w) (literal true `y)))
(define test-clause25 (clause (literal true `p) (literal false `q) (literal false `z)))
(define test-clause26 (clause (literal true `r) (literal false `w) (literal false `z)))
(define test-clause27 (clause (literal true `s) (literal false `u) (literal true `w) (literal false `y)))
(define test-clause28 (clause (literal true `p) (literal false `q) (literal true `t) (literal false `w) (literal true `x)))


(define test-trivial-clause1 (clause (literal true (var 'q)) (literal false (var 'r)) (literal false (var 's)) (literal true (var 'r))))
(define test-trivial-clause2 (clause (literal true (var 'q)) (literal false (var 'q))))

;; resolved otrzymany z przeprowadzenia rezolucji przed zastosowaniem optymalizacji z zadania 3
(define test-resolved '((res-int () (r) 1 (resolve s (axiom (clause (literal #t s))) (resolve p (axiom (clause (literal #t p) (literal #f s))) (resolve q (axiom (clause (literal #t q) (literal #f r))) (axiom (clause (literal #f p) (literal #f q)))))))
                        (res-int () (r) 1 (resolve s (axiom (clause (literal #t s))) (resolve q (axiom (clause (literal #t q) (literal #f r))) (resolve p (axiom (clause (literal #t p) (literal #f s))) (axiom (clause (literal #f p) (literal #f q)))))))
                        (res-int () (r) 1 (resolve p (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))) (resolve q (axiom (clause (literal #t q) (literal #f r))) (axiom (clause (literal #f p) (literal #f q))))))
                        (res-int () (r) 1 (resolve q (axiom (clause (literal #t q) (literal #f r))) (resolve s (axiom (clause (literal #t s))) (resolve p (axiom (clause (literal #t p) (literal #f s))) (axiom (clause (literal #f p) (literal #f q)))))))
                        (res-int () (q) 1 (resolve s (axiom (clause (literal #t s))) (resolve p (axiom (clause (literal #t p) (literal #f s))) (axiom (clause (literal #f p) (literal #f q))))))
                        (res-int () (r) 1 (resolve q (axiom (clause (literal #t q) (literal #f r))) (resolve p (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))) (axiom (clause (literal #f p) (literal #f q))))))
                        (res-int () (q) 1 (resolve p (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))) (axiom (clause (literal #f p) (literal #f q)))))
                        (res-int () (r) 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #f s) (literal #f r)))))
                        (res-int (p) () 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))))
                        (res-int (s) () 1 (axiom (clause (literal #t s))))
                        (res-int () (r s) 2 (resolve p (axiom (clause (literal #t p) (literal #f s))) (resolve q (axiom (clause (literal #t q) (literal #f r))) (axiom (clause (literal #f p) (literal #f q))))))
                        (res-int () (r s) 2 (resolve q (axiom (clause (literal #t q) (literal #f r))) (resolve p (axiom (clause (literal #t p) (literal #f s))) (axiom (clause (literal #f p) (literal #f q))))))
                        (res-int () (p r) 2 (resolve q (axiom (clause (literal #t q) (literal #f r))) (axiom (clause (literal #f p) (literal #f q)))))
                        (res-int () (q s) 2 (resolve p (axiom (clause (literal #t p) (literal #f s))) (axiom (clause (literal #f p) (literal #f q)))))
                        (res-int () (p q) 2 (axiom (clause (literal #f p) (literal #f q))))
                        (res-int () (r s) 2 (axiom (clause (literal #f s) (literal #f r))))
                        (res-int (p) (s) 2 (axiom (clause (literal #t p) (literal #f s))))
                        (res-int (q) (r) 2 (axiom (clause (literal #t q) (literal #f r))))))

;; resolved otrzymany z przeprowadzenia rezolucji po opytamlizacji subsume-add-prove
(define test-resolved2 '((res-int () (q) 1 (resolve p (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))) (axiom (clause (literal #f p) (literal #f q)))))
                         (res-int () (r) 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #f s) (literal #f r)))))
                         (res-int (p) () 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))))
                         (res-int (s) () 1 (axiom (clause (literal #t s))))))

;; resolved otrzymany z przeprowadzenia rezolucji po opytamlizacji wyłącznie resolve-single-prove
(define test-resolved4 '((res-int () (q) 1 (resolve p (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))) (axiom (clause (literal #f p) (literal #f q)))))
                         (res-int () (r) 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #f s) (literal #f r)))))
                         (res-int (p) () 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))))
                         (res-int (s) () 1 (axiom (clause (literal #t s))))))

;; wynik procedury (simplify test-resolved2 (single-var-evaluation `r #f))
;; wynik został zapisany w celu prezetacji działania
;; simplify jest obecnie procedurą pomocniczą wewnątrz innej procedury, więc nie da się jej wywołać bezpośrednio
(define test-resolved5 '((res-int () (q) 1 (resolve p (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))) (axiom (clause (literal #f p) (literal #f q)))))
                         (res-int (p) () 1 (resolve s (axiom (clause (literal #t s))) (axiom (clause (literal #t p) (literal #f s)))))
                         (res-int (s) () 1 (axiom (clause (literal #t s))))))

;; stworzenie trzech formuł w cnf
;; pierwsza z nich jest spełniona dla wartościowania (p #t) (q #f) (r #f) (s #t)
;; druga z nich nie jest spełnialna
;; trzecia jest spełnialna, składa się z większej ilości klauzul i zmiennych
(define test-satisfiable-cnf (cnf test-clause1 test-clause2 test-clause3 test-clause4 test-clause5))
(define test-unsatisfiable-cnf (cnf test-clause1 test-clause2 test-clause3 test-clause4 test-clause5 test-clause6))
(define test-cnf (cnf test-clause8 test-clause9 test-clause10 test-clause11 test-clause12 test-clause13 test-clause14
                      test-clause15 test-clause16 test-clause17 test-clause18 test-clause19 test-clause20 test-clause21
                      test-clause22 test-clause23 test-clause24 test-clause25 test-clause26 test-clause27 test-clause28))

;; procedura pomocnicza do wypisywania klauzuli
(define (print-clauses clauses)
  (if (null? clauses)
      (newline)
      (begin (displayln (list `clause (res-clause-pos (car clauses)) (res-clause-neg (car clauses)) (res-clause-size (car clauses)) `proof))
             (print-clauses (cdr clauses)))))

;; Testy poszczególnych procedur

;; Test common-var
(println "Test procedury common-var")
;; Wspólna zmiennia z list `(p q r) `(q s)
(common-var `(p q r) `(q s))
;; Wspólna zmiennia z list `(p q r) `()
(common-var `(p q r) `())
;; Wspólna zmiennia z list `(p) `(r s)
(common-var `(p) `(r s))
;; Wspólna zmiennia z list `() `(r s)
(common-var `() `(r s))
;; Wspólna zmiennia z list `(p q r s) `(p q r s)
(common-var `(p q r s) `(p q r s))
(newline)

;; Test clause-trivial
;; Pierwsze 3 klauzule nie są trywialne, następne dwie są
(println "Test procedury clause-trivial?")
(clause-trivial? (car (form->clauses (cnf test-clause1))))
(clause-trivial? (car (form->clauses (cnf test-clause2))))
(clause-trivial? (car (form->clauses (cnf test-clause3))))
(clause-trivial? (car (form->clauses (cnf test-trivial-clause1))))
(clause-trivial? (car (form->clauses (cnf test-trivial-clause2))))
(newline)

;; Test resolve
(println "Test procedury resolve")
;; resolve dla klauzul q v -r oraz -p v -q
;; wynikiem powinna być klauzula -p V -r
(resolve (car (form->clauses (cnf test-clause1))) (car (form->clauses (cnf test-clause4))))
;; resolve dla klauzul p V -s oraz -s v -r
;; wynikiem powinno być false
(resolve (car (form->clauses (cnf test-clause2))) (car (form->clauses (cnf test-clause3))))
;; resolve dla klauzul q V -p oraz p v -q
;; wynikiem powinna być klauzula p v -p
(resolve (car (form->clauses (cnf test-clause6))) (car (form->clauses (cnf test-clause7))))
(newline)

;; Test procedury generate-valuation oraz simplify
;; wartościowanie powinno wynosić (p #t) (q #f) (r #f) (s #t)
(println "Test procedury simplify")
(print-clauses test-resolved2)
(print-clauses test-resolved5)
(newline)
(println "Test procedury generate-valuation")
(generate-valuation test-resolved)
(newline)

;; Test optymalizacji procedury subsume-add-prove
;; Porównanie resolved otrzymanego z procedur przed i po dodaniu optymalizacji procedury subsume-add-prove
(println "Test optymalizacji procedury subsume-add-prove")
(print-clauses test-resolved)
(print-clauses test-resolved2)


;; Test optymalizacji procedury resolve-single-prve
(println "Test optymalizacji procedury resolve-single-prove")
(print-clauses test-resolved)
(print-clauses test-resolved4)
(newline)

;; Test działania całego programu
(println "Test działania pełnego programu")

(prove test-satisfiable-cnf)
(prove-and-check test-satisfiable-cnf)
(newline)

(prove test-unsatisfiable-cnf)
(prove-and-check test-unsatisfiable-cnf)
(newline)

(prove test-cnf)
(prove-and-check test-cnf)
