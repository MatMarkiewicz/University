#lang racket

;; LISTA 5

;; Cw 1

(define (var? t)
  (symbol? t))

(define (neg? t)
  (and (list? t)
       (= 2 (length t))
       (eq? `neg (car t))))

(define (conj? t)
  (and (list? t)
       (= 3 (length t))
       (eq? `conj (car t))))

(define (disj? t)
  (and (list? t)
       (= 3 (length t))
       (eq? `disj (car t))))

(define (prop? f)
  (or (var? f)
      (and (neg? f)
           (prop? (neg-subf f)))
      (and (disj? f)
           (prop? (disj-left f))
           (prop? (disj-rght f)))
      (and (conj? f)
           (prop? (disj-left f))
           (prop? (disj-rght f)))))

(define (neg p)
  (list `neg p))

(define (conj p q)
  (list `conj p q))

(define (disj p q)
  (list `disj p q))

(define (disj-left disj)
  (if (disj? disj)
      (cadr disj)
      (error "Podana formuła nie jest alternatywą")))

(define (disj-rght disj)
  (if (disj? disj)
      (caddr disj)
      (error "Podana formuła nie jest alternatywą")))

(define (conj-left conj)
  (if (conj? conj)
      (cadr conj)
      (error "Podana formuła nie jest koninukcją")))

(define (conj-rght conj)
  (if (conj? conj)
      (caddr conj)
      (error "Podana formuła nie jest koninukcją")))

(define (neg-subf neg)
  (if (neg? neg)
      (cadr neg)
      (error "Podana formuła nie jest negacją")))

;; testy

;;(neg-subf (neg `p))
;;(disj-left (disj `p `q))
;;(disj-rght (disj `p `q))
;;(conj-left (conj `p `q))
;;(conj-rght (conj `p `q))


;; Cw 2

(define (literal? l)
  (and (list? l)
       (= (length l) 2)
       (eq? (car l) `lit)
       (or (var? (second l))
           (and (neg? (second l))
                (var? (neg-subf (second l)))))))

(define (contains? xs x)
  (if (null? xs)
      #f
      (or (equal? x (car xs))
          (contains? (cdr xs) x))))

(define (free-vars form)
  (define (iter f xs)
    (cond [(var? f) (if (contains? xs f)
                        xs
                        (cons f xs))]
          [(literal? f) (iter (second f) xs)]
          [(neg? f) (iter (neg-subf f) xs)]
          [(conj? f) (iter (conj-left f) (iter (conj-rght f) xs))]
          [(disj? f) (iter (disj-left f) (iter (disj-rght f) xs))]
          [else (error "Podano błedną formułę")]))
  (iter form null))

;; testy

;;(free-vars (conj `p (disj `q `r)))
;;(free-vars (conj `p (neg `p)))


;; Cw 3

(define (gen-vals xs)
  (if (null? xs)
      (list null)
      (let* ((vss (gen-vals (cdr xs)))
             (x (car xs))
             (vst (map (lambda (vs) (cons (list x true) vs)) vss))
             (vsf (map (lambda (vs) (cons (list x false) vs)) vss)))
        (append vst vsf))))

(define (var-value var vals)
  (cond [(null? vals) (error "Zmienna nie występuje w wartościowaniu")]
        [(eq? (caar vals) var) (cadar vals)]
        [else (var-value var (cdr vals))]))
     
(define (eval-formula form vals)
  (cond [(var? form) (var-value form vals)]
        [(literal? form) (eval-formula (second form) vals)]
        [(neg? form) (not (eval-formula (neg-subf form) vals))]
        [(disj? form) (or (eval-formula (disj-left form) vals)
                          (eval-formula (disj-rght form) vals))]
        [(conj? form) (and (eval-formula (conj-left form) vals)
                           (eval-formula (conj-rght form) vals))]
        [else (error "Podano błedną formułę")]))

(define f1 (conj (neg `p) (disj `q (neg `r))))

(define vf1 (gen-vals (free-vars f1)))

(define (falsifiable-eval? form)
  (let ((vals (gen-vals (free-vars form))))
    (define (iter values)
      (if (null? values)
          #f
          (if (not (eval-formula form (car values)))
              (car values)
              (iter (cdr values)))))
    (iter vals)))

;; testy

;;(falsifiable-eval? f1)
;;(falsifiable-eval? (conj `p (neg `p)))
;;(falsifiable-eval? (disj `p (neg `p)))


;; Cw 4
                 
(define (literal p)
  (if (or (var? p)
          (and (neg? p)
               (var? (neg-subf p))))
      (list `lit p)
      (error "Podana formuła nie jest zmienna ani negacją zmiennej")))

(define (nnf? f)
  (cond [(literal? f) #t]
        [(conj? f) (and (nnf? (conj-left f))
                        (nnf? (conj-rght f)))]
        [(disj? f) (and (nnf? (disj-left f))
                        (nnf? (disj-rght f)))]
        [(neg? f) #f]
        [else (error "Podano błędną formułę")]))


(define f2 (conj (literal (neg `p)) (disj (literal `q) (literal (neg `r)))))


;; Cw 5

(define (convert-to-nnf2 f)
  ;; niezgodne ze specyfikacją
  (cond [(var? f) (literal f)]
        [(disj? f) (disj (convert-to-nnf2 (disj-left f))
                         (convert-to-nnf2 (disj-rght f)))]
        [(conj? f) (conj (convert-to-nnf2 (conj-left f))
                         (convert-to-nnf2 (conj-rght f)))]
        [(neg? f) (cond [(var? (neg-subf f)) (literal f)]
                        [(disj? (neg-subf f)) (conj (convert-to-nnf2 (neg (disj-left (neg-subf f))))
                                                    (convert-to-nnf2 (neg (disj-rght (neg-subf f)))))]
                        [(conj? (neg-subf f)) (disj (convert-to-nnf2 (neg (conj-left (neg-subf f))))
                                                    (convert-to-nnf2 (neg (conj-rght (neg-subf f)))))]
                        [(neg? (neg-subf f)) (convert-to-nnf2 (neg-subf (neg-subf f)))]
                        [else (error "Błędna formuła")])]
        [else (error "Błędna formuła")]))

(define (convert-to-nnf-neg f)
  (cond [(var? f) (literal (neg f))]
        [(disj? f) (conj (convert-to-nnf-neg (disj-left f))
                         (convert-to-nnf-neg (disj-rght f)))]
        [(conj? f) (disj (convert-to-nnf-neg (conj-left f))
                         (convert-to-nnf-neg (conj-rght f)))]
        [(neg? f) (convert-to-nnf (neg-subf f))]
        [else (error "Błędna formuła")]))

(define (convert-to-nnf f)
  (cond [(var? f) (literal f)]
        [(disj? f) (disj (convert-to-nnf (disj-left f))
                         (convert-to-nnf (disj-rght f)))]
        [(conj? f) (conj (convert-to-nnf (conj-left f))
                         (convert-to-nnf (conj-rght f)))]
        [(neg? f) (convert-to-nnf-neg (neg-subf f))]
        [else (error "Błędna formuła")]))


;; CW 6

;; Klauzla - lista literałów
;; CNF - lista klauzul

(define (clause xs)
  (cons `clause xs))

(define (clause? cl)
  (and (list? cl)
       (> (length cl) 0)
       (eq? (car cl) `clause)
       (andmap literal? cl)))

(define (cnf clauses)
  (cons `cnf clauses))

(define (cnf? cls)
  (and (list? cls)
       (> (length cls) 0)
       (eq? (car cls) `cnf)
       (andmap clause? cnf)))

(define (join xss yss)
  (apply append (map (lambda (p)
                       (map (lambda (q) (clause (append p q)))
                            (cdr yss)))
                     (cdr xss))))

(define (convert-to-cnf-test f)
  ;; NIE DZIAŁA
  (cond [(literal? f) (cnf (list (clause (list f))))]
        [(conj? f) (cnf (append (second (convert-to-cnf (conj-left f)))
                                (second (convert-to-cnf (conj-rght f)))))]
        [(disj? f) (list (second (convert-to-cnf (disj-left f)))
                         (second (convert-to-cnf (disj-rght f))))] ;; (cnf (join (second (convert-to-cnf (disj-left f)))
                              ;;(second (convert-to-cnf (disj-rght f)))))]
        [else (error "Coś jest źle")]))

(define (convert-to-cnf f)
  ;; NIE DZIAŁA
  (cond [(literal? f) (cnf (list (clause (list f))))]
        [(conj? f) (cnf (append (second (convert-to-cnf (conj-left f)))
                                (second (convert-to-cnf (conj-rght f)))))]
        [(disj? f) (cnf (join (second (convert-to-cnf (disj-left f)))
                              (second (convert-to-cnf (disj-rght f)))))]
        [else (error "Coś jest źle" f)]))

(define f3 (neg (conj `p `q)))
;;   (convert-to-cnf '(disj (lit (neg p)) (lit (neg q))))                            