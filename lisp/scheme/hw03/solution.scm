;; exercise 2
;; (contig-sublist? xs ys)
;;   consumes two lists xs and ys
;;   produces #t if xs appears as a contiguous sublist of ys, else #f

(define contig-sublist? (xs ys)
  (define prefix? (xs ys)
    (cond [(null? xs) #t]
          [(null? ys) #f]
          [(equal? (car xs) (car ys))
           (prefix? (cdr xs) (cdr ys))]
          [else #f]))
  (cond [(null? xs) #t]
        [(null? ys) #f]
        [(prefix? xs ys) #t]
        [else (contig-sublist? xs (cdr ys))]))

(check-expect (contig-sublist? '(2 3) '(1 2 3 4)) #t)
(check-expect (contig-sublist? '(2 4) '(1 2 3 4)) #f)
(check-error  (contig-sublist? 99 99))



;; exercise 3
;; (flatten xs)
;;   consumes a list possibly containing nested lists
;;   produces a flat list of all atoms in order

(define flatten (xs)
  (cond [(null? xs) '()]
        [(pair? (car xs))
         (append (flatten (car xs))
                 (flatten (cdr xs)))]
        [else
         (cons (car xs) (flatten (cdr xs)))]))

(check-expect (flatten '((1 2) (3 (4)))) '(1 2 3 4))
(check-expect (flatten '()) '())
(check-error  (flatten 99))


;; exercise 4
;; (take n xs)
;;   produces first n elements of xs (or all if shorter)

(define take (n xs)
  (cond [(or (zero? n) (null? xs)) '()]
        [else (cons (car xs)
                    (take (- n 1) (cdr xs)))]))

(check-expect (take 2 '(1 2 3 4)) '(1 2))
(check-expect (take 5 '(1 2)) '(1 2))
(check-error  (take 9 99))

;; (drop n xs)
;;   produces xs without its first n elements

(define drop (n xs)
  (cond [(or (zero? n) (null? xs)) xs]
        [else (drop (- n 1) (cdr xs))]))

(check-expect (drop 2 '(1 2 3 4)) '(3 4))
(check-expect (drop 5 '(1 2)) '())
(check-error  (drop 9 99))



;; exercise 5
(zip '(1 2) '(a b)) → '((1 a) (2 b))
;; (zip xs ys)
;;   produces list of pairs formed from corresponding elements

(define zip (xs ys)
  (cond [(or (null? xs) (null? ys)) '()]
        [else (cons (list (car xs) (car ys))
                    (zip (cdr xs) (cdr ys)))]))

(check-expect (zip '(1 2 3) '(a b c)) '((1 a) (2 b) (3 c)))
(check-error  (zip 99 99))

(unzip '((1 a) (2 b))) → '((1 2) (a b))
;; (unzip ps)
;;   consumes list of pairs
;;   produces list containing two lists: firsts and seconds

(define unzip (ps)
  (cond [(null? ps) (list '() '())]
        [else
         (let ([rest (unzip (cdr ps))])
           (list (cons (car (car ps)) (car rest))
                 (cons (cadr (car ps)) (cadr rest))))]))

(check-expect (unzip '((1 a) (2 b))) '((1 2) (a b)))
(check-error  (unzip 99))



;; exercise 6
(arg-max abs '(-10 3 -4)) → -10
;; (arg-max f xs)
;;   returns element of xs whose f-value is largest

(define arg-max (f xs)
  (cond [(null? xs) (error 'arg-max "empty list")]
        [(null? (cdr xs)) (car xs)]
        [else
         (let* ([best (arg-max f (cdr xs))]
                [x (car xs)])
           (if (> (f x) (f best)) x best))]))

(check-expect (arg-max abs '(-10 3 -4)) -10)
(check-error  (arg-max 9 99))






;; 1 (a)

;; (contig-sublist? xs ys)
;;   consumes two lists of atoms xs and ys
;;   produces #t iff xs appears as a contiguous subsequence of ys
;;   i.e. there exist lists front and back such that
;;   ys = (append (append front xs) back)

(define contig-sublist? (xs ys)

  ;; does xs match the prefix of ys?
  (define prefix? (xs ys)
    (cond [(null? xs) #t]
          [(null? ys) #f]
          [(equal? (car xs) (car ys))
           (prefix? (cdr xs) (cdr ys))]
          [else #f]))

  (cond
    [(null? xs) #t]                 ; empty always matches
    [(null? ys) #f]
    [(prefix? xs ys) #t]            ; found match at this spot
    [else (contig-sublist? xs (cdr ys))])) ; slide window

(contig-sublist? '() ys) = #t

(contig-sublist? xs '()) = #f        if xs ≠ '()

(contig-sublist? xs ys)  = #t
  if xs is a prefix of ys

(contig-sublist? xs (cons y ys1))
  = (contig-sublist? xs ys1)
  if xs is not a prefix of (cons y ys1)

(prefix? '() ys) = #t
(prefix? xs '()) = #f      if xs ≠ '()
(prefix? (cons x xs) (cons y ys))
  = (prefix? xs ys)        if (equal? x y)
(prefix? (cons x xs) (cons y ys))
  = #f                    if (not (equal? x y))


;; 1 (b)

(flatten '()) = '()

(flatten (cons x xs))
  = (cons x (flatten xs))
  if x is an atom

(flatten (cons x xs))
  = (append (flatten x) (flatten xs))
  if x is a list


;; (flatten xs)
;;   consumes a list of ordinary S-expressions
;;   produces a flat list of all atoms in the same order

(define flatten (xs)
  (cond
    [(null? xs) '()]
    [(pair? (car xs))                       ; element is a list
     (append (flatten (car xs))
             (flatten (cdr xs)))]
    [else                                   ; element is atom
     (cons (car xs)
           (flatten (cdr xs)))]))

(check-expect (flatten '((I Ching) (U Thant) (E Coli)))
              '(I Ching U Thant E Coli))
(check-expect (flatten '(((((a)))))) '(a))
(check-expect (flatten '()) '())
(check-expect (flatten '((a) () ((b c) d e))) '(a b c d e))
(check-error  (flatten 99))


;; 2
(take 0 xs) = '()

(take n '()) = '()

(take n (cons x xs))
  = (cons x (take (- n 1) xs))
  if n > 0


;; (take n xs)
;;   returns first n elements of xs (or all if shorter)

(define take (n xs)
  (cond
    [(zero? n) '()]
    [(null? xs) '()]
    [else (cons (car xs)
                (take (- n 1) (cdr xs)))]))

(check-expect (take 2 '(1 2 3 4)) '(1 2))
(check-expect (take 9 '(1 2)) '(1 2))
(check-error  (take 9 99))

;; 4 
(drop 0 xs) = xs

(drop n '()) = '()

(drop n (cons x xs))
  = (drop (- n 1) xs)
  if n > 0

;; (drop n xs)
;;   removes first n elements of xs

(define drop (n xs)
  (cond
    [(zero? n) xs]
    [(null? xs) '()]
    [else (drop (- n 1) (cdr xs))]))

(check-expect (drop 2 '(1 2 3 4)) '(3 4))
(check-expect (drop 9 '(1 2)) '())
(check-error  (drop 9 99))

;; 5 
(zip '() '()) = '()

(zip (cons x xs) (cons y ys))
  = (cons (list2 x y) (zip xs ys))

(zip '() '()) = '()
(zip (cons x xs) (cons y ys))
  = (cons (list2 x y) (zip xs ys))


;; (zip xs ys)
;;   returns list of 2-element lists pairing corresponding elements

(define zip (xs ys)
  (cond
    [(null? xs) '()]
    [else
     (cons (list2 (car xs) (car ys))
           (zip (cdr xs) (cdr ys)))]))

(check-expect (zip '(1 2 3) '(a b c))
              '((1 a) (2 b) (3 c)))
(check-error  (zip 99 99))



(unzip '()) = (list2 '() '())

(unzip (cons (list2 x y) ps))
  = (list2 (cons x (car (unzip ps)))
           (cons y (cadr (unzip ps))))

;; (unzip ps)
;;   converts list of pairs into pair of lists

(define unzip (ps)
  (cond
    [(null? ps) (list2 '() '())]
    [else
     (let ([rest (unzip (cdr ps))])
       (list2 (cons (car (car ps)) (car rest))
              (cons (cadr (car ps)) (cadr rest))))]))

(check-expect (unzip '((I Magnin) (U Thant) (E Coli)))
              '((I U E) (Magnin Thant Coli)))
(check-error  (unzip 99))

(cons a '())
(cons a as) where as nonempty


(arg-max f (cons x '())) = x

(arg-max f (cons x xs))
  = x
  if (> (f x) (f (arg-max f xs)))

(arg-max f (cons x xs))
  = (arg-max f xs)
  if (<= (f x) (f (arg-max f xs)))


;; (arg-max f xs)
;;   xs is nonempty
;;   returns element whose f-value is maximal

(define arg-max (f xs)
  (cond
    [(null? (cdr xs)) (car xs)]          ; one element
    [else
     (let ([best (arg-max f (cdr xs))]
           [x (car xs)])
       (if (> (f x) (f best)) x best))]))

(define square (a) (* a a))

(check-expect (arg-max square '(5 4 3 2 1)) 5)
(check-expect (arg-max car '((105 PL) (160 Algorithms) (170 Theory)))
              '(170 Theory))
(check-error (arg-max 9 99))
