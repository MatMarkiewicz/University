#lang racket
(define (cont-frac N D k)
  (define (A i)
    (cond
      [(= i -1) 1]
      [(= i 0) 0]
      [else (+ (* (D i) (A (- i 1))) (* (N i) (A (- i 2))))]))
  (define (B i)
    (cond
      [(= i -1) 0]
      [(= i 0) 1]
      [else (+ (* (D i) (B (- i 1))) (* (N i) (B (- i 2))))]))
  (define (f i)
    (/ (A i) (B i)))
  (define (good-enough? k)
    (< (dist (f k) (f (+ k 1))) 0.000001))
  (if (good-enough? k)
      (f k)
      (cont-frac N D (+ k 1))))

(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 1)