#lang racket
(require racket/contract)
(require quickcheck)

;; Cw 1

#|
;; kontrakt gwarantuje to
(define/contract (id x)
  (let ([a (new-∀/c 'a)])
    (-> a a))
  x)
|#

(define/contract (suffixes xs)
  (let ([a (new-∀/c 'a)])
  (-> (listof a) (listof (listof a))))
  (if (null? xs)
      (cons null null)
      (cons xs (suffixes (cdr xs)))))
      
;; Cw 2

(define/contract (dist x y)
  (-> number? number? number?)
  (abs (- x y)))

(define/contract (average x y)
  (-> number? number? number?)
  (/ (+ x y) 2))

(define/contract (square x)
  (-> number? number?)
  (* x x))

(define/contract (sqrt x)
  (->i ([val positive?])
        [result positive?]
        #:post (result val)
        (< (dist (square result) val) 0.001))
  ;; lokalne definicje
  ;; poprawienie przybliżenia pierwiastka z x
  (define (improve approx)
    (average (/ x approx) approx))
  ;; nazwy predykatów zwyczajowo kończymy znakiem zapytania
  (define (good-enough? approx)
    (< (dist x (square approx)) 0.0001))
  ;; główna procedura znajdująca rozwiązanie
  (define (iter approx)
    (cond
      [(good-enough? approx) approx]
      [else                  (iter (improve approx))]))
  
  (iter 1.0))

;; Cw 3
#|
(define/contract (filter f xs)
  (let ([a (new-∀/c 'a)]) 
    (-> (-> a boolean?) (listof a) (listof a)))
  (cond [(null? xs) null]
        [(f (car xs)) (cons (car xs) (filter f (cdr xs)))]
        [else (filter f (cdr xs))]))
|#

(define/contract (filter f xs)
  (and/c 
   (let ([a (new-∀/c 'a)]) 
     (-> (-> a boolean?) (listof a) (listof a)))
   (->i ([p (-> any/c boolean?)]
         [ys (listof any/c)])
        (result (listof any/c))
        #:post (result p)
        (andmap p result)))
  (cond [(null? xs) null]
        [(f (car xs)) (cons (car xs) (filter f (cdr xs)))]
        [else (filter f (cdr xs))]))

;; Cw 4


(define-signature monoid^
   ((contracted
      [elem? (-> any/c boolean?)]
      [neutral elem?]
      [oper (-> elem? elem? elem?)])))

#|
(define-unit monoid-1@
  (import)
  (export monoid^)
  
  (define (elem? e)
    (exact-integer? e))
  
  (define neutral 0)
  (define (oper x y)
    (+ x y)))

(define-values/invoke-unit/infer monoid-1@)
|#

(define-unit monoid-2@
  (import)
  (export monoid^)
  
  (define (elem? e)
    (list? e))
  
  (define neutral `())
  (define (oper x y)
    (append x y)))

(define-values/invoke-unit/infer monoid-2@)


;; Cw 5

(define (is-neutral? e)
  (property ([n (arbitrary-list arbitrary-integer)])
            (and (equal? (oper n e) n)
                 (equal? (oper e n) n))))

(quickcheck (is-neutral? neutral))

(quickcheck ((lambda (op) (property ([n1 (arbitrary-list arbitrary-integer)]
                                     [n2 (arbitrary-list arbitrary-integer)]
                                     [n3 (arbitrary-list arbitrary-integer)])
                                    (equal? (op n1 (op n2 n3)) (op (op n1 n2) n3) ))) oper) )
