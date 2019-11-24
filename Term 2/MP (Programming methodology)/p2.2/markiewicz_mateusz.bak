#lang racket
(define (dist x y)
  ;;procedura z wykładu
  (abs (- x y)))

(define (close-enough? x y)
  ;;procedura z wykładu   
  (< (dist x y) 0.00001))

(define (fixed-point f x0)
  ;;procedura z wykładu
  (let ((x1 (f x0)))
    (if (close-enough? x0 x1)
        x1
        (fixed-point f x1))))

(define (average-damp f)
  ;;procedura z wykładu
  (lambda (x) (/ (+ x (f x)) 2.0)))

(define (compose f g)
  ;;procedura z racownii (napisana samodzielnie)
  (lambda (x) (f (g x))))

(define (repeated p n)
  ;;procedura z racownii (napisana samodzielnie)
  (if (= n 0)
      identity
      (compose p (repeated p (- n 1)))))

(define (identity x)
  ;;procedura z racownii (napisana samodzielnie)
  x)

(define (test n x m)
  ;; procedura do wyznaczania potrzebnej ilości złożeń
  (expt (fixed-point ((repeated average-damp m) (lambda (y) (/ x (expt y (- n 1))))) 1.0) n))

;;testy
;;(test 2 100 1)
;;(test 3 100 1)
;;(test 4 100 1) - brak wyniku, zbyt mała ilość złożeń
;;(test 4 100 2)
;;(test 7 100 2)
;;(test 8 100 2) - brak wyniku, zbyt mała ilość złożeń
;;(test 8 100 3)
;;(test 16 100 3) - brak wyniku, zbyt mała ilość złożeń
;;(test 16 100 4)
;;(test 32 100 4) - brak wyniku, zbyt mała ilość złożeń
;;(test 32 100 5)


(define (nth-root n x)
  (define (floor-log2 n i)
    (cond [(= n 1) 1]
          [(= (expt 2 i) n) i]
          [(> (expt 2 i) n) (- i 1)]
          [else (floor-log2 n (+ i 1))]))
  (let ((m (floor-log2 n 1)))
    (fixed-point ((repeated average-damp m) (lambda (y) (/ x (expt y (- n 1))))) 1.0)))

(nth-root 10 1024)

