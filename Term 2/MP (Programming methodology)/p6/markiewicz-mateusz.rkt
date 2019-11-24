#lang racket

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

(define (op->proc op)
  (cond [(eq? op '+) +]
        [(eq? op '*) *]
        [(eq? op '-) -]
        [(eq? op '/) /]))

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

(define (var? t)
  (symbol? t))

(define (var-var e)
  e)

(define (var-cons x)
  x)

(define (hole? t)
  (eq? t 'hole))

(define (arith/let/holes? t)
  (or (hole? t)
      (const? t)
      (and (binop? t)
           (arith/let/holes? (binop-left  t))
           (arith/let/holes? (binop-right t)))
      (and (let? t)
           (arith/let/holes? (let-expr t))
           (arith/let/holes? (let-def-expr (let-def t))))
      (var? t)))

(define (num-of-holes t)
  (cond [(hole? t) 1]
        [(const? t) 0]
        [(binop? t)
         (+ (num-of-holes (binop-left  t))
            (num-of-holes (binop-right t)))]
        [(let? t)
         (+ (num-of-holes (let-expr t))
            (num-of-holes (let-def-expr (let-def t))))]
        [(var? t) 0]))

(define (arith/let/hole-expr? t)
  (and (arith/let/holes? t)
       (= (num-of-holes t) 1)))

(define (hole-context e)
  ;; procedura zwracająca zmienne zwiazane w miejscu występowania struktury hole
  (define (serch-for-hole expr acc)
    ;; Procedura pomocnicza szukająca wystapienia dziuru w formule
    ;; W akumulatorze gromadzone są zmienne związane w miejscu obecnie sprawdzanym przez procedurę
    ;; Jeśli odnaleźliśmy dzirę wystarczy zwróci przechowywane zmienne
    ;; Jeśli rozpatrywane wyrażenie jest stałą lub zmienną zwracany jest fałsz
    ;; oznacza to, że w tym miejscu nie ma dziury i należy szukać w innym
    ;; Jeśli rozpatrywane wyrażenie jest operacją binarną procedura szuka dziury najpierw w lewym
    ;; argumencie wyrażenia, a jeśli jej nie znajdzie to w prawym argumencie wyrażenia
    ;; Jeśli rozpatrywane wyrażenie jest let-wyrażeniem to procedura szuka dziury w definicji zmiennej
    ;; let wyrażenia, a jeśli jej nie znajdzie dodaje do listy zadeklarownych zmiennych nową, która
    ;; została zadeklarowana przez rozpatrywanego leta i szuka dziury w wyrażeniu let-wyrażenia
    ;; nowa zmienna zostaje dodana do listy tylko, gdy jeszcze się na niej nie znajduje
    (cond [(hole? expr) acc]
          [(or (const? expr)
               (var? expr)) #f]
          [(binop? expr) (let ((serch-for-hole-left (serch-for-hole (binop-left expr) acc)))
                           (if serch-for-hole-left
                               serch-for-hole-left
                               (serch-for-hole (binop-right expr) acc)))]
          [(let? expr) (let ((serch-for-hole-def-expr (serch-for-hole (let-def-expr (let-def expr)) acc)))
                         (if serch-for-hole-def-expr
                             serch-for-hole-def-expr
                             (serch-for-hole (let-expr expr) (if (member (let-def-var (let-def expr)) acc)
                                                                 acc
                                                                 (cons (let-def-var (let-def expr)) acc)))))]))
  ;; formuła podana w argumencie hole-context musi być spełniać predykat arith/let/hole-expr?
  ;; jeśli powyższe założenie nie jest spełnione zgłaszany jest błąd
  (if (not (arith/let/hole-expr? e))
      (error "Podano złe wyrażenie" e)
      (serch-for-hole e `())))
      

(define (test)
  ;; testy procedury hole-context
  (define (equal-lists? l1 l2)
    ;; procedura pomocnicza sprawdzajaca, czy dwa wyniki w postaci list są sobie równe
    ;; procedura uwzględnia fakt, że kolejność występowania zmiennych na liście nie jest istotny
    (equal? (sort l1 symbol<?) (sort l2 symbol<?)))
  (and (equal-lists? (list)
               (hole-context (binop-cons `+ 3 `hole)))
       (equal-lists? (list)
               (hole-context (binop-cons `* `hole 3)))
       (equal-lists? (list)
               (hole-context `hole))
       (equal-lists? (list)
               (hole-context (let-cons (let-def-cons `x `hole) 3)))
       (equal-lists? (list `x `y)
               (hole-context (binop-cons `+ (let-cons (let-def-cons `x `3) `x)
                                            (let-cons (let-def-cons `x `3) (let-cons (let-def-cons `y `6) `hole)))))
       (equal-lists? (list `x `y `z)
               (hole-context (let-cons (let-def-cons `x 3) (let-cons (let-def-cons `y 4) (let-cons (let-def-cons `z 5) `hole)))))
       (equal-lists? (list `x)
               (hole-context (let-cons (let-def-cons `x 3) (let-cons (let-def-cons `x 4) (let-cons (let-def-cons `x 5) (binop-cons `+ 3 `hole))))))
       (equal-lists? (list `x)
               (hole-context (let-cons (let-def-cons `x 3) (let-cons (let-def-cons `x `x) (let-cons (let-def-cons `x `x) `hole)))))
       (equal-lists? (list `x `y `z)
               (hole-context (let-cons (let-def-cons `x 3) (let-cons (let-def-cons `y 4) (let-cons (let-def-cons `z 5) (binop-cons `+ 3 `hole))))))))


;; (test)