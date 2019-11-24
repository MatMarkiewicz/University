#lang racket

(require racklog)

;; predykat unarny %male reprezentuje zbiór mężczyzn
(define %male
  (%rel ()
        [('adam)]
        [('john)]
        [('joshua)]
        [('mark)]
        [('david)]))

;; predykat unarny %female reprezentuje zbiór kobiet
(define %female
  (%rel ()
        [('eve)]
        [('helen)]
        [('ivonne)]
        [('anna)]))

;; predykat binarny %parent reprezentuje relację bycia rodzicem
(define %parent
  (%rel ()
        [('adam 'helen)]
        [('adam 'ivonne)]
        [('adam 'anna)]
        [('eve 'helen)]
        [('eve 'ivonne)]
        [('eve 'anna)]
        [('john 'joshua)]
        [('helen 'joshua)]
        [('ivonne 'david)]
        [('mark 'david)]))

;; predykat binarny %sibling reprezentuje relację bycia rodzeństwem
(define %sibling
  (%rel (a b c)
        [(a b)
         (%parent c a)
         (%parent c b)]))

;; predykat binarny %sister reprezentuje relację bycia siostrą
(define %sister
  (%rel (a b)
        [(a b)
         (%sibling a b)
         (%female a)]))

;; predykat binarny %ancestor reprezentuje relację bycia przodkiem
(define %ancestor
  (%rel (a b c)
        [(a b)
         (%parent a b)]
        [(a b)
         (%parent a c)
         (%ancestor c b)]))

;; Cw 1

; a jest wnukiem b
(define %grandson
  (%rel (a b c)
        [(a b)
         (%male a)
         (%parent b c)
         (%parent c a)]))

; a jest kuzynem / kuzynka b
(define %cousin
  (%rel (a b c d)
        [(a b)
         (%parent c a)
         (%parent d b)
         (%sibling c d)]))

; a jest matką b
(define %is_mother
  (%rel (a b)
        [(a)
         (%female a)
         (%parent a b)]))

; a jest ojcem b
(define %is_father
  (%rel (a b)
        [(a)
         (%male a)
         (%parent a b)]))

;; Cw 2

; Czy John jest potomkiem Marka?
;(%find-all () (%ancestor `mark `john))

;Kto jest potomkiem Adama?
;(%find-all (x) (%ancestor `adam x))

;Kto jest siostr ˛a Ivonne?
;(%find-all (x) (%sister `ivonne x))

;Kto ma w tej rodzinie kuzyna i kim ten kuzyn jest?
;(%find-all (x y) (%cousin x y))

;Kto ma w tej rodzinie kuzyna
;(%let (y) (%find-all (x) (%cousin x y)))


(require racklog)

(define %my-append
  (%rel (x xs ys zs)
        [(null ys ys)]
        [((cons x xs) ys (cons x zs))
         (%my-append xs ys zs)]))

(define %my-member
  (%rel (x xs y)
        [(x (cons x xs))]
        [(y (cons x xs))
         (%my-member y xs)]))

(define %select
  (%rel (x xs y ys)
        [(x (cons x xs) xs)]
        [(y (cons x xs) (cons x ys))
         (%select y xs ys)]))


;; prosta rekurencyjna definicja
(define %simple-length
  (%rel (x xs n m)
        [(null 0)]
        [((cons x xs) n)
         (%simple-length xs m)
         (%is n (+ m 1))]))

;; test w trybie +- (działa)
;(%find-all (a) (%simple-length (list 1 2) a))
;; test w trybie ++ (działa)
;(%find-all () (%simple-length (list 1 2) 2))
;; test w trybie -+ (1 odpowiedź, pętli się)
;(%which (xs) (%simple-length xs 2))
;; test w trybie -- (nieskończona liczba odpowiedzi)
;(%which (xs a) (%simple-length xs a))

;; definicja zakładająca, że długość jest znana
(define %gen-length
  (%rel (x xs n m)
        [(null 0) !]
        [((cons x xs) n)
         (%is m (- n 1))
         (%gen-length xs m)]))
;; test w trybie ++ (działa)
;(%find-all () (%gen-length (list 1 2) 2))
;; test w trybie -+ (działa)
;(%find-all (xs) (%gen-length xs 2))


;; Cw 3

;Jakie pary list maj  ̨a t  ̨e własno ́s ́c, ze druga lista jest wynikiem konkatenacji  ̇
;dwóch kopii pierwszej z nich?
;(%which (xs ys) (%my-append xs xs ys))

;Jaki element nalezy usun ˛a´c z listy ˙ ’(1 2 3 4), aby otrzyma´c ’(1 2 4)?
;(%which (x) (%member x (list 1 2 3 4)) (%not (%member x (list 1 2 4))))
;(%which (x) (%select x (list 1 2 3 4) (list 1 2 4)))

;Jak ˛a list ˛e nalezy doł ˛aczy´c do listy ˙ ’(1 2 3), aby otrzyma´c ’(1 2 3 4 5)?
;(%which (xs) (%append (list 1 2 3) xs (list 1 2 3 4 5)))

;; Cw 4
; ...

;; Cw 5
; ...

;; Cw 6

(define %sublist
  (%rel (x xs ys xs2 ys2)
        [(null ys)]
        [((cons x xs2) (cons x ys2))
         (%sublist xs2 ys2)]
        [(xs (cons x ys2))
         (%sublist xs ys2)]))

;; Cw 7

;; dziala w +-
(define %perm
  (%rel (x xs ys zs)
        [(null null)]
        [((cons x xs) ys)
         (%perm xs zs)
         (%select x ys zs)]))

; dziala w -+
(define %perm2
  (%rel (x xs ys zs)
        [(null null)]
        [((cons x xs) ys)
         (%select x ys zs)
         (%perm2 xs zs)]))

;; Cw 8

(define (list->num l)
  (foldl (lambda (x y) (+ (* 10 y) x)) 0 l))

(define %send-more
  (%rel (D E M N O R S Y xs ys acc)
        [(D E M N O R S Y)
         (%gen-length xs 8)
         (%sublist xs (list 0 1 2 3 4 5 6 7 8 9))
         (%perm xs ys)
         (%= ys (list D E M N O R S Y))
         (%=/= M 0)
         (%=/= S 0)
         (%is acc (list->num (list M O N E Y)))
         (%is acc (+ (list->num (list S E N D)) (list->num (list M O R E))))]))

;(%which (D E M N O R S Y) (%send-more D E M N O R S Y))


