#lang racket

;; Cw 1

(define (make-account balance password)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch p m)
    (if (eq? p password)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request -- MAKE-ACCOUNT"
                       m)))
    (lambda (e) 'incorrect-password)))
  dispatch)

;(define acc (make-account 100 'secret-password ) )
;((acc 'secret-password 'withdraw ) 40)
;((acc 'some-other-password 'deposit ) 50)

;; Cw 2

(define (make-cycle l)
  (define (helper xs)
    (if (null? (mcdr xs))
          (set-mcdr! xs l)
        (helper (mcdr xs))))
  (helper l))

(define test-l (mcons 1 (mcons 2 (mcons 3 (mcons 4 null)))))

;; Cw 3

(define (has-cycle? l)
  (define (helper xs ys)
    (cond [(or (null? ys) (null? (mcdr ys)))
           #f]
          [(eq? xs ys) #t]
          [else (helper (mcdr xs) (mcdr (mcdr ys)))]))
  (if (or (null? l) (null? (mcdr l)))
      #f
      (helper (mcdr l) (mcdr (mcdr l)))))

;; Cw 4

(define (make-monitored p)
  (let ((n 0))
    (define (dispatch m)
      (cond [(eq? m `reset) (set! n 0)]
            [(eq? m `how-many) n]))
    (define (change-proc . args)
      (set! n (+ n 1))
      (apply p args))
    (cons change-proc dispatch)))

;; Cw 5


(define (bucket-sort xs)
  (let* ((max (apply max (map (lambda (e) (car e)) xs)))
         (v (make-vector (+ 1 max) `())))
    (define (the-walking-pair ys)
      (when (not (null? ys))
        (vector-set! v (caar ys) (cons (cdar ys) (vector-ref v (caar ys))))
        (the-walking-pair (cdr ys))))
    (define (procedure2 id)
      (if (> id max)
          null
          (let ((l (reverse (vector-ref v id))))
            (append (map (lambda (e) (cons id e)) l) (procedure2 (+ 1 id))))))
    (the-walking-pair xs)
    (procedure2 0)))
    
(define (test1 l)
  (sort l #:key car <))

(define (test2 l)
  (bucket-sort l))

;; Cw 6

(define (lcons x f)
  (mcons x f))

(define (lhead l)
  (mcar l))

(define (ltail l)
  (when (procedure? (mcdr l))
      (set-mcdr! l ((mcdr l))))
  (mcdr l))

(define (integers-starting-from n)
  (lcons n (lambda () (integers-starting-from (+ n 1)))))

(define (ltake n l)
  (if (or (null? l) (= n 0))
      null
      (cons (lhead l)
            (ltake (- n 1) (ltail l)))))

(define (lfilter p l)
  (cond [(null? l) null]
        [(p (lhead l))
         (lcons (lhead l)
                (lambda ()
                  (lfilter p (ltail l))))]
        [else (lfilter p (ltail l))]))

(define (lmap f . ls)
  (if (ormap null? ls) null
      (lcons (apply f (map lhead ls))
             (lambda ()
               (apply lmap (cons f (map ltail ls)))))))


(define fact
  (lcons 1 (lambda () (lmap * (integers-starting-from 1) fact))))

;; Cw 7

(define (sum l)
  (lcons 0 (lambda () (lmap + (




    