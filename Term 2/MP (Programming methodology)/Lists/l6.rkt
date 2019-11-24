#lang racket

;; Kod z wykładu

;; arithmetic expressions

(define (const? t)
  (number? t))

(define (binop? t)
  (and (list? t)
       (= (length t) 3)
       (member (car t) '(+ - * /))))

(define (binop-op e)
  (car e))

(define (binop-left e)
  (cadr e))

(define (binop-right e)
  (caddr e))

(define (binop-cons op l r)
  (list op l r))

(define (arith-expr? t)
  (or (const? t)
      (and (binop? t)
           (arith-expr? (binop-left  t))
           (arith-expr? (binop-right t)))))

;; calculator

(define (op->proc op)
  (cond [(eq? op '+) +]
        [(eq? op '*) *]
        [(eq? op '-) -]
        [(eq? op '/) /]))

(define (eval-arith e)
  (cond [(const? e) e]
        [(binop? e)
         ((op->proc (binop-op e))
            (eval-arith (binop-left  e))
            (eval-arith (binop-right e)))]))

;; let expressions

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
       (let-defs? (cadr t))))

(define (let-defs? t)
  (and (list? t)
       (andmap let-def? t)))

(define (let-defs e)
  (cadr e))

(define let-def car)

(define (let-expr e)
  (caddr e))

(define (let-cons def e)
  (list 'let def e))

(define (var? t)
  (symbol? t))

(define (var-var e)
  e)

(define (var-cons x)
  x)

(define (arith/let-expr/if-zero? t)
  (or (const? t)
      (and (oper? t)
           (andmap arith/let-expr/if-zero? (cdr t)))
      (and (if-zero? t)
           (arith/let-expr/if-zero? (second t))
           (arith/let-expr/if-zero? (third t))
           (arith/let-expr/if-zero? (fourth t)))
      (and (let? t)
           (arith/let-expr/if-zero? (let-expr t))
           (arith/let-expr/if-zero? (let-defs (let-def-expr t))))
      (var? t)))

;; evalation via substitution

(define (subst e x f)
  (cond [(const? e) e]
        [(binop? e)
         (binop-cons
           (binop-op e)
           (subst (binop-left  e) x f)
           (subst (binop-right e) x f))]
        [(let? e)
         (let-cons
           (let-def-cons
             (let-def-var (let-defs e))
             (subst (let-def-expr (let-defs e)) x f))
           (if (eq? x (let-def-var (let-defs e)))
               (let-expr e)
               (subst (let-expr e) x f)))]
        [(var? e)
         (if (eq? x (var-var e))
             f
             (var-var e))]))

(define (eval-subst e)
  (cond [(const? e) e]
        [(binop? e)
         ((op->proc (binop-op e))
            (eval-subst (binop-left  e))
            (eval-subst (binop-right e)))]
        [(let? e)
         (eval-subst
           (subst
             (let-expr e)
             (let-def-var (let-defs e))
             (eval-subst (let-def-expr (let-defs e)))))]
        [(var? e)
         (error "undefined variable" (var-var e))]))

;; evaluation via environments

(define empty-env
  null)

(define (add-to-env x v env)
  (cons (list x v) env))

(define (find-in-env x env)
  (cond [(null? env) (error "undefined variable" x)]
        [(eq? x (caar env)) (cadar env)]
        [else (find-in-env x (cdr env))]))

(define (eval-env e env)
  (cond [(const? e) e]
        [(oper? e) (apply (op->proc (car e))
                            (map (lambda (q) (eval-env q env))
                                 (cdr e)))]
        [(let? e)
         (eval-env
           (let-expr e)
           (env-for-let (let-defs e) env))]
        [(if-zero? e) (if (= (eval-env (if-zero-exp e) env) 0)
                          (eval-env (if-zero-inst-true e) env)
                          (eval-env (if-zero-inst-false e) env))]
        [(var? e) (find-in-env (var-var e) env)]))

(define (env-for-let def env)
  ;; można to mapem zrobić
  (define (f def my-env)
    (if (null? def)
        my-env
        (f (cdr def) (add-to-env (let-def-var (let-def def))
                                 (eval-env (let-def-expr (let-def def)) env)
                                  my-env))))
  (append (f def empty-env) env))

(define (eval e)
  (eval-env e empty-env))


;; Lista 6

;; Cw 1

(define (arith->rpn2 exp)
  ;; niepoprawne, generuje nieużytki
  (if (const? exp)
      (list exp)
      (append (append (arith->rpn2 (binop-left exp))
            (arith->rpn2 (binop-right exp))
            (list (binop-op exp))))))

(define (arith->rpn3 exp)
  ;; niepoprawne, generuje nieużytki
  (define (helper e)
    (if (const? e)
        e
        (list  (arith->rpn2 (binop-left exp))
               (arith->rpn2 (binop-right exp))
               (binop-op exp))))
  (flatten (helper exp)))

(define (arith->rpn exp)
  (define (helper e acc)
    (if (const? e)
        (cons e acc)
        (helper (binop-left e) (helper (binop-right e) (cons (binop-op e) acc)))))
  (helper exp null))



;;Cw 2

;; (provide (all-defined-out))

(define (stack? s)
  (list? s))

(define (push x s)
  (cons x s))

(define (pop s)
  (if (null? s)
      (error "Empty stack" s)
      (cons (car s) (cdr s))))

;; Cw 3

(define (op? o)
  (member o '(+ - * /)))

(define (eval-rpn exp)
  (define (helper e s)
    (cond [(null? e) (if (null? (cdr (pop s)))
                         (car (pop s))
                         (error "Bad syntax" exp))]
          [(number? (car e)) (helper (cdr e) (push (car e) s))]
          [(op? (car e)) (let ((a (car (pop s)))
                               (b (car (pop (cdr (pop s))))))
                           (helper (cdr e) (push ((op->proc (car e)) b a) (cdr (pop (cdr (pop s)))))))]))
  (helper exp null))


;; Cw 5

(define (if-zero? e)
  (and (list? e)
       (eq? (car e) `if-zero)
       (= (length e) 4)))

(define (if-zero-cons exp inst1 inst2)
  (list `if-zero exp inst1 inst2))

(define (if-zero-exp e)
  (second e))

(define (if-zero-inst-true e)
  (third e))

(define (if-zero-inst-false e)
  (fourth e))


;; Cw 6

(define (oper? t)
  (and (pair? t)
       (op? (car t))
       (list? (cdr t))))

(define (oper-op e)
  (car e))

(define (oper-args e)
  (cdr e))

(define (oper-cons op l)
  (cons op l))


;; Cw 7
;; Odpowiednie procedury z wykładu zostały edytowane

