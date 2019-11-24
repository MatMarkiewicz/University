#lang racket

;; Lista 7

(define (tagged-tuple? tag len p)
  (and (list? p)
       (= (length p) len)
       (eq? (car p) tag)))

(define (tagged-list? tag p)
  (and (pair? p)
       (eq? (car p) tag)
       (list? (cdr p))))

;; kod z wykładu:

;; arithmetic expressions

(define (const? t)
  (number? t))

(define (op? t)
  (and (list? t)
       (member (car t) '(+ - * / > < <= >= =))))

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
        [(eq? op '=) =]
        [(eq? op '>) >]
        [(eq? op '<) <]
        [(eq? op '<=) <=]
        [(eq? op '>=) >=]))

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
  (and (list? t)
       (= (length t) 3)
       (eq? (car t) 'let)
       (let-def? (cadr t))))

(define (let-def e)
  (cadr e))

(define (let-expr e)
  (caddr e))

(define (let-cons def e)
  (list 'let def e))

;; variables

(define (var? t)
  (and (symbol? t)
       (not (eq? t `null))))

(define (var-var e)
  e)

(define (var-cons x)
  x)

;; pairs

(define (cons? t)
  (and (list? t)
       (= (length t) 3)
       (eq? (car t) 'cons)))

(define (cons-fst e)
  (second e))

(define (cons-snd e)
  (third e))

(define (cons-cons e1 e2)
  (list 'cons e1 e2))

(define (car? t)
  (and (list? t)
       (= (length t) 2)
       (eq? (car t) 'car)))

(define (car-expr e)
  (second e))

(define (cdr? t)
  (and (list? t)
       (= (length t) 2)
       (eq? (car t) 'cdr)))

(define (cdr-expr e)
  (second e))

;; lambdas

(define (lambda? t)
  (and (list? t)
       (= (length t) 3)
       (eq? (car t) 'lambda)
       (list? (cadr t))
       (andmap symbol? (cadr t))))

(define (lambda-vars e)
  (cadr e))

(define (lambda-expr e)
  (caddr e))

;; applications

(define (app? t)
  (and (list? t)
       (> (length t) 0)
       (not (symbol? (car t)))))

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
      (var? t)
      (and (cons? t)
           (expr? (cons-fst t))
           (expr? (cons-snd t)))
      (and (car? t)
           (expr? (car-expr t)))
      (and (cdr? t)
           (expr? (cdr-expr t)))
      (and (lambda? t)
           (expr? (lambda-expr t)))
      (exp-null? t)
      (and (exp-null-pred? t)
           (expr? (exp-null-pred-expr t)))
      (and (exp-pair-pred? t)
           (expr? (exp-pair-pred-expr t)))
      (and (exp-list? t)
           (andmap expr? (exp-list-args t)))
      (exp-boolean? t)
      (and (exp-if? t)
           (expr? (exp-if-cond t))
           (expr? (exp-if-true t))
           (expr? (exp-if-false t)))
      (and (exp-cond? t)
           (andmap (lambda (c)
                     (and (expr? (cond-clause-cond c))
                          (expr? (cond-clause-expr c))))
                   (cond-clauses t)))
      (exp-list? t)
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

;; evaluator

(define (eval-env e env)
  (cond [(const? e) e]
        [(exp-null? e) null]
        [(op? e)
         (apply (op->proc (op-op e))
                (map (lambda (a) (eval-env a env))
                     (op-args e)))]
        [(let? e)
         (eval-env (let-expr e)
                   (env-for-let (let-def e) env))]
        [(cons? e)
         (cons (eval-env (cons-fst e) env)
               (eval-env (cons-snd e) env))]
        [(car? e)
         (car (eval-env (car-expr e) env))]
        [(cdr? e)
         (cdr (eval-env (cdr-expr e) env))]
        [(lambda? e)
         (closure-cons (lambda-vars e) (lambda-expr e) env)] 
        [(exp-null-pred? e) (null? (eval-env (exp-null-pred-expr e) env))]
        [(exp-pair-pred? e) (pair? (eval-env (exp-pair-pred-expr e) env))]
        [(exp-list? e) (eval-env (exp-list->cons (exp-list-args e)) env)]
        [(exp-boolean? e) e]
        [(exp-if? e) (if (eval-env (exp-if-cond e) env)
                         (eval-env (exp-if-true e) env)
                         (eval-env (exp-if-false e) env))]
        [(exp-cond? e)
         (eval-cond-clauses (cond-clauses e) env)]
        [(lambda-rec? e)
         (closure-rec-cons (lambda-rec-name e)
                           (lambda-rec-vars e)
                           (lambda-rec-expr e)
                           env)]
        #|
        [(exp-append? e) (eval-for-append (map (lambda (e) (if (exp-list? e)
                                                               (exp-list->cons (exp-list-args e))
                                                               (identity e)))
                                               (exp-append-args e)) env)]
        [(exp-map? e) (eval-for-map (exp-map-proc e)
                                    (map (lambda (e)
                                           (if (exp-list? e)
                                               (exp-list->cons (exp-list-args e))
                                               (identity e)))
                                         (exp-map-args e)) env)]
        [(exp-reverse? e) (reverse (eval-env (exp-reverse-list e) env))]
        |#
        [(var? e) (find-in-env (var-var e) env)]
        [(app? e)
         (apply-closure
          (eval-env (app-proc e) env)
          (map (lambda (a) (eval-env a env))
               (app-args e)))]))

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

(define (eval-cond-clauses cs env)
  (if (null? cs)
      (error "no true clause in cond")
      (let ([cond (cond-clause-cond (car cs))]
            [expr (cond-clause-expr (car cs))])
           (if (eval-env cond env)
               (eval-env expr env)
               (eval-cond-clauses (cdr cs) env)))))

(define (eval-for-append args env)
  (cond [(null? args) `null]
        [(= 1 (length args)) (car args)]
        [(eval-for-append (cons (exp-append-two-lists (first args) (second args)) (cddr args)) env)]))

(define (exp-append-two-lists xs ys)
  (if (exp-null? xs)
      ys
      (cons-cons (cons-fst xs) (exp-append-two-lists (cons-snd xs) ys))))

(define (eval-for-map proc args env)
  (if (exp-null? (car args))
      `null
      (cons-cons (eval-env (cons proc (map cons-fst args)) env)
                 (eval-for-map proc (map cons-snd args) env))))

;; Cw 3

(define (exp-null? e)
        (eq? e `null))
  
(define (exp-null-cons) `null)

(define (exp-null-pred? e)
  (and (list? e)
       (= 2 (length e))
       (eq? `null? (car e))))

(define (exp-null-pred-expr e)
  (second e))

(define (exp-null-pred-cons e)
  (list `null? e))

(define (exp-pair-pred? e)
  (and (list? e)
       (= 2 (length e))
       (eq? `pair? (car e))))

(define (exp-pair-pred-expr e)
  (second e))

(define (exp-pair-pred-cons e)
  (list `pair? e))

(define (exp-pair? e)
  (and (list? e)
       (= (length e) 3)
       (eq? (car e) `cons)))

(define (exp-list? e)
  (and (list? e)
       (> (length e) 0)
       (eq? `list (car e))))

(define (exp-list-cons l)
  (cons `list l))

(define (exp-list-args e)
  (cdr e))

(define (exp-list->cons l)
  (if (null? l)
      (exp-null-cons)
      (cons-cons (car l) (exp-list->cons (cdr l)))))

;; Cw 4

(define (exp-false-cons) #f)
(define (exp-true-cons) #t)
(define (exp-boolean? e)
  (boolean? e))

(define (exp-if? e)
  (and (list? e)
       (= 4 (length e))
       (eq? `if (car e))))

(define (exp-if-cond e)
  (second e))

(define (exp-if-true e)
  (third e))

(define (exp-if-false e)
  (fourth e))

(define (exp-if-cons cond true false)
  (list `if cond true false))

(define (cond-clause? t)
  (and (list? t)
       (= (length t) 2)))

(define (cond-clause-cond c)
  (first c))

(define (cond-clause-expr c)
  (second c))

(define (cond-claue-cons b e)
  (list b e))

(define (exp-cond? t)
  (and (tagged-list? 'cond t)
       (andmap cond-clause? (cdr t))))

(define (cond-clauses e)
  (cdr e))

(define (cond-cons cs)
  (cons 'cond cs))

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

;; Lista 8

;; Cw 2

;; append

(define (exp-append-cons . args)
  (cons `append args))

(define exp-append-args cdr)

(define (exp-append? e)
  (and (list? e)
       (> (length e) 0)
       (eq? (car e) `append)))

;; map

(define (exp-map-cons f . args)
  (cons `map (cons f args)))

(define exp-map-proc second)

(define exp-map-args cddr)

(define (exp-map? e)
  (and (list? e)
       (> (length e) 1)
       (eq? (car e) `map)))

(define (exp-reverse-cons xs)
  (list `reverse xs))

(define (exp-reverse? e)
  (and (list? e)
       (> (length e) 0)
       (eq? (car e) `reverse)))

(define (exp-reverse-list e)
  (second e))

#|
(define (testl . args)
  (exp-list->cons args))

(eval `(map (lambda (e1 e2) (+ e1 e2))
            (cons 1 (cons 2 (cons 3 null)))
            (cons 4 (cons 5 (cons 6 null)))
      ))
|#

;; append - pracownia

(eval `((lambda-rec (append l1 l2) (if (null? l1) l2 (cons (car l1) (append (cdr l1) l2)))) (cons 1 null) (cons 2 null)))
