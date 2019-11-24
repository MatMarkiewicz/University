#lang racket
(require "calc.rkt")

(define (def-name p)
  (car p))

(define (def-prods p)
  (cdr p))

(define (rule-name r)
  (car r))

(define (rule-body r)
  (cdr r))

(define (lookup-def g nt)
  (cond [(null? g) (error "unknown non-terminal" g)]
        [(eq? (def-name (car g)) nt) (def-prods (car g))]
        [else (lookup-def (cdr g) nt)]))

(define parse-error 'PARSEERROR)

(define (parse-error? r) (eq? r 'PARSEERROR))

(define (res v r)
  (cons v r))

(define (res-val r)
  (car r))

(define (res-input r)
  (cdr r))

;;

(define (token? e)
  (and (list? e)
       (> (length e) 0)
       (eq? (car e) 'token)))

(define (token-args e)
  (cdr e))

(define (nt? e)
  (symbol? e))

;;

(define (parse g e i)
  (cond [(token? e) (match-token (token-args e) i)]
        [(nt? e) (parse-nt g (lookup-def g e) i)]))

(define (parse-nt g ps i)
  (if (null? ps)
      parse-error
      (let ([r (parse-many g (rule-body (car ps)) i)])
        (if (parse-error? r)
            (parse-nt g (cdr ps) i)
            (res (cons (rule-name (car ps)) (res-val r))
                 (res-input r))))))

(define (parse-many g es i)
  (if (null? es)
      (res null i)
      (let ([r (parse g (car es) i)])
        (if (parse-error? r)
            parse-error
            (let ([rs (parse-many g (cdr es) (res-input r))])
              (if (parse-error? rs)
                  parse-error
                  (res (cons (res-val r) (res-val rs))
                       (res-input rs))))))))

(define (match-token xs i)
  (if (and (not (null? i))
           (member (car i) xs))
      (res (car i) (cdr i))
      parse-error))

;;

(define num-grammar
  '([digit {DIG (token #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)}]
    [numb {MANY digit numb}
          {SINGLE digit}]))

(define (node-name t)
  (car t))

;; selektory, konstruktor
(define node-left second)
(define node-op third)
(define node-right fourth)
(define node-const list)

(define (c->int c)
  (- (char->integer c) (char->integer #\0)))

(define (walk-tree-acc t acc)
  (cond [(eq? (node-name t) 'MANY)
         (walk-tree-acc
          (third t)
          (+ (* 10 acc) (c->int (second (second t)))))]
        [(eq? (node-name t) 'SINGLE)
         (+ (* 10 acc) (c->int (second (second t))))]))

(define (walk-tree t)
  (walk-tree-acc t 0))

;;

(define arith-grammar
  (append num-grammar
       ;; rozszerzenie wyrażeń z dodawaniem na wyrażenia z dodawaniem i odejmowaniem
     '([add-sub-expr {ADD-MANY mult-div-expr (token #\+) add-sub-expr}
                     {SUB-MANY mult-div-expr (token #\-) add-sub-expr}
                     {ADD-SUB-SINGLE mult-div-expr}]
       ;; rozszerzenie wyrażeń z mnożeniem na wyrażenia z mnożeniem i dzieleniem
       [mult-div-expr {MULT-MANY base-expr (token #\*) mult-div-expr}
                      {DIV-MANY base-expr (token #\/) mult-div-expr}
                      {MULT-DIV-SINGLE base-expr}]
       [base-expr {BASE-NUM numb}
                  {PARENS (token #\() add-sub-expr (token #\))}])))

(define (change-tree t)
  ;; procedura pomocnicza, dzięki której wyrażenia wiążą w prawo, a nie w lewo
  ;; zmiana dotyczy również wyrażeń z dodawaniem i mnożeniem. Obie te operacje są łączne
  ;; więc wynik pozostaje ten sam, lecz naturalna kolejność wykonywania działań to od lewej do prawej
        ;; w przypadku pojedynczych wyrażeń wykonywane jest wywołanie rekurencyjne dla podwyrażenia
  (cond [(eq? (node-name t) 'ADD-SUB-SINGLE) (node-const (node-name t) (change-tree (node-left t)))]
        [(eq? (node-name t) 'MULT-DIV-SINGLE) (node-const (node-name t) (change-tree (node-left t)))]
        ;; w przypadku wyrażeń składających z większej ilości elementów schemat działania jest następujący:
        ;; jeśli prawe podwyrażenie jest pojedynczym wyrażeniem wykonywane są wywołania rekurencyjne dla podwyrażeń
        ;; nie trzeba edytować takiej struktury, gdyż 2 elementy łączą w lewo
        ;; jeśli prawe podwyrażenie jest rozbudowane, powstaje nowe wyrażenie, gdzie lewy element oraz lewy element prawego
        ;; podwyrażenia łączone są ze sobą i stają się nowym lewym elementem prawego poddzewa. Schemat ten jest powtarzany
        ;; za pomocą wywołań rekurencyjnych, aż całe wyrażenie zostanie "przechylone" na lewą stronę
        ;; wówczas prawdziwy jest warunek, że prawe poddzewo jest pojedynczym wyrażeniem i nastepuje wywołanie dla podwyrażeń
        [(eq? (node-name t) 'ADD-MANY) (if (member (node-name (node-right t)) `(ADD-MANY SUB-MANY))
                                           (change-tree (node-const (node-name (node-right t))
                                                                    (node-const (node-name t)
                                                                                (node-left t)
                                                                                (node-op t)
                                                                                (node-left (node-right t)))
                                                                    (node-op (node-right t))
                                                                    (node-right (node-right t))))
                                           (node-const (node-name t)
                                                       (change-tree (node-left t))
                                                       (node-op t)
                                                       (change-tree (node-right t))))]
        [(eq? (node-name t) 'SUB-MANY) (if (member (node-name (node-right t)) `(ADD-MANY SUB-MANY))
                                           (change-tree (node-const (node-name (node-right t))
                                                                    (node-const (node-name t)
                                                                                (node-left t)
                                                                                (node-op t)
                                                                                (node-left (node-right t)))
                                                                    (node-op (node-right t))
                                                                    (node-right (node-right t))))
                                           (node-const (node-name t)
                                                       (change-tree (node-left t))
                                                       (node-op t)
                                                       (change-tree (node-right t))))]
        [(eq? (node-name t) 'MULT-MANY) (if (member (node-name (node-right t)) `(MULT-MANY DIV-MANY))
                                           (change-tree (node-const (node-name (node-right t))
                                                                    (node-const (node-name t)
                                                                                (node-left t)
                                                                                (node-op t)
                                                                                (node-left (node-right t)))
                                                                    (node-op (node-right t))
                                                                    (node-right (node-right t))))
                                           (node-const (node-name t)
                                                       (change-tree (node-left t))
                                                       (node-op t)
                                                       (change-tree (node-right t))))]
        [(eq? (node-name t) 'DIV-MANY) (if (member (node-name (node-right t)) `(MULT-MANY DIV-MANY))
                                           (change-tree (node-const (node-name (node-right t))
                                                                    (node-const (node-name t)
                                                                                (node-left t)
                                                                                (node-op t)
                                                                                (node-left (node-right t)))
                                                                    (node-op (node-right t))
                                                                    (node-right (node-right t))))
                                           (node-const (node-name t)
                                                       (change-tree (node-left t))
                                                       (node-op t)
                                                       (change-tree (node-right t))))]
        [(eq? (node-name t) 'BASE-NUM) t]
        ;; w przypadku nawiasów następuje wywołanie rekurencyjne dla podwyrażenia
        ;; z powodu zmiany kolejności argumentów selektor ten ma mylną nazwę node-op (zazwyczaj trzecim elementem jest operator)
        [(eq? (node-name t) 'PARENS) (node-const (node-name t) (node-left t) (change-tree (node-op t)) (node-right t))]
        ))
                                  
(define (arith-walk-tree t)
  (cond [(eq? (node-name t) 'ADD-SUB-SINGLE)
         (arith-walk-tree (second t))]
        [(eq? (node-name t) 'MULT-DIV-SINGLE)
         (arith-walk-tree (second t))]
        [(eq? (node-name t) 'ADD-MANY)
         (binop-cons
          '+
          (arith-walk-tree (second t))
          (arith-walk-tree (fourth t)))]
        ;; rozszerzenie procedury o przetwarzanie wyrażeń z odejmowaniem i dzieleniem
        ;; w sposób analogiczny, jak wyrażenia z dodawaniem i mnożeniem
        [(eq? (node-name t) 'SUB-MANY)
         (binop-cons
          '-
          (arith-walk-tree (second t))
          (arith-walk-tree (fourth t)))]
        [(eq? (node-name t) 'MULT-MANY)
         (binop-cons
          '*
          (arith-walk-tree (second t))
          (arith-walk-tree (fourth t)))]
        [(eq? (node-name t) 'DIV-MANY)
         (binop-cons
          '/
          (arith-walk-tree (second t))
          (arith-walk-tree (fourth t)))]
        [(eq? (node-name t) 'BASE-NUM)
         (walk-tree (second t))]
        [(eq? (node-name t) 'PARENS)
         (arith-walk-tree (third t))]))

(define (calc s)
  (eval
   (arith-walk-tree
    (change-tree
     (car
      (parse
       arith-grammar
       'add-sub-expr
       (string->list s)))))))

;; TESTY

(define (convert s)
  ;; procedura pomocnicza do testów
  (arith-walk-tree
   (change-tree
    (car
    (parse
       arith-grammar
       'add-sub-expr
       (string->list s))))))

(define (convert2 s)
  ;; procedura pomocnicza do testów
   (change-tree
    (car
    (parse
       arith-grammar
       'add-sub-expr
       (string->list s)))))

(define (convert3 s)
  ;; procedura pomocnicza do testów
    (car
    (parse
       arith-grammar
       'add-sub-expr
       (string->list s))))

(define (test)
  (and (equal? (convert "2+2")
               '(+ 2 2))
       (equal? (convert "1-2-3")
               '(- (- 1 2) 3))
       (equal? (convert "2*(1+1)")
               '(* 2 (+ 1 1)))
       (equal? (convert "1+2*3")
               '(+ 1 (* 2 3)))
       (equal? (convert "2+2+2+2")
               '(+ (+ (+ 2 2) 2) 2))
       (equal? (convert "2*2-3-4")
               '(- (- (* 2 2) 3) 4))
       (equal? (convert "5-4-3-2-1")
               '(- (- (- (- 5 4) 3) 2) 1))
       (equal? (convert "4+6/3")
               '(+ 4 (/ 6 3)))
       (equal? (convert "5*6*7-8")
               '(- (* (* 5 6) 7) 8))
       (equal? (convert "5-6*7*8")
               '(- 5 (* (* 6 7) 8)))
       (equal? (convert "5*6-8/2")
               '(- (* 5 6) (/ 8 2)))
       (equal? (convert "5*(6-3)/5")
               '(/ (* 5 (- 6 3)) 5))
       (= (calc "2+2")
               4)
       (= (calc "1-2-3")
               -4)
       (= (calc "2*(1+1)")
               4)
       (= (calc "1+2*3")
               7)
       (= (calc "2+2+2+2")
               8)
       (= (calc "2*2-3-4")
               -3)
       (= (calc "5-4-3-2-1")
               -5)
       (= (calc "4+6/3")
               6)
       (= (calc "5*6*7-8")
               202)
       (= (calc "5-6*7*8")
               -331)
       (= (calc "5*6-8/2")
               26)
       (= (calc "5*(6-3)/5")
               3)
       ))

(define (random-op2)
  ;; operatory bez dzielenia, by uniknąć dzielenia przez zero
  (let ((n (random 3)))
    (define (random-elem n l)
      (cond [(null? l) (error "Index out of range")]
            [(= n 0) (car l)]
            [else (random-elem (- n 1) (cdr l))]))
    (random-elem n (list `+ `* `-))))

(define (random-arith n)
  ;; procedura pomocnicza generująca losowe wyrażenie o "głębokości" n
  ;; zakres liczb w wyrażeniu to domyslnie 1000
  (if (= n 0)
      (random 1000)
      (list (random-op2) (random-arith (- n 1)) (random-arith (- n 1)))))

(define (int_to_s i)
  ;; procedura pomocznicza
  (~v i))

(define (op_to_s op)
  ;; procedura pomocznicza
  (cond [(eq? op `+) "+"]
        [(eq? op `-) "-"]
        [(eq? op `*) "*"]
        [(eq? op `/) "/"]))

(define (to_s t)
  ;; procedura zmianiająca binop wyrażenie na wyrażenie w postaci string
  (if (not (binop? t))
      (int_to_s t)
      (string-append* "(" (to_s (binop-left t)) (op_to_s (binop-op t)) (to_s (binop-right t)) `(")"))))

;; z poniższych 2 postów widać, że dla większych danych program działa znacząco wolniej
;; z test3 wynika, że problemem jest parsowanie wyrażeń, lecz pomimo prób zmiany gramatyki tak,
;; by działała szybciej nie udało mi się osiągnąć lepszego działania programu
;; każde wyrażenie oprócz dodawania i mnożenia może być odejmowaniem i dzieleniem, przez co
;; dopasowywanie wyrażenia trwa znacznie dłużej

(define (test2 n)
  (let ((random-arith (random-arith n)))
    (= (eval random-arith) (calc (to_s random-arith)))))

(define (test3 n)
  (let ((random (random-arith n)))
    (begin (display "random arith done")
           (newline)
           (let ((string (to_s random)))
             (begin (display "to_s done")
                    (newline)
                    (let ((parse (convert3 string)))
                      (begin (display "parse done")
                             (newline)
                             (let ((change (change-tree parse)))
                               (begin (display "change done")
                                      (newline)
                                      (let ((walk (arith-walk-tree change)))
                                        (begin (display "walk done")
                                               (newline)
                                               (eval walk))))))))))))
           
