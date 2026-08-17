;;;;;;;;;;;;;;;;;;; COMP 105 Type Systems ASSIGNMENT ;;;;;;;;;;;;;;;

;; Frank Li yli57, Rui Zhu rzhu03


;; (even? x) takes an integer x and tells if it is even.
(define bool even? ([x : int]) ([@ = int] (mod x 2) 0))
        (check-assert (not (even? 1)))
        (check-assert      (even? 2))

;; (odd? x) takes an integer x and tells if it is odd.
(define bool odd?  ([x : int]) ([@ = int] (mod x 2) 1))
        (check-assert      (odd? 1))
        (check-assert (not (odd? 2)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Part B

;; (drop n xs) takes an integer n and list xs and returns xs without the first 
;; n elements, or the empty list if n is greater than the length of xs

;; laws:
;;   (drop 0 ys) == ys
;;   (drop m '()) == '()
;;   (drop (+ 1 m) (cons y ys)) == (drop m ys)

(val drop 
    (type-lambda ['a] 
        (letrec [([drop-mono : (int (list 'a) -> (list 'a))]
                    (lambda ([n : int] [xs : (list 'a)]) 
                        (if ([@ = int] n 0)
                            xs
                            (if ([@ null? 'a] xs)
                                [@ '() 'a]
                                (drop-mono (- n 1) ([@ cdr 'a] xs))))))]
            drop-mono)))

        (check-type drop (forall ['a] (int (list 'a) -> (list 'a))))
        (check-expect ([@ drop int] 0 '(1 2 3)) '(1 2 3))
        (check-expect ([@ drop int] 1 '(1 2 3)) '(2 3))
        (check-expect ([@ drop int] 2 '(1 2 3)) '(3))
        (check-expect ([@ drop int] 3 '(1 2 3)) [@ '() int])
        (check-expect ([@ drop int] 4 '(1 2 3)) [@ '() int])
        (check-expect ([@ drop int] 1 [@ '() int]) [@ '() int])


;; (takewhile p? xs) takes a predicate p? and list xs and returns the longest
;; prefix of the list in which every element satisfies the predicate.

;; laws:
;;   (takewhile p? '()) == '()
;;   (takewhile p? (cons a as)) == '(), where (not (p? a))
;;   (takewhile p? (cons a as)) == (cons a (takewhile p? as)), where (p? a)

(val takewhile 
    (type-lambda ['a] 
        (letrec [([takewhile-mono : (('a -> bool) (list 'a) -> (list 'a))]
                    (lambda ([p? : ('a -> bool)] [xs : (list 'a)]) 
                        (if ([@ null? 'a] xs)
                            [@ '() 'a]
                            (if (not (p? ([@ car 'a] xs)))
                                [@ '() 'a]
                                ([@ cons 'a] ([@ car 'a] xs) 
                                    (takewhile-mono p? ([@ cdr 'a] xs)))))))]
            takewhile-mono)))

        (check-type takewhile (forall ['a] 
                                (('a -> bool) (list 'a) -> (list 'a))))
        (check-expect ([@ takewhile int] even? [@ '() int]) [@ '() int])
        (check-expect ([@ takewhile int] even? '(2 4 6 7 8 10 12)) '(2 4 6))
        (check-expect ([@ takewhile int] even? '(2 4 6 8 10 12)) 
                                                             '(2 4 6 8 10 12))
        (check-expect ([@ takewhile int] odd? '(2 4 6 7 8 10 12)) [@ '() int])
        (check-expect ([@ takewhile int] odd? '(1 3 5 6 7)) '(1 3 5))
