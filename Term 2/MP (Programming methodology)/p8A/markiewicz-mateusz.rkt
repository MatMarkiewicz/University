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

;; self-evaluating expressions

(define (const? t)
  (or (number? t)
      (my-symbol? t)
      (eq? t 'true)
      (eq? t 'false)))

;; arithmetic expressions

(define (op? t)
  (and (list? t)
       (member (car t) '(+ - * / = > >= < <= eq?))))

(define (op-op e)
  (car e))

(define (op-args e)
  (cdr e))

(define (op-cons op args)
  (cons op args))

(define (op->proc op)
  (cond [(eq? op '+) +]
        [(eq? op '*) *]
        [(eq? op '-) -]
        [(eq? op '/) /]
        [(eq? op '=)  (compose bool->val =)]
        [(eq? op '>)  (compose bool->val >)]
        [(eq? op '>=) (compose bool->val >=)]
        [(eq? op '<)  (compose bool->val <)]
        [(eq? op '<=) (compose bool->val <=)]
        [(eq? op 'eq?) (lambda (x y)
                         (bool->val (eq? (symbol-symbol x)
                                         (symbol-symbol y))))]))

;; symbols

(define (my-symbol? e)
  (and (tagged-tuple? 'quote 2 e)
       (symbol? (second e))))

(define (symbol-symbol e)
  (second e))

(define (symbol-cons s)
  (list 'quote s))

;; lets

(define (let-def? t)
  (and (list? t)
       (= (length t) 2)
       (symbol? (car t))))

(define (let-def-var e)
  (car e))

(define (let-def-expr e)
  (cadr e))

(define (let-def-cons x e)
  (list x e))

(define (let? t)
  (and (tagged-tuple? 'let 3 t)
       (let-def? (cadr t))))

(define (let-def e)
  (cadr e))

(define (let-expr e)
  (caddr e))

(define (let-cons def e)
  (list 'let def e))

;; variables

(define (var? t)
  (symbol? t))

(define (var-var e)
  e)

(define (var-cons x)
  x)

;; pairs

(define (cons? t)
  (tagged-tuple? 'cons 3 t))

(define (cons-fst e)
  (second e))

(define (cons-snd e)
  (third e))

(define (cons-cons e1 e2)
  (list 'cons e1 e2))

(define (car? t)
  (tagged-tuple? 'car 2 t))

(define (car-expr e)
  (second e))

(define (cdr? t)
  (tagged-tuple? 'cdr 2 t))

(define (cdr-expr e)
  (second e))

(define (pair?? t)
  (tagged-tuple? 'pair? 2 t))

(define (pair?-expr e)
  (second e))

(define (pair?-cons e)
  (list 'pair? e))


;; if

(define (if? t)
  (tagged-tuple? 'if 4 t))

(define (if-cons b t f)
  (list 'if b t f))

(define (if-cond e)
  (second e))

(define (if-then e)
  (third e))

(define (if-else e)
  (fourth e))

;; cond

(define (cond-clause? t)
  (and (list? t)
       (= (length t) 2)))

(define (cond-clause-cond c)
  (first c))

(define (cond-clause-expr c)
  (second c))

(define (cond-claue-cons b e)
  (list b e))

(define (cond? t)
  (and (tagged-list? 'cond t)
       (andmap cond-clause? (cdr t))))

(define (cond-clauses e)
  (cdr e))

(define (cond-cons cs)
  (cons 'cond cs))

;; lists

(define (my-null? t)
  (eq? t 'null))

(define (null?? t)
  (tagged-tuple? 'null? 2 t))

(define (null?-expr e)
  (second e))

(define (null?-cons e)
  (list 'null? e))

;; lambdas

(define (lambda? t)
  (and (tagged-tuple? 'lambda 3 t)
       (list? (cadr t))
       (andmap symbol? (cadr t))))

(define (lambda-cons vars e)
  (list 'lambda vars e))

(define (lambda-vars e)
  (cadr e))

(define (lambda-expr e)
  (caddr e))

;; lambda-rec

(define (lambda-rec? t)
  (and (tagged-tuple? 'lambda-rec 3 t)
       (list? (cadr t))
       (>= (length (cadr t)) 1)
       (andmap symbol? (cadr t))))

(define (lambda-rec-cons vars e)
  (list 'lambda-rec vars e))

(define (lambda-rec-expr e)
  (third e))

(define (lambda-rec-name e)
  (car (second e)))

(define (lambda-rec-vars e)
  (cdr (second e)))

;; applications

(define (app? t)
  (and (list? t)
       (> (length t) 0)))

(define (app-cons proc args)
  (cons proc args))

(define (app-proc e)
  (car e))

(define (app-args e)
  (cdr e))

;; expressions

(define (expr? t)
  (or (const? t)
      (and (op? t)
           (andmap expr? (op-args t)))
      (and (let? t)
           (expr? (let-expr t))
           (expr? (let-def-expr (let-def t))))
      (and (cons? t)
           (expr? (cons-fst t))
           (expr? (cons-snd t)))
      (and (car? t)
           (expr? (car-expr t)))
      (and (cdr? t)
           (expr? (cdr-expr t)))
      (and (pair?? t)
           (expr? (pair?-expr t)))
      (my-null? t)
      (and (null?? t)
           (expr? (null?-expr t)))
      (and (if? t)
           (expr? (if-cond t))
           (expr? (if-then t))
           (expr? (if-else t)))
      (and (cond? t)
           (andmap (lambda (c)
                      (and (expr? (cond-clause-cond c))
                           (expr? (cond-clause-expr c))))
                   (cond-clauses t)))
      (and (lambda? t)
           (expr? (lambda-expr t)))
      (and (lambda-rec? t)
           (expr? (lambda-rec-expr t)))
      (var? t)
      (and (app? t)
           (expr? (app-proc t))
           (andmap expr? (app-args t)))))

;; environments

(define empty-env
  null)

(define (add-to-env x v env)
  (cons (list x v) env))

(define (find-in-env x env)
  (cond [(null? env) (error "undefined variable" x)]
        [(eq? x (caar env)) (cadar env)]
        [else (find-in-env x (cdr env))]))

;; closures

(define (closure-cons xs expr env)
  (list 'closure xs expr env))

(define (closure? c)
  (and (list? c)
       (= (length c) 4)
       (eq? (car c) 'closure)))

(define (closure-vars c)
  (cadr c))

(define (closure-expr c)
  (caddr c))

(define (closure-env c)
  (cadddr c))

;; closure-rec

(define (closure-rec? t)
  (tagged-tuple? 'closure-rec 5 t))

(define (closure-rec-name e)
  (second e))

(define (closure-rec-vars e)
  (third e))

(define (closure-rec-expr e)
  (fourth e))

(define (closure-rec-env e)
  (fifth e))

(define (closure-rec-cons f xs e env)
  (list 'closure-rec f xs e env))

;; evaluator

(define (bool->val b)
  (if b 'true 'false))

(define (val->bool s)
  (cond [(eq? s 'true)  true]
        [(eq? s 'false) false]
        [else (error "could not convert symbol to bool")]))

(define (eval-env e env)
  (cond [(const? e)
         e]
        [(op? e)
         (apply (op->proc (op-op e))
                (map (lambda (a) (eval-env a env))
                     (op-args e)))]
        [(let? e)
         (eval-env (let-expr e)
                   (env-for-let (let-def e) env))]
        [(my-null? e)
         null]
        [(cons? e)
         (cons (eval-env (cons-fst e) env)
               (eval-env (cons-snd e) env))]
        [(car? e)
         (car (eval-env (car-expr e) env))]
        [(cdr? e)
         (cdr (eval-env (cdr-expr e) env))]
        [(pair?? e)
         (bool->val (pair? (eval-env (pair?-expr e) env)))]
        [(null?? e)
         (bool->val (null? (eval-env (null?-expr e) env)))]
        [(if? e)
         (if (val->bool (eval-env (if-cond e) env))
             (eval-env (if-then e) env)
             (eval-env (if-else e) env))]
        [(cond? e)
         (eval-cond-clauses (cond-clauses e) env)]
        [(var? e)
         (find-in-env (var-var e) env)]
        [(lambda? e)
         (closure-cons (lambda-vars e) (lambda-expr e) env)]
        [(lambda-rec? e)
         (closure-rec-cons (lambda-rec-name e)
                           (lambda-rec-vars e)
                           (lambda-rec-expr e)
                           env)]
        [(app? e)
         (apply-closure
           (eval-env (app-proc e) env)
           (map (lambda (a) (eval-env a env))
                (app-args e)))]))

(define (eval-cond-clauses cs env)
  (if (null? cs)
      (error "no true clause in cond")
      (let ([cond (cond-clause-cond (car cs))]
            [expr (cond-clause-expr (car cs))])
           (if (val->bool (eval-env cond env))
               (eval-env expr env)
               (eval-cond-clauses (cdr cs) env)))))

(define (apply-closure c args)
  (cond [(closure? c)
         (eval-env
            (closure-expr c)
            (env-for-closure
              (closure-vars c)
              args
              (closure-env c)))]
        [(closure-rec? c)
         (eval-env
           (closure-rec-expr c)
           (add-to-env
            (closure-rec-name c)
            c
            (env-for-closure
              (closure-rec-vars c)
              args
              (closure-rec-env c))))]))

(define (env-for-closure xs vs env)
  (cond [(and (null? xs) (null? vs)) env]
        [(and (not (null? xs)) (not (null? vs)))
         (add-to-env
           (car xs)
           (car vs)
           (env-for-closure (cdr xs) (cdr vs) env))]
        [else (error "arity mismatch")]))

(define (env-for-let def env)
  (add-to-env
    (let-def-var def)
    (eval-env (let-def-expr def) env)
    env))

(define (eval e)
  (eval-env e empty-env))

(define (my-eval-arith e)
  ;; Ewaluator wyrażeń aryytmetycznych napisany w języku z wykładu
  (eval `(let (my-binop-cons (lambda (op l r) (cons op (cons l (cons r null)))))
           ;; Kontruktor wyrażeń. Wyrażenie to trzyelementowa lista składająca się z operatora i 2 podwyrażeń
           ;; listy w języku z wykładu tworzone są za pomocą formy `(cons a b) zakończonej symbolem `null
           ;; Selektory lewego i prawego podwyrażenia oraz operatora
           ;; Selektory stworzone są za pomocą formy `(car e) oraz `(cdr e)
           (let (my-binop-left (lambda (e) (car (cdr e))))
             (let (my-binop-right (lambda (e) (car (cdr (cdr e)))))
               (let (my-binop-op (lambda (e) (car e)))
                 ;; Procedura sprawdzająca, czy dany element jest operatorem
                 ;; Procedura stworzona jest za pomocą formy `(lambda .. )
                 ;; Forma ta ewaluuje się do domknięcia, które aplikujemy do argumentu
                 ;; Jeśli argument jest jedym z symboli +,-,*,/ (reprezentowanych za pomocą formy `(quote x)
                 ;; wyrażenie wylicza się do `true, wpp do `false
                 ;; Symbole porównywane są za pomocą formy specjalnej `(eq . args)
                 (let (my-op? (lambda (e) (cond ((eq? (quote +) e) true)
                                                ((eq? (quote -) e) true)
                                                ((eq? (quote *) e) true)
                                                ((eq? (quote /) e) true)
                                                (#t false))))
                   ;; Procedura sprawdzająca, czy dany element jest wyrażeniem
                   ;; Domknięcie zaaplikowane do elementu wylicza się do `true, gdy element jest
                   ;; 3-elementową listą (czyli 3 zagnieżdżonymi consami) oraz pierwszy element to operator
                   ;; wpp wylicza się do `false
                   (let (my-binop? (lambda (e) (if (pair? e)
                                                   (if (pair? (cdr e))
                                                       (if (pair? (cdr (cdr e)))
                                                           (my-op? (car e))
                                                           false)
                                                       fale)
                                                   false)))
                     ;; Procedura przetwarzająca symbol (z języka z wykładu) operacji arytmetycznej
                     ;; na wyrażenie binop w języku z wykładu
                     ;; Lambda wylicza się do odpowiedniego domknięcia, które zaaplikowane do dwóch argumentów
                     ;; tworzy wyrażenie `(op l r), które może już zostać wyliczone w naszym języku
                     (let (my-op->op (lambda (e) (cond ((eq? (quote +) e) (lambda (x y) (+ x y)))
                                                       ((eq? (quote -) e) (lambda (x y) (- x y)))
                                                       ((eq? (quote *) e) (lambda (x y) (* x y)))
                                                       ((eq? (quote /) e) (lambda (x y) (/ x y))))))
                       ;; Procedura do ewaluacji wyrażeń arytmetycznych
                       ;; Procedura napisana jest za pomocą formy lambda-rec
                       ;; jeśli przetwarzane wyrażenie jest pewłnym wyrażeniem, obliczane są (rekurencyjnie) 
                       ;; jego podwyrażenia, a następnie obliczana jest jego wartość, przetwarzając go do postaci
                       ;; `(op l r), która zostaje obliczona w naszym jezyku (za pomocą proceduray eval)
                       ;; jeśli wyrażenie nie spełnia my-binop? oznacza, że jest liczbą i można ją zwrócić bez obliczeń
                       (let (my-eval-arith (lambda-rec (my-eval-arith e)
                                                       (if (my-binop? e) ((my-op->op (my-binop-op e))
                                                                          (my-eval-arith (my-binop-left e))
                                                                          (my-eval-arith (my-binop-right e)))
                                                           e)))
                         ;; Wywołanie procedura do ewaluacji wyrażeń
                         ;; wyrażenie otrzymane w argumencie jest odcytowana (za pomocą ,), gdyż chcemy obliczyć
                         ;; wartość tego wyrażenia, a nie wartość symbolu `e
                         (my-eval-arith ,e)
                         ))))))))))


;; TESTY


(define (test)
  (and
   (= (my-eval-arith '(cons
                      (quote +)
                      (cons
                       (cons (quote +) (cons 1 (cons 2 null)))
                       (cons
                        (cons
                         (quote *)
                         (cons
                          (cons (quote -) (cons 4 (cons 2 null)))
                          (cons
                           (cons (quote /) (cons 3 (cons 1 null)))
                           null)))
                        null)))) 9)
   (= (my-eval-arith '(cons (quote +) (cons 3 (cons 4 null)))) 7)
   (= (my-eval-arith '(cons
                       '-
                       (cons
                        (cons
                         '-
                         (cons
                          (cons '* (cons 29 (cons 32 null)))
                          (cons (cons '* (cons 19 (cons 42 null))) null)))
                        (cons
                         (cons
                          '*
                          (cons
                           (cons '- (cons 33 (cons 20 null)))
                           (cons (cons '- (cons 4 (cons 7 null))) null)))
                         null)))) 169)
   (= (my-eval-arith '(cons
                       '+
                       (cons
                        (cons
                         '+
                         (cons
                          (cons '- (cons 26 (cons 7 null)))
                          (cons (cons '* (cons 17 (cons 45 null))) null)))
                        (cons
                         (cons
                          '*
                          (cons
                           (cons '+ (cons 16 (cons 47 null)))
                           (cons (cons '* (cons 31 (cons 26 null))) null)))
                         null)))) 51562)
   (= (my-eval-arith '(cons
                       '*
                       (cons
                        (cons '* (cons 42 (cons 40 null)))
                        (cons (cons '- (cons 37 (cons 49 null))) null)))) -20160)
   (= (my-eval-arith '(cons
                       '-
                       (cons
                        (cons '- (cons 19 (cons 48 null)))
                        (cons (cons '+ (cons 48 (cons 43 null))) null)))) -120)
      ))

(define (w op l r)
  ;; procedura pomocnicza tworząca wyrażenie jako lista w naszym języku (czyli złożenie `cons)
  ;; wyrażenie ma postać '(cons '+ (cons 1 (cons 2 null))) zamiast '(cons (quote +) (cons 1 (cons 2 null)))
  ;; lecz (eval `(eq? (quote +) '+)) wylicza się do `true, ponieważ (eval `(quote +)) wylicza się do ''+
  (let ((op (list `quote op)))
  (cons-cons op (cons-cons l (cons-cons r `null)))))

(define (random-op)
  ;; procedura generująca losowy operator (w postci symbolu)
  (let ((n (random 4)))
    (define (random-elem n l)
      (cond [(null? l) (error "Index out of range")]
            [(= n 0) (car l)]
            [else (random-elem (- n 1) (cdr l))]))
    (random-elem n (list `+ `- `* `/))))

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
      (w (random-op2) (random-arith (- n 1)) (random-arith (- n 1)))))

(define (test2 n)
  ;; procedura generująca wyrażenie o "głębokości" n i obliczajaca je
  ;; najlepiej testować dla n <= 15
  ;; wyrażenie o "głębokości" n ma 2^n wyrażeń elementarnych (liczb), stąd
  ;; wyrażenie dla n = 13 składa się z ponad 8000 liczb
  (let ((arith (random-arith n)))
    (begin (display "Wyrażenie wygenerowane")
           (newline)
           (my-eval-arith arith))))

