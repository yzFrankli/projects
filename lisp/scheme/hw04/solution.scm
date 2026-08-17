;;;;;;;;;;;;;;;;;;; 105 IMPCORE ASSIGNMENT ;;;;;;;;;;;;;;;

;; Your Name: yli57

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 2

;; flip takes a function with two parameters and flips the parameter around
;;

;; laws:
;;    ((flip f) x y) = (f y x)

(define flip (f)
        (lambda (x y)
            (f y x)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 3

;; takewhile takes a predicate and a list and returns the longest prefix in the
;; list where every element satisfies the predicate

;; laws:
;; (takewhile p '()) = '()
;; (takewhile p '(cons x xs)) =
;;      (cons x (takewhile p xs)) if (p x)
;;      = '()                    otherwise

(define takewhile ()
    (lambda (p xs)
        (if (null? xs
            '())
            (if (p (car xs))
                (cons (car xs))
                    (takewhile p (cdr xs)))
                    '())))


(check-expect (takewhile null? '()) '())

;; dropwhile takes a predicate and a list and removes the longest prefix in the
;; list

;; laws:
;;   (dropwhile p '()) = '()
;;   (dropwhile p (cons x xs))
;;      = (dropwhile p xs)      if (p x)
;;      = (cons x xs)           otherwise

;; dropwhile
(define dropwhile ()
    (lambda (p xs)
        (if (null? xs)
            '()
        (if (p (car xs))
            (dropwhile p (cdr xs))
            xs))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 4

;; laws:   


(define ordered-by (precedes? xs)
    (if (null? xs) #t
        (if (null? (cdr xs)) #t
            #t 
            (and 
                (precedes? (car xs) (car (cdr xs))) 
                (ordered-by(precedes? (cdr xs)))))))


(val increasing? (ordered-by <))
(check-assert (increasing? '()) #t)
(check-assert (increasing? '(5) #t))
(check-error (increasing < '(a b c)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 5

;; greater takes two number inputs and outputs the greater number 

(define greater (a b)
    (if (> a b) a b))

;; max takes a list and uses greater to compare each element of the list and 
;; output the max
(define max* () 
    (lambda (xs)
        (foldl greater (car xs) (cdr xs))))


;; product takes in a list and multiply each element of the list
(define product
    (lambda (xs)
        (foldl * (car xs) (cdr xs))
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 6

;; append takes two lists and connect the beginning of the second list to the 
;; end of the first list
(define append (xs ys)
            (foldr cons ys xs))

(check-expect (append '(1 2) '(3 4)) '(1 2 3 4))

;; reverse takes a list and reverse the order of int
(define reverse (xs)
    (foldl cons '() xs))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 7


;; map will apply the condition to all the elements in the list
(define map (p xs)
    (foldr (lambda (x acc) 
        (cons (p x) acc))
    '()
    xs))

(check-expect (map (lambda (x) (+ 1 x) '(1 2))))


;; filter will remove all the elements in the list that returns false
;; for the precondition p?
(define filter (p? xs)
    (foldr (lambda (x acc) 
        (if (p? x) 
            (cons x acc) 
            acc))
            '() 
            xs))

(check-expect (filter (lambda (x) (= (mod x 2) 0)) '(1 2 3)) '(2))

;; all? will apply the condition to all the elements in the list
(define all (p? xs)
    (foldl (lambda (x acc) 
        (and (p? x) acc)) 
    #t 
    xs))

(check-expect (all even '(2 4 6)) #t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 8

;; (a)
;; even set is the set of even numbers

(val evens (lambda (x) (= (mod x 2) 0)))

;; (b)
;; two-digits set is the set that contains two digit positive numbers

(val two-digits (lambda (x) (and (> x 9) (< x 100))))

;; (c)

;; add-element returns a set containing x and all the elements of s.
;; s is a characteristic function (set) and x is an element
(define add-element (x s)
    (lambda (y) (or (equal? x y) (member? y s))))

;; union returns a set containing elements that are in either s1 or s2
(define union (s1 s2)
    (lambda (x) (or (member? x s1) (member? x s2))))

;; inter s1 s2 returns a set containing elements that are in both s1 and s2
(define inter (s1 s2)
    (lambda (x) (and (member? x s1) (member? x s2))))

;; diff s1 s2 returns a set containing elements in s1 that are not in s2
(define diff (s1 s2)
    (lambda (x) (and (member? x s1) (not (member? x s2)))))





