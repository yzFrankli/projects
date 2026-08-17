;;;;;;;;;;;;;;;;;;; COMP 105 SCHEME ASSIGNMENT ;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Exercise 2


;; (contig-sublist? xs ys) <does what exactly> (replace with function contract)

;; laws (if you want to attempt them; they are optional for this problem):
;;   (contig-sublist? ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define contig-sublist? (xs ys)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (contig-sublist? 99 99))

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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Exercise 3


;; (flatten xs) <does what exactly> (replace with function contract)

;; laws:
;;   (flatten ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define flatten (xs)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (flatten 99))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Exercise 4


;; (take n xs) <does what exactly> (replace with function contract)

;; laws:
;;   (take ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define take (n xs)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (take 9 99))



;; (drop n xs) <does what exactly> (replace with function contract)

;; laws:
;;   (drop ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define drop (n xs)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (drop 9 99))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Exercise 5


;; (zip xs ys) <does what exactly> (replace with function contract)

;; laws:
;;   (zip ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define zip (xs ys)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (zip 99 99))



;; (unzip ps) <does what exactly> (replace with function contract)

;; laws (if you want to attempt them; they are optional for unzip):
;;   (unzip ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define unzip (ps)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (unzip 99))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Exercise 6


;; (arg-max f xs) <does what exactly> (replace with function contract)

;; laws:
;;   (arg-max ...) == ...
;;   ...
;; [optional notes about where laws come from, or difficulty, if any]

(define arg-max (f xs)
    (error 'not-implemented-yet)) ;; replace this line with good code

        ;; replace next line with good check-expect or check-assert tests
        (check-error (arg-max 9 99))

