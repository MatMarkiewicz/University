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

;;
;; WHILE
;;

; memory

(define empty-mem
  null)

(define (set-mem x v m)
  (cond [(null? m)
         (list (cons x v))]
        [(eq? x (caar m))
         (cons (cons x v) (cdr m))]
        [else
         (cons (car m) (set-mem x v (cdr m)))]))

(define (get-mem x m)
  (cond [(null? m) 0]
        [(eq? x (caar m)) (cdar m)]
        [else (get-mem x (cdr m))]))

; arith and bool expressions: syntax and semantics

(define (const? t)
  (number? t))

(define (true? t)
  (eq? t 'true))

(define (false? t)
  (eq? t 'false))

(define (op? t)
  (and (list? t)
       (member (car t) '(+ - * / = > >= < <= not and or mod ^))))

(define (rand? t)
  ;; predykat wyrażeń rand
  (and (list? t)
       (eq? (car t) `rand)))

;; selektor wyrażeń rand zwracający aksymalny zakres liczby
(define rand-max cadr)

(define (op-op e)
  (car e))

(define (op-args e)
  (cdr e))

(define (op->proc op)
  (cond [(eq? op '+) +]
        [(eq? op '*) *]
        [(eq? op '-) -]
        [(eq? op '/) /]
        [(eq? op '=) =]
        [(eq? op '>) >]
        [(eq? op '>=) >=]
        [(eq? op '<)  <]
        [(eq? op '<=) <=]
        [(eq? op 'not) not]
        [(eq? op 'and) (lambda x (andmap identity x))]
        [(eq? op 'or) (lambda x (ormap identity x))]
        [(eq? op 'mod) modulo]
        [(eq? op `^) expt]))
                                                      

(define (var? t)
  (symbol? t))

(define (eval-arith e m seed)
  ;; procedura eval-arith została zmodyfikowana, by przekazywać stan
  ;; umozliwiający obliczanie kolejnych pseudolosowych liczb
  (cond [(true? e) (res true seed)]
        ;; wyrażenia składające się jedynie z symboli true/fals obliczane są do
        ;; wyniku, gdzie wartość to true/fals, a stan pozostaje taki, jak
        ;; otrzymany w argumencie 
        [(false? e) (res false seed)]
        ;; zmienne obliczane są do wyniku, gdzie wartość zmiennej odnajdowana jest
        ;; w pamięci, a stan pozostaje taki, jak otrzymany w argumencie
        [(var? e) (res (get-mem e m) seed)]
        ;; jeżeli wyarażenie jest postaci (rand max) obliczana jest wartość
        ;; max (rekurencyjnie), a następnie zwracana wartość z procedury rand
        ;; czyli para wylosowana liczba oraz stan.
        ;; rand obliczany jest dla takiego stanu, jaki został zwrócony z obliczenia max
        [(rand? e) (let ((r (eval-arith (rand-max e) m seed)))
                    ((rand (res-val r)) (res-state r)))]
        ;; w przypadku operatora na początku wyliczane są argumenty za pomocą
        ;; procedury eval-op, a następnie zwracany jest wynik, gdzie jego wartość
        ;; to zaaplikowany operator do wartości argumentów, a stan to stan
        ;; ostatniego argumentu
        [(op? e) (let ((args (eval-op (op-args e) m seed)))
                   (res (apply (op->proc (op-op e)) (map res-val args))
                        (res-state (last args))))]
        ;; w przypadku stałej zwracany jest wynik składający się
        ;; z tej stałej i otrzymanego w argumencie stanu
        [(const? e) (res e seed)]))

(define (eval-op args m seed)
  ;; procedura pomocnicza do evaluacji argumentów z op wyrażeń
  (if (null? args)
      null
      ;; obliczane jest pierwsze wyrażenie, a następnie ogon wyrażeń
      ;; ze stanem otrzymanym z wyliczenia pierwszego argumentu
      ;; wyniki łączone są w listę
      (let ((r (eval-arith (car args) m seed)))
        (cons r (eval-op (cdr args) m (res-state r))))))

;; syntax of commands

(define (assign? t)
  (and (list? t)
       (= (length t) 3)
       (eq? (second t) ':=)))

(define (assign-var e)
  (first e))

(define (assign-expr e)
  (third e))

(define (if? t)
  (tagged-tuple? 'if 4 t))

(define (if-cond e)
  (second e))

(define (if-then e)
  (third e))

(define (if-else e)
  (fourth e))

(define (while? t)
  (tagged-tuple? 'while 3 t))

(define (while-cond t)
  (second t))

(define (while-expr t)
  (third t))

(define (block? t)
  (list? t))

;; state

(define (res v s)
  (cons v s))

(define (res-val r)
  (car r))

(define (res-state r)
  (cdr r))

;; psedo-random generator

(define initial-seed
  123456789)

(define (rand max)
  (lambda (i)
    (let ([v (modulo (+ (* 1103515245 i) 12345) (expt 2 32))])
      (res (modulo v max) v))))

;; WHILE interpreter

(define (eval e m seed)
  ;; evaluator wspierający rand wyrażenia
        ;; w przypadku przypisania obliczana jest wartość wyrażenia
        ;; następnie do pamięcia dodawana jest nowa zmienna wraz z
        ;; obliczoną pamięcią i wynik ten zwracany jest wraz ze stanem
        ;; otrzymanym po obliczeniu wyrażenia z przypisania
  (cond [(assign? e) (let ((r-arith (eval-arith (assign-expr e) m seed)))
                       (res (set-mem
                             (assign-var e)
                             (res-val r-arith)
                             m)
                            (res-state r-arith)))]
        ;; w przypadku ifa obliczany jest warunek
        ;; jeśli wylicza się on do true obliczane jest wyrażenia
        ;; if-then (w otrzymanym stanem po obliczeniu warunku)
        ;; wpp obliczany jest if-else w taki sam sposób
        [(if? e) (let ((r-arith (eval-arith (if-cond e) m seed)))
                   (if (res-val r-arith)
                       (eval (if-then e) m (res-state r-arith))
                       (eval (if-else e) m (res-state r-arith))))]
        ;; w przypadku while obliczany jest warunek, jeśli jest on spełniony
        ;; obliczane jest wyrażenia (z otrzymanym stanem), a następnie
        ;; wywołujemy rekurencyjnie procedurę, by ponownie sprawdzić warunek
        ;; jeśli warunek nie jest spełniony zwracamy wynik,
        ;; czyli parę memory oraz stan otrzymany po wyliczeniu warunku
        [(while? e) (let ((r-arith (eval-arith (while-cond e) m seed)))
                      (if (res-val r-arith)
                          (let ((r-expr (eval (while-expr e) m (res-state r-arith))))
                            (eval e (res-val r-expr) (res-state r-expr)))
                          (res m (res-state r-arith))))]
        ;; w przypadku bloku obliczane są kolejne wyrażenia, którym odpowiednio
        ;; przekazuje się stan (seeda) oraz pamięć
        [(block? e)
         (if (null? e)
             (res m seed)
             (let ((r-expr (eval (car e) m seed)))
               (eval (cdr e) (res-val r-expr) (res-state r-expr))))]))

(define (run e)
  (res-val (eval e empty-mem initial-seed)))

;; Zgodnie z poleceniem liczbę pseudolosową z zakresu 2 - (n-2) reprezentujemy
;; jako (+ 2 (rand (- n 4))), przez co test Fermata działa dla n > 4

(define fermat-test2
  ;; procedura nie wykorzystująca expt
  `( (composite := false)
     (while (and (> k 0) (not composite))
            ( (a := (+ 2 (rand (- n 4))))
              (exp_a := 1)
              (m := (- n 1))
              (while (> m 0)
                     ( (exp_a := (* exp_a a))
                       (m := (- m 1))))
              (if (not (= 1 (mod exp_a n)))
                  (composite := true)
                  ())
              (k := (- k 1))))))

(define fermat-test
  ;; początkowo wartość composite jest fałszywa
  ;; następnie k razy losowana jest liczba z zakresu 2 - (n-2)
  ;; liczba a podnoszona jest do n-1 potęgi
  ;; i jeżeli nie jest ona równa 1 mod n, composite zmienia
  ;; wartość na true, przez co program się zakończy
  `( (composite := false)
     (while (and (> k 0) (not composite))
            ( (a := (+ 2 (rand (- n 4))))
              (exp_a := (^ a (- n 1)))
              (if (not (= 1 (mod exp_a n)))
                  (composite := true)
                  ())
              (k := (- k 1))))))

(define (probably-prime? n k) ; check if a number n is prime using
                              ; k iterations of Fermat's primality
                              ; test
  (let ([memory (set-mem 'k k
                         (set-mem 'n n empty-mem))])
    (not (get-mem
          'composite
          (res-val (eval fermat-test memory initial-seed))))))

;; TESTY


(define (take-rand n max seed)
  ;; procedura pomocnicza
  ;; zwraca listę n pseudolosowych liczb z zakresu 0-max
  ;; początkowy seed podany jest w argumencie
  (if (= n 0)
      null
      (let ((rand-num ((rand max) seed)))
        (cons (car rand-num) (take-rand (- n 1) max (cdr rand-num))))))

;; programy w języku while do testowania rand wyrażeń

(define test-rand-block
  `( (x0 := (rand 10))
     (x1 := (rand 10))
     (x2 := (rand 10))
     (x3 := (rand 10))
     (x4 := (rand 10))
     (x5 := (rand 10))
     (x6 := (rand 10))
     (x7 := (rand 10))
     (x8 := (rand 10))
     (x9 := (rand 10))))

(define test-rand-assign1
  `(x := (rand 10)))

(define test-rand-assign2
  `(x := (+ (rand 10) (rand 10) (rand 10) (rand 10) (rand 10) (rand 10) (rand 10) (rand 10) (rand 10) (rand 10))))

(define test-rand-assign3
  `(x := (rand (+ 2 (rand 10)))))

(define test-rand-if1
  `(if (> (rand 10) -1)
      (x := (+ 100 (rand 10)))
      (x := (+ 200 (rand 10)))))

(define test-rand-if2
  `(if (< (rand 10) -1)
      (x := (+ 100 (rand 10)))
      (x := (+ 200 (rand 10)))))

(define test-while1
  `( (n := 10)
     (s := 0)
     (while (> n 0)
            ( (s := (+ s (rand 10)))
              (n := (- n 1))))))

(define test-while2
  `( (i := 0)
     (while (not (= (rand 10) 5))
            (i := (+ i 1)))))

(define (ints n)
  ;; procedura pomocnicza zwracająca listę liczb od n do 5
  (if (= n 4)
      null
      (cons n (ints (- n 1)))))

;; procedury pomocznicze do sprawdzania pierwszości liczby
(define (dive-by? x y)
  (= (modulo x y) 0))

(define (prime? n)
  (define (helper i n)
    (if (> (* i i) n)
        true
        (and (not (dive-by? n i)) (helper (+ i 1) n))))
  (helper 2 n))

;; procedury testujące obie części pracowni

(define (test-prime)
  (and (equal? (filter (lambda (n) (prime? n)) (ints 1000))
          (filter (lambda (n) (probably-prime? n 10)) (ints 1000)))
       (probably-prime? 104729 10)))

(define (test-rand)
  (and (equal? (run test-rand-block) '((x0 . 0) (x1 . 9) (x2 . 8) (x3 . 7)
                (x4 . 2) (x5 . 5) (x6 . 8) (x7 . 1) (x8 . 6) (x9 . 9)))
       (equal? (run test-rand-assign1) '((x . 0)))
       (equal? (run test-rand-assign2) '((x . 55)))
       (equal? (run test-rand-assign3) '((x . 1)))
       (equal? (run test-rand-if1) '((x . 109)))
       (equal? (run test-rand-if2) '((x . 209)))
       (equal? (run test-while1) '((n . 0) (s . 55)))
       (equal? (run test-while2) '((i . 5)))
       ))

(and (test-rand) (test-prime))
