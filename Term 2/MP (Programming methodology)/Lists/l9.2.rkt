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

; arith and bools

(define (const? t)
  (number? t))

(define (op? t)
  (and (list? t)
       (member (car t) '(% + - * / = > >= < <=))))

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
        [(eq? op '%) modulo]))

(define (var? t)
  (symbol? t))

(define (eval-arith e m)
  (cond [(var? e) (get-mem e m)]
        [(op? e)
         (apply
          (op->proc (op-op e))
          (map (lambda (x) (eval-arith x m))
               (op-args e)))]
        [(const? e) e]))

;;

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

;;

(define (eval e m)
  (cond [(assign? e)
         (set-mem
          (assign-var e)
          (eval-arith (assign-expr e) m)
          m)]
        [(if? e)
         (if (eval-arith (if-cond e) m)
             (eval (if-then e) m)
             (eval (if-else e) m))]
        [(while? e)
         (if (eval-arith (while-cond e) m)
             (eval e (eval (while-expr e) m))
             m)]
        [(++? e) (set-mem (cadr e)
                          (+ 1 (eval-arith (cadr e) m))
                          m)]
        [(--? e) (set-mem (cadr e)
                          (- (eval-arith (cadr e) m) 1)
                          m)]
        [(for? e) (eval (list (for-assign e) (list `while (for-cond e) (list (for-expr e) (for-inc e)))) m)]










        
        [(block? e)
         (if (null? e)
             m
             (eval (cdr e) (eval (car e) m)))]))

(define (run e)
  (eval e empty-mem))

;;

(define fact10
  '( (i := 10)
     (r := 1)
     (while (> i 0)
       ( (r := (* i r))
         (i := (- i 1)) ))))

(define (computeFact10)
  (run fact10))

;; Lista 9

;; Zad 3

(define (fib n)
  `( (a := 0)
     (b := 1)
     (n := ,n)
     (while (> n 0)
        ( (h := a)
          (a := b)
          (b := (+ a h))
          (n := (- n 1))))))

(define (Fibonacci n)
  (cdar (run (fib n))))

;(Fibonacci 10)

(define (prime n)
  `( (res := 0)
     (i := 2)
     (n := ,n)
     (while (> n 0)
       ( (j := 2)
         (divs := 0)
         (while (<= (* j j) i)
                ((if (= (% i j) 0)
                    (divs := (+ divs 1))
                    ())
                (j := (+ j 1))))
         (if (= divs 0)
             ( (res := (+ res i))
               (n := (- n 1)))
             ())
         (i := (+ i 1))))))

(define (prime2 n)
  `( (res := 0)
     (i := 2)
     (n := ,n)
     (while (> n 0)
            ( (j := 2)
              (divs := 0)
              (while (<= (* j j) i)
                     ( (d := (/ i j))
                       (while (> d 0)
                              (d := (- d 1)))
                       (if (= d 0)
                           (divs := (+ divs 1))
                           ())
                       (j := (+ j 1))))
              (if (= divs 0)
                  ( (res := (+ res i))
                    (n := (- n 1)))
                  ())
              (i := (+ i 1))))))
             
(define (sum-of-n-prime n)
  (cdar (run (prime2 n))))
        

(define (sum n)
  `( (res := 0)
     (n := ,n)
     (while (> n 0)
        ( (n := (- n 1))
          (res := (+ res n))))))

(define (sum-of-first-n-nats n)
  (cdar (run (sum n))))

;(sum-of-first-n-nats 5)
           
(define (++? e)
  (and (list? e)
       (= 2 (length e))
       (eq? (car e) `++)))

(define (--? e)
  (and (list? e)
       (= 2 (length e))
       (eq? (car e) `--)))


(define (for? e)
  (and (list? e)
       (= 5 (length e))
       (eq? (car e) `for)))
                
(define (for-assign e)
  (second e))

(define (for-cond e)
  (third e))

(define (for-inc e)
  (fourth e))

(define (for-expr e)
  (fifth e))

;(run `( (i := 0)
 ;       (for (j := 0) (< j 10) (j := (+ j 1)) (i := j))))


(define (translate t)
  (cond [(assign? t) t]
        [(if? t) (list `if (if-cond t) (translate (if-then t)) (translate (if-else t)))]
        [(while? t) (list `while (while-cond t) (translate (while-expr t)))]
        [(++? t) t]
        [(--? t) t]
        [(for? t) (list (for-assign t) (list `while (for-cond t) (list (translate (for-expr t)) (for-inc t))))]
        [(block? t) (map translate t)]))

;(translate `( (i := 0)
;              (for (j := 0) (< j 10) (j := (+ j 1)) (i := j))))
