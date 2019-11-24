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

;; procedura sprawdzająca, czy wyrażenie jest pustym środowiskiem
(define empty-env? null?)

;; definicja zmiennej i jej wartości ze zwykłego leta tagowana jest symbolem `eager
(define (add-to-env x v env)
  (cons (list `eager x v) env))

;; definicja zmiennej i jej wyrażenia z lazy-leta tagowana jest symbolem `lazy
(define (add-lazy-def-to-env x v let-env env)
  (cons (list `lazy x v let-env) env))

(define (lazy-env-def? e)
  ;; procedura sprawdzająca, czy pojedyncza definicja pochodzi z lazy-leta
  (and (list? e)
       (= 4 (length e))
       (eq? (car e) `lazy)))

;; selektor zmiennej z pojedynczej definicji w środowisku
(define def-var cadr)

;; selektor wartości (lub wyrażenia) z pojedynczej definicji w środowisku
(define def-val caddr)

;; selektor środowiska (przypisanego podczas definiowania zmiennej za pomocą lazy-leta)
;; z pojedynczej definicji
(define lazy-def-env cadddr)

(define (find-in-env x env)
  ;; procedura szukająca wartość danej zmiennej w środowisku
  (if (empty-env? env)
      ;; jeśli srodowisko jest puste nie znajduje się w nim poszukiwana zmienna
      (error "undefined variable" x)
      ;; jeśli środowisko nie jest puste rozpatrywana jest jego pierwsza definicja
      (let ((def (car env)))
        (if (eq? (def-var def) x)
            ;; jeśli zmienna w tej definicji jest równa x`owi, to:
            (if (lazy-env-def? def)
                ;; w przypadku, gdy definicja pochodzi z lazy leta obliczana jest jej wartość
                ;; w środowisku przypisanym do wyrażenia w momencie definiowania lazy-leta
                (eval-env (def-val def) (lazy-def-env def))
                ;; w przeciwnym przypadku zwracana jest tej wartość
                ;; (obliczona już podczas definicowania zmiennej zwykłym letem)
                (def-val def))
            ;; jeśli zmienna w definicji nie jest tą, której wartości poszukujemy przeglądany jest ogon środowiska
            (find-in-env x (cdr env))))))

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
        [(lazy-let? e)
         ;; wartością lazy-let wyrażenia jest wartość jego wyrażenia w środowisku zmodyfikowanym przez env-for-lazy-let
         (eval-env (lazy-let-expr e)
                   (env-for-lazy-let (lazy-let-def e) env))]
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

(define (env-for-lazy-let def env)
  ;; procedura rozszerza podane środowisko dodając do niego nową zmienną wraz z jego wyrażeniem
  ;; oraz środowiskiem aktualnym w momencie definiowania wyrażenia z definicji lazy-leta
  (add-lazy-def-to-env
   (let-def-var def)
   (let-def-expr def)
   env
   env))

(define (eval e)
  (eval-env e empty-env))

;; lezy-let
;; wyrażenia lazy-let różnią się od wyrażeń let jedynie tagiem

(define (lazy-let? e)
  (and (tagged-tuple? 'lazy-let 3 e)
       (let-def? (cadr e))))

(define (lazy-let-def e)
  (cadr e))

(define (lazy-let-expr e)
  (caddr e))

(define (lezy-let-cons def e)
  (list 'lazy-let def e))

(define (test)
  ;; pomijam testy złożoności czasowej mojego rozwiązania dla dużych danych, gdyż dokonane modyfikacje
  ;; nie wpływają w znacznym stopniu na czas obliczeń (a przynajmniej nie w większym, niż jest to niezbędne,
  ;; obliczenia mogą zająć więcej czasu, niż przed modyfikacją, gdyż wartość zmiennej z lazy-leta
  ;; obliczana jest na nowo za każdym razem, gdy jest wywoływana, a nie jednorazowo podczas jej definiowania
  ;; są to jednak założenia tego rozwiazania, których nie można zmienić / przyspieszyć)
  (and (= 120 (eval `((lambda-rec (fact n) (lazy-let (f (* n (fact (- n 1)))) (if (= n 0) 1 f))) 5)))
       (= 10 (eval `(let (x 5) (lazy-let (y (* x 2)) (let (x 20) y)))))
       (= 5 (eval `(lazy-let (x (/ 1 0)) 5)))
       (= 42 (eval `(lazy-let (x 42) x)))
       (= 10 (eval `(lazy-let (x (lambda (y) (* y 2))) (x 5))))
       (= 5 (eval `(lazy-let (x (lazy-let (y 5) y)) x)))
       (= 10 (eval `(lazy-let (x 5) (lazy-let (x 10) x))))
       (= 20 (eval `(lazy-let (x 10) (lazy-let (x (* 2 x)) x))))
       ))

(test)
