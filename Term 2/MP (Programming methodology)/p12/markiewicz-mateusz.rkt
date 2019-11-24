#lang racket

;; sygnatura: grafy
(define-signature graph^
  ((contracted
    [graph        (-> list? (listof edge?) graph?)]
    [graph?       (-> any/c boolean?)]
    [graph-nodes  (-> graph? list?)]
    [graph-edges  (-> graph? (listof edge?))]
    [edge         (-> any/c any/c edge?)]
    [edge?        (-> any/c boolean?)]
    [edge-start   (-> edge? any/c)]
    [edge-end     (-> edge? any/c)]
    [has-node?    (-> graph? any/c boolean?)]
    [outnodes     (-> graph? any/c list?)]
    [remove-node  (-> graph? any/c graph?)]
    )))

;; prosta implementacja grafów
(define-unit simple-graph@
  (import)
  (export graph^)

  (define (graph? g)
    (and (list? g)
         (eq? (length g) 3)
         (eq? (car g) 'graph)))

  (define (edge? e)
    (and (list? e)
         (eq? (length e) 3)
         (eq? (car e) 'edge)))

  (define (graph-nodes g) (cadr g))

  (define (graph-edges g) (caddr g))

  (define (graph n e) (list 'graph n e))

  (define (edge n1 n2) (list 'edge n1 n2))

  (define (edge-start e) (cadr e))

  (define (edge-end e) (caddr e))

  (define (has-node? g n) (not (not (member n (graph-nodes g)))))
  
  (define (outnodes g n)
    (filter-map
     (lambda (e)
       (and (eq? (edge-start e) n)
            (edge-end e)))
     (graph-edges g)))

  (define (remove-node g n)
    (graph
     (remove n (graph-nodes g))
     (filter
      (lambda (e)
        (not (eq? (edge-start e) n)))
      (graph-edges g)))))

;; sygnatura dla struktury danych
(define-signature bag^
  ((contracted
    [bag?       (-> any/c boolean?)]
    [bag-empty? (-> bag? boolean?)]
    [empty-bag  (and/c bag? bag-empty?)]
    [bag-insert (-> bag? any/c (and/c bag? (not/c bag-empty?)))]
    [bag-peek   (-> (and/c bag? (not/c bag-empty?)) any/c)]
    [bag-remove (-> (and/c bag? (not/c bag-empty?)) bag?)])))


;; struktura danych - stos
(define-unit bag-stack@
  (import)
  (export bag^)
  ;; implementacja stosu poprzez listę
  ;; elementy są dodawane i pobierane z początku listy
  (define (bag? e)
    (list? e))
  (define (bag-empty? bag)
    (null? bag))
  (define empty-bag null)
  (define (bag-insert bag e)
    (cons e bag))
  (define (bag-peek bag)
    (car bag))
  (define (bag-remove bag)
    (cdr bag))
)


;; struktura danych - kolejka FIFO
;; do zaimplementowania przez studentów
(define-unit bag-fifo@
  (import)
  (export bag^)
  ;; implementacja kolejki fifo jako pary dwóch list
  ;; elementy są dodowane na początek pierwszej listy (wejściowej)
  ;; elementy pobierane są z początku drugiej listy
  ;; jeśli natomiast jest ona pusta zastępuje się drugą listę
  ;; odwróconą pierwszą listą, pierwsza zaś staje się pusta
  (define (bag? e)
    (and (cons? e)
         (list? (car e))
         (list? (cdr e))))
  (define (bag-empty? bag)
    (and (null? (car bag))
         (null? (cdr bag))))
  (define empty-bag (cons null null))
  (define (bag-insert bag e)
    (cons (cons e (car bag)) (cdr bag)))
  (define (bag-cons in-list out-list)
      (if (null? out-list)
          (cons null (reverse in-list))
          (cons in-list out-list)))
  (define (bag-peek bag)
    (let ((bag (bag-cons (car bag) (cdr bag))))
      (cadr bag)))
  (define (bag-remove bag)
    (let ((bag (bag-cons (car bag) (cdr bag))))
      (cons (car bag) (cddr bag)))) 
)

;; sygnatura dla przeszukiwania grafu
(define-signature graph-search^
  (search))

;; implementacja przeszukiwania grafu
;; uzależniona od implementacji grafu i struktury danych
(define-unit/contract graph-search@
  (import bag^ graph^)
  (export (graph-search^
           [search (-> graph? any/c (listof any/c))]))
  (define (search g n)
    (define (it g b l)
      (cond
        [(bag-empty? b) (reverse l)]
        [(has-node? g (bag-peek b))
         (it (remove-node g (bag-peek b))
             (foldl
              (lambda (n1 b1) (bag-insert b1 n1))
              (bag-remove b)
              (outnodes g (bag-peek b)))
             (cons (bag-peek b) l))]
        [else (it g (bag-remove b) l)]))
    (it g (bag-insert empty-bag n) '()))
  )

;; otwarcie komponentu grafu
(define-values/invoke-unit/infer simple-graph@)

;; graf testowy
(define test-graph
  (graph
   (list 1 2 3 4)
   (list (edge 1 3)
         (edge 1 2)
         (edge 2 4))))

(define test-graph2
  (graph
   (list 1 2 3 4 5 6 7)
   (list (edge 1 2)
         (edge 2 3)
         (edge 3 4)
         (edge 4 5)
         (edge 5 6)
         (edge 6 7))))

(define test-graph3
  (graph
   (list 1 2 3)
   (list (edge 1 2)
         (edge 2 3)
         (edge 2 1)
         (edge 1 3))))

(define test-graph4
  (graph
   (list 1 2 3 4)
   (list (edge 1 3)
         (edge 3 2)
         (edge 2 4))))

(define test-graph5
  (graph
   (list 1 2 3 4 5)
   (list (edge 1 5)
         (edge 1 3)
         (edge 2 4)
         (edge 3 2))))

(define test-graph6
  (graph
   (list 1 2 3 4 5)
   (list (edge 1 2)
         (edge 2 1)
         (edge 3 4)
         (edge 4 5)
         (edge 5 3))))

;; otwarcie komponentu stosu
(define-values/invoke-unit/infer bag-stack@)
;; opcja 2: otwarcie komponentu kolejki
;(define-values/invoke-unit/infer bag-fifo@)

;; testy w Quickchecku
(require quickcheck)

;; test przykładowy: jeśli do pustej struktury dodamy element
;; i od razu go usuniemy, wynikowa struktura jest pusta
(quickcheck
 (property ([s arbitrary-symbol])
           (bag-empty? (bag-remove (bag-insert empty-bag s)))))

;; test konstruktuora pustej listy
(quickcheck
 (property ()
           (bag-empty? empty-bag)))

;; test wstawiania elementu
(quickcheck
 (property ([s arbitrary-symbol])
           (not (bag-empty? (bag-insert empty-bag s)))))

#|
;; test dla kolejki, sprawdzający, czy jako pierwszy zwrócony zostanie
;; element, który został dodany jako pierwszy
(quickcheck
 (property ([s1 arbitrary-symbol]
            [s2 arbitrary-symbol])
           (eq? s1 (bag-peek (bag-insert (bag-insert empty-bag s1) s2)))))

;; test dla kolejki, sprawdzający, czy elementy są poprawnie dodawane,
;; pobierane oraz czy dodawane i pobierane są wszystkie elementy i nie dodawane
;; są żadne inne
(quickcheck
 (property ([xs (arbitrary-list arbitrary-symbol)])
           (define (add-to-bag bag xs)
             (if (null? xs)
                 bag
                 (add-to-bag (bag-insert bag (car xs)) (cdr xs))))
           (define (take-from-bag bag xs)
             (if (bag-empty? bag)
                 xs
                 (take-from-bag (bag-remove bag) (cons (bag-peek bag) xs))))
           (equal? (reverse xs) (take-from-bag (add-to-bag empty-bag xs) null))))
|#
;#|
;; testy dla stosu, sprawdzający, czy jako pierwszy zwrócony zostanie
;; element, który został dodany jako drugi
(quickcheck
 (property ([s1 arbitrary-symbol]
            [s2 arbitrary-symbol])
           (eq? s2 (bag-peek (bag-insert (bag-insert empty-bag s1) s2)))))

;; test dla stous, sprawdzający, czy elementy są poprawnie dodawane,
;; pobierane oraz czy dodawane i pobierane są wszystkie elementy i nie dodawane
;; są żadne inne
(quickcheck
 (property ([xs (arbitrary-list arbitrary-symbol)])
           (define (add-to-bag bag xs)
             (if (null? xs)
                 bag
                 (add-to-bag (bag-insert bag (car xs)) (cdr xs))))
           (define (take-from-bag bag xs)
             (if (bag-empty? bag)
                 xs
                 (take-from-bag (bag-remove bag) (cons (bag-peek bag) xs))))
           (equal? xs (take-from-bag (add-to-bag empty-bag xs) null))))
;|#                 

;; otwarcie komponentu przeszukiwania
(define-values/invoke-unit/infer graph-search@)

;; uruchomienie przeszukiwania na przykładowym grafie
(search test-graph 1)
(search test-graph2 1)
(search test-graph3 2)
(search test-graph4 1)
(search test-graph5 1)
(search test-graph6 1)
(search test-graph6 3)