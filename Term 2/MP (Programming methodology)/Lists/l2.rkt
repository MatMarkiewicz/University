#lang racket
(define square (lambda (x) (* x x)))

(define (inc x) (+ x 1))

(define (compose f g) (lambda (x) (f (g x))))

(define (repeated p n)
  (if (= n 0)
      identity
      (compose p (repeated p (- n 1)))))

(define (identity x)
  x)

;; ((repeated inc 2) 1)

(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))

(define (pi max)
  (* 2 (product (lambda (x) (/ (* 4 x x ) (* (- (* 2 x) 1) (+ (* 2 x) 1)))) 1 inc max)))

(define (product2 term a next b res)
  (if (> a b)
      res
      (product2 term (next a) next b (* res (term a)))))

(define (product3 term a next b)
  (define (product-iter i res)
   (if (> i b)
      res
      (product-iter (next i) (* res (term i)))))
  (product-iter a 1))

(define (pi3 n)
  (* 2 (product3 (lambda (x) (/ (* 4 x x ) (* (- (* 2 x) 1) (+ (* 2 x) 1)))) 1 inc n)))

(define (pi2 max)
  (* 2 (product2 (lambda (x) (/ (* 4 x x ) (* (- (* 2 x) 1) (+ (* 2 x) 1)))) 1 inc max 1)))

(define test (lambda (x) (/ (* 4 x x ) (* (- (* 2 x) 1) (+ (* 2 x) 1)))))

(define (cf num den k i)
  (if (> i k)
      0
      (/ (num i) (+ (den i) (cf num den k (+ i 1))))))

(define (cont-frac num den k)
  (cf num den k 0))

(define id (lambda (i) 1.0))

(define (cont-frac-iter num den k)
  (define (cfi i res)
   (if (> i k)
       res
      (cfi (+ i 1) (/ (num (- k i)) (+ res (den (- k i)))))))
  (cfi 0 0))

(define (pi4 n)
  (+ 3 (cont-frac (lambda (n) (square (+ (* 2 n) 1))) (lambda (n) 6.0) n)))

(define (pi5 n)
  (+ 3 (cont-frac-iter (lambda (n) (square (+ (* 2 n) 1))) (lambda (n) 6.0) n)))

(define (atan-cf x k)
  (cont-frac-iter (lambda (k) (if (= k 0) x (square (* k x)))) (lambda (k) (+ (* 2 k) 1)) k))

( define ( buildp n d b )
(/ n (+ d b ) ) )

(define (repeated-build k n b d)
  ( define ( build b )
    ;(/ n (+ d b ) ) )
     (buildp n d b))
  ((repeated build k) b))










