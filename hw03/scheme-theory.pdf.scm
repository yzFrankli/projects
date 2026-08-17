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




