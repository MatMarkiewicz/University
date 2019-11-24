#lang racket

(require racklog)

;; transpozycja tablicy zakodowanej jako lista list
(define (transpose xss)
  (cond [(null? xss) xss]
        ((null? (car xss)) (transpose (cdr xss)))
        [else (cons (map car xss)
                    (transpose (map cdr xss)))]))

;; procedura pomocnicza
;; tworzy listę n-elementową zawierającą wyniki n-krotnego
;; wywołania procedury f
(define (repeat-fn n f)
  (if (eq? 0 n) null
      (cons (f) (repeat-fn (- n 1) f))))

;; tworzy tablicę n na m elementów, zawierającą świeże
;; zmienne logiczne
(define (make-rect n m)
  (repeat-fn m (lambda () (repeat-fn n _))))

(define %gen-length
  ;; procedura z wykładu
  (%rel (x xs n m)
        [(null 0) !]
        [((cons x xs) n)
         (%is m (- n 1))
         (%gen-length xs m)]))

(define %list-of--*
  ;; predykat listy składajacej się z symboli `- oraz `*
  (%rel (x xs)
        [(null)]
        [((cons x xs))
         (%or (%= x '-)
              (%= x '*))
         (%list-of--* xs)]))

(define %list-of-*
  ;; predykat listy składającej się z symboli `*
  (%rel (xs)
        [(null)]
        [((cons '* xs))
         (%list-of-* xs)]))

(define %n-length-list-of--*
  ;; predykat listy symboli `- `* o określonej długości
  (%rel (xs n)
        [(xs n)
         (%gen-length xs n)
         (%list-of--* xs)]))

(define %n-length-list-of-*
  ;; predykat listy symboli `* o określonej długości
  (%rel (xs n)
        [(xs n)
         (%gen-length xs n)
         (%list-of-* xs)]))

;; predykat binarny
;; (%row-ok xs ys) oznacza, że xs opisuje wiersz (lub kolumnę) ys

(define %row-ok
  (%rel (xs ys ys1 ys2 x xs1 ys11)
        ;; lista pusta opisuje listę pustą
        ;; symbole `- z początku wiersza można pominąć
        [(null null)]
        [(xs (cons `- ys1))
         (%row-ok xs ys1)]
        ;; wiersz cały zapełniony gwiazdkami opisuje jego długość
        [((cons x null) ys)
         (%n-length-list-of-* ys x)]
        ;; jeśli wiersz składaja się z co najmniej 2 bloków rozdzielonych `-
        ;; pierwszy z nich musi być opisany przez pierwszą cyfrę, a następne
        ;; sprawdzone są rekurencyjnie
        [((cons x xs1) ys)
         (%n-length-list-of-* ys1 x)
         (%append ys1 `(-) ys11)
         (%append ys11 ys2 ys)
         (%row-ok xs1 ys2)]
        ))

(define %possible-row
  ;; predykat sprawdzający, czy podany rząd jest zgodny z opisem i ma odpowiednią długość
  (%rel (xs ys n)
        [(xs ys n)
         (%n-length-list-of--* ys n)
         (%row-ok xs ys)]))

(define %good-board-rows
  ;; predykat sprawdzający, czy obrazek jest zgodny z opisem rzędów
  (%rel (xss xs yss ys n)
        [(null null n)]
        [((cons xs xss) (cons ys yss) n)
         (%possible-row ys xs n)
         (%good-board-rows xss yss n)]))

(define %good-board-cols
  ;; predykat sprawdzający, czy obrazek jest zgodny z opisem kolumn
  (%rel (xss txss yss n)
        [(null null n)]
        [(xss yss n)
         (%is txss (transpose xss))
         (%good-board-rows txss yss n)]))
                                    
;; funkcja rozwiązująca zagadkę
(define (solve rows cols)
  (let ((x (length cols))
        (y (length rows)))
    (define board (make-rect x y))
    (define tboard (transpose board))
    (define ret (%which (xss) 
                        (%= xss board)
                        (%good-board-rows xss rows x)
                        (%good-board-cols xss cols y)
                        ))
    (and ret (cdar ret))
    ))

;; INFORMACJA O ROZWIĄZANIU ZADANIA
;; W całym rozwiązaniu zmieniłem symbol `_ na symbol `-.
;; Symbol `_ interpretowany jest przez rackloga jako dowolny symbol przez
;; co unifikuje się z wszystkimi innymi symbolami, w tym również `*, a w moim
;; rozwiązaniu konieczne było rozróżnienie symboli `* i `_
;; Przykładem tego są takie wywołania:
;;(%which () (%append `(_) `() `(*)))
;;(%which () (%append `(-) `() `(*)))


;; testy
(equal? (solve '((2) (1) (1)) '((1 1) (2)))
        '((* *)
          (- *)
          (* -)))

(equal? (solve '((2) (2 1) (1 1) (2)) '((2) (2 1) (1 1) (2)))
        '((- * * -)
          (* * - *)
          (* - - *)
          (- * * -)))

#|
;; wylicza się ok 90 sekund
(equal? (solve `((2 1) (1 3) (1 2) (3) (4) (1)) `((1) (5) (2) (5) (2 1) (2)))
     '((* * - - - *)
  (- * - * * *)
  (- * - * * -)
  (- * * * - -)
  (- * * * * -)
  (- - - * - -)))
|#

;; TESTY

#|
;; Testy %row-ok

(eq? (%which () (%row-ok `(2 4) `(* * - * * * *))) null)
(eq? (%which () (%row-ok `(2 4) `(* * * * * *))) #f)
(eq? (%which () (%row-ok `() `(- - -))) null)
(eq? (%which () (%row-ok `() `(- * -))) #f)
(eq? (%which () (%row-ok `(2 4 1) `(* * - * * * * -))) #f)
(eq? (%which () (%row-ok `(2 4 1) `(* * - * * * * - - - * ))) null)
(eq? (%which () (%row-ok `(2 4 1) `(- - - * * - * * * * - - - * -))) null)
(eq? (%which () (%row-ok `(2 4) `(* * - * * * * * -))) #f)
(eq? (%which () (%row-ok `(4) `(* * * * *))) #f)

;; Testy %possible-row

(%which () (%possible-row `(2 4) `(* * - - * * * * -) 9))
(%find-all (xs) (%possible-row `(2 4) xs 9))
|#
