#lang racket

;; expressions

(define (const? t)
  (number? t))

(define (op? t)
  (and (list? t)
       (member (car t) '(+ - * /))))

(define (op-op e)
  (car e))

(define (op-args e)
  (cdr e))

(define (op-cons op args)
  (cons op args))

(define (op->proc op)
  (cond [(eq? op '+) +]
        [(eq? op '*) *]
        [(eq? op '-) -]
        [(eq? op '/) /]))

(define (let-def? t)
  (and (list? t)
       (= (length t) 2)
       (symbol? (car t))))

(define (let-def-var e)
  (car e))

(define (let-def-expr e)
  (cadr e))

(define (let-def-cons x e)
  (list x e))

(define (let? t)
  (and (list? t)
       (= (length t) 3)
       (eq? (car t) 'let)
       (let-def? (cadr t))))

(define (let-def e)
  (cadr e))

(define (let-expr e)
  (caddr e))

(define (let-cons def e)
  (list 'let def e))

(define (var? t)
  (symbol? t))

(define (var-var e)
  e)

(define (var-cons x)
  x)

(define (arith/let-expr? t)
  (or (const? t)
      (and (op? t)
           (andmap arith/let-expr? (op-args t)))
      (and (let? t)
           (arith/let-expr? (let-expr t))
           (arith/let-expr? (let-def-expr (let-def t))))
      (var? t)))

;; let-lifted expressions

(define (arith-expr? t)
  (or (const? t)
      (and (op? t)
           (andmap arith-expr? (op-args t)))
      (var? t)))

(define (let-lifted-expr? t)
  (or (and (let? t)
           (let-lifted-expr? (let-expr t))
           (arith-expr? (let-def-expr (let-def t))))
      (arith-expr? t)))

;; generating a symbol using a counter

(define (number->symbol i)
  (string->symbol (string-append "x" (number->string i))))

;; environments (could be useful for something)

(define empty-env
  null)

(define (add-to-env x v env)
  (cons (list x v) env))

;; poniższa procedura z wykładu została przeze mnie edytowana na potrzeby zadania
;; w przypadku nieznalezienia zmiennej procedura zwraca fałsz, a nie błąd
(define (find-in-env x env)
  (cond [(null? env) #f]
        [(eq? x (caar env)) (cadar env)]
        [else (find-in-env x (cdr env))]))

;; procedury z wykładu

(define (eval-env e env)
  (cond [(const? e) e]
        [(op? e)
         (apply (op->proc (op-op e))
                (map (lambda (a) (eval-env a env))
                     (op-args e)))]
        [(let? e)
         (eval-env (let-expr e)
                   (env-for-let (let-def e) env))]
        [(var? e) (find-in-env (var-var e) env)]))

(define (env-for-let def env)
  (add-to-env
    (let-def-var def)
    (eval-env (let-def-expr def) env)
    env))

(define (eval e)
  (eval-env e empty-env))

;; struktura danych

;; let-lift wyrażenia będą na potrzeby zadania reprezentowane jako para, złożona z listy deklaracji
;; oraz wyrażenia nie zawierającego letów. Litera t oznacza, że jest to przetworzone wyrażenie

(define texpr-cons cons)

;; selektory umożliwiające dostęp do definicji i wyrażenia w przetworzonym wyrażeniu

(define texpr-defs car)
(define texpr-expr cdr)

;; procedura służżca do tłumaczenia wyrażeń z tymczasowej (przetworzonej) formy na postać let-wyrażeń

(define (texpr->let-expr e)
  (if (null? (texpr-defs e))
      (texpr-expr e)
      (let-cons (car (texpr-defs e)) (texpr->let-expr (texpr-cons (cdr (texpr-defs e)) (texpr-expr e))))))

;; wynikiem pomocniczej procedury będzie para składająca się z wyrażenia trans-let-expr oraz następnej liczby potrzebnej
;; do tworzenia świeżych zmiennych. Nazwa jest skrótem od result-with-iterator

(define rwi-cons cons)

;; selektory umożliwiające dostęp do wyniku i iteratora z tej struktury danych

(define rwi-result car)
(define rwi-iterator cdr)

;; procedura rekurencyjna przekształcająca wyrażenia
                                                                                                                                    
(define (let-lift e)
  ;; procedura przetwarzająca wyrażenia tak, by spełniały predykat let-lifted-expr?
  (define (let-lift-for-op args i env)
    ;; procedura przetwarzająca listę wyrażeń, czyli argumenty op-wyrażenia
    (if (null? args)
        (rwi-cons (texpr-cons `() `()) i)
        (let* ((tfirst-arg (let-lift-with-counter (car args) i env))
               (trest-args (let-lift-for-op (cdr args) (rwi-iterator tfirst-arg) env)))
          ;; łączone są listy definicji pierwszego i reszty argumentów (wywołanie rekurencyjne)
          ;; oraz łaczone są wyrażenia w listę, by w głównej procedurze dodać do nich operator
          (rwi-cons (texpr-cons (append (texpr-defs (rwi-result tfirst-arg))
                                        (texpr-defs (rwi-result trest-args)))
                                (cons (texpr-expr (rwi-result tfirst-arg))
                                      (texpr-expr (rwi-result trest-args))))
                    (rwi-iterator trest-args)))))
  (define (let-lift-with-counter exp i env)
    ;; główna procedura przetwarzająca wyrażenie względem jego struktury
    ;; w przypadku stałych zmieniana jest jedynie reprezentacja wyrażenia
    (cond [(const? exp) (rwi-cons (texpr-cons `() exp) i)]
          ;; zmienna wyszukiwana jest w środowisku i ewentualnie zmieniana jest jej nazwa
          [(var? exp) (let ((new-var (find-in-env exp env)))
                      (if new-var
                          (rwi-cons (texpr-cons `() new-var) i)
                          (rwi-cons (texpr-cons `() exp) i)))]
          ;; w przypadku wyrażenia z operatorem wywoływana jest procedura pomocnicza
          [(op? exp) (let ((targs (let-lift-for-op (op-args exp) i env)))
                     (rwi-cons (texpr-cons (texpr-defs (rwi-result targs))
                                           (cons (op-op exp) (texpr-expr (rwi-result targs))))
                               (rwi-iterator targs)))]
          ;; w przypadku leta przetwarzane jest zarówno główne wyrażenie, jak i wyrażenie z definicji
          ;; wywołanie dla wyrażenia wykonywane jest dla iteratora świeżych zmiennych otrzymanego z
          ;; przetworzenia wyrażenia w definicji
          ;; w wynikowym wyrażeniu kolejność łączenia definicji jest następująca:
          ;; na początku umieszczane są definicje uzyskane z przetworzenia wyrazeni z definicji, następnie dodawana jest
          ;; nowa definicja z rozpatrywanego leta, na końcu umieszczone są definicje z dalszego wyrażenia         
          [(let? exp) (let* ((old-var (let-def-var (let-def exp)))
                           (new-var (number->symbol i))
                           (tdef-expr (let-lift-with-counter (let-def-expr (let-def exp))
                                                             (+ i 1)
                                                             env))
                           (texpr (let-lift-with-counter (let-expr exp)
                                                         (rwi-iterator tdef-expr)
                                                         (add-to-env old-var new-var env))))
                      (rwi-cons (texpr-cons (append (append (texpr-defs (rwi-result tdef-expr))
                                                            (list (list new-var (texpr-expr (rwi-result tdef-expr)))))
                                                    (texpr-defs (rwi-result texpr)))
                                            (texpr-expr (rwi-result texpr)))
                                (rwi-iterator texpr)))]))
  ;; pomocnicza procedura wywoływana jest z iteratorem równym zero oraz pustym środowiskiem
  (if (arith/let-expr? e)    
      (texpr->let-expr (rwi-result (let-lift-with-counter e 0 empty-env)))
      (error "Podano błędną formułę")))


;; Testy

;; Testy procedury trans-let-expr->let-expr

;(trans-let-expr->let-expr (trans-let-expr-cons `() `(+ 3 4)))
;(trans-let-expr->let-expr (trans-let-expr-cons `((x0 7)) `(+ x0 4)))
;(trans-let-expr->let-expr (trans-let-expr-cons (list `(x0 1) `(x1 2) `(x2 3) `(x3 4) `(x4 5)) `(+ x0 (* x1 (- x2 (/ x4 x3))))))

;; Testy głównej procedury

;; przykładowe przetworzenie wyrażenia

#|
(let-lift `(/ (let (x 4) (* x x))
              (let (x (+ 2
                         (let (y 4) (+ 3
                                       y
                                       (let (z 5) (* 1 z))))))
                (+ x
                   (let (a 6) (* a 3))
                   (let (a 7) (* a 4))))
              3))
|#

(define (test)
  ;; procedura przetwarza przykładowe wyrażenia za pomocą procedury let-lift
  ;; następnie sprawdza, czy otrzymany wynik spełnia predykat let-lifted-expr?
  ;; procedura sprawdza również, czy wynik ewaluuje się do takiego samego wyniku, jak pierwotne wyrażenie
  (and (let* ((e `(/ (let (x 4) (* x x))
              (let (x (+ 2
                         (let (y 4) (+ 3
                                       y
                                       (let (z 5) (* 1 z))))))
                (+ x
                   (let (a 6) (* a 3))
                   (let (a 7) (* a 4))))
              3))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `(+ 9 (/ (let (x 5) (+ 3 x)) 2)))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `(let (x (+ 1 (let (y 2) y))) (* x x)))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `(* (let (x 1) x) (let (x 2) x)))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `42)
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `(+ 3 (let (x 1) (let (y 2) (let (z 3) (+ x y x))))))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `(let (x 1) (let (x 2) (+ x x))))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `(+ (let (x 1) x) (let (x 2) x) (let (x 3) x)))
              (le (let-lift e)))
         (and (let-lifted-expr? le)
              (= (eval e) (eval le))))
       (let* ((e `x)
              (le (let-lift e)))
         (eq? e le))
       ))