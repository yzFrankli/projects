;;;;;;;;;;;;;;;;;;; CS 105 HOFS ACTIVITY ;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 1: `exists?` laws and implementation.
;;;;
;;;;  The `exists?` function is our first "classic higher-order function (HOF)"
;;;;  for today, and is provided in uScheme's initial basis. For this problem,
;;;;  you'll investigate how it should work and try to re-implement it yourself.
;;;;
;;;;  Here are the steps to complete for this problem:
;;;;    1. Read the contract and unit tests for `exists?` below to
;;;;       understand the function's expected inputs and output.
;;;;    2. Complete the right-hand side of the second algebraic law for 
;;;;       the `exists?` function below these instructions. 
;;;;    3. Use that law's right-hand side to complete the implementation 
;;;;       of `exists?`. 
;;;;    4. Run this file through the interpreter (uscheme -q hofs.scm)
;;;;       and check that there are no failing unit tests that mention
;;;;       `exists?`.


;; (exists? p? xs) tells whether an element of list xs satisfies
;; predicate p?. 

;; laws:
;;   (exists? p? '()) == #f
;;   (exists? p? (cons y ys)) == ???? ;; TODO: Complete this algebraic law

(define exists? (p? xs)
  (if (null? xs)
      #f
      (/ 1 0))) ;; TODO: Replace this branch based on your algebraic law above

        (check-assert (not (exists? number? '())))
        (check-assert      (exists? number? '(1 2 3)))
        (check-assert (not (exists? number? '(a () #t))))
        (check-assert      (exists? null?   '(a () #t)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 2: The `all?` function.
;;;;
;;;;  The `all?` function is another classic HOF in uScheme's initial basis. The
;;;;  unit tests for `all?` written below all pass.  Based off of that, describe
;;;;  in English what the `all?` function does. How might you compare it to the
;;;;  `exists?` function?
;;;;
;;;;  ANSWER: The all? function...<write your answer here>


        (check-assert      (all? number?  '(1)))
        (check-assert      (all? number?  '(1 2)))
        (check-assert      (all? number?  '(1 2 3)))
        (check-assert (not (all? number?  '(1 a 3))))
        (check-assert      (all? boolean? '(#f #f #t)))
        (check-assert (not (all? null?    '(a () #t))))
        (check-assert      (all? null?    '(() () ())))
        (check-assert      (all? number?  '()))
        (check-assert      (all? boolean? '()))
        (check-assert      (all? null?    '()))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 3: `all?` laws.
;;;;
;;;;  Write algebraic laws for the `all?` function below. Start by copy-pasting
;;;;  your completed laws for the `exists?` function; `all?` will have the same
;;;;  number of laws and use the same forms of data, so the left-hand sides of
;;;;  `all?`'s laws will be the same as the left-hand sides for `exists?`'s
;;;;  laws.


;; TODO: WRITE YOUR LAWS HERE
;; laws:
;;
;;
;;
;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 4: `map` vs `filter`.
;;;;
;;;;  Two higher-order initial basis functions, `map` and `filter`, are
;;;;  re-defined below.  Below each definition is a set of incomplete unit
;;;;  tests: the input is provided to the function being tested, but the
;;;;  expected output is incorrect. Use the definition of each function to
;;;;  replace each test's `'error` symbol with the expected output for that unit
;;;;  test. Your goal is to get each unit test to pass ONLY by filling in the
;;;;  test's output (i.e., don't change the functions' definitions or any unit
;;;;  test's input!).  


(define map (f xs)
  (if (null? xs)
      '()
      (cons (f (car xs)) (map f (cdr xs)))))

        ;; TODO: Replace each "error" symbol with the actual expected
        ;; output for each test.
        (val square (lambda (x) (* x x)))
        (check-expect (map square  '())          'error)
        (check-expect (map square  '(1 2 3))     'error)
        (check-expect (map number? '(1 a 3))     'error)
        (check-expect (map car     '((a) (b c))) 'error)

(define filter (p? xs)
  (if (null? xs)
      '()
      (if (p? (car xs))
          (cons (car xs) (filter p? (cdr xs)))
          (filter p? (cdr xs)))))

        ;; TODO: Replace each "error" symbol with the actual expected
        ;; output for each test.
        (check-expect (filter number?  '(1 a 3)) 'error)
        (check-expect (filter symbol?  '(1 a 3)) 'error)
        (check-expect (filter boolean? '(1 a 3)) 'error)
        (check-expect (filter null?    '(1 a 3)) 'error)



