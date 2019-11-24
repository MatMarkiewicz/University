#lang racket

(define (dist x y)
  ;; procedura z wykładu
  (abs (- x y)))

(define (cube x)
  (* x x x))

(define (square x)
  (* x x))

(define (cube-root x)
  ;; procedura obliczająca następne, lepsze przybliżenie
  (define (improve approx)
    (/ (+ (/ x (square approx)) (* 2 approx)) 3))
  ;; procedura sprawdzająca, czy dane przybliżenie jest wystarczająco dobre
  (define (good-enough? approx)
    (< (dist (cube approx) x) 0.0001))
  ;; procedura iterująca następne przybliżenia do czasu znalezienia wystarczająco dobrego
  (define (iter approx)
    (cond
      [(good-enough? approx) approx]
      [else (iter (improve approx))]))
  (iter 1.0))

(cube-root 8)
(cube-root 0)
(cube-root 1000)
(cube-root -0.7)
(cube-root 123456789)
