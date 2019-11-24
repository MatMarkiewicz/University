#lang racket

(define (dist x y)
  ;; procedura z wykładu
  (abs (- x y)))

(define (square x)
  ;; procedura z wykładu
  (* x x))

(define (cont-frac N D)
  (define (cont-frac-iter pre-A pre-pre-A pre-B pre-pre-B i)
    (let ((A (+ (* (D i) pre-A) (* (N i) pre-pre-A)))
          (B (+ (* (D i) pre-B) (* (N i) pre-pre-B))))
      (define (good-enough? fk1 fk2)
        (< (dist fk1 fk2) 0.000001))
      (if (good-enough? (/ A B) (/ pre-A pre-B))
          (/ A B)
          (cont-frac-iter A pre-A B pre-B (+ i 1)))))
  (cont-frac-iter 0 1 1 0 1))


(define (atan-cf x)
  (cont-frac (lambda (i) (if (= i 1) x (square (* (- i 1) x)))) (lambda (i) (- (* 2 i) 1))))

;; 1/złoty podział
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0))

;; pi
(+ 3 (cont-frac (lambda (i) (square (- (* 2 i) 1))) (lambda (i) 6.0)))

;; tan 0.5
(atan-cf 0.5)
(atan 0.5)



    
    
    
        