;; step 5
(check-type 3 int)
(check-type #t bool)
(check-type 'hello sym)

;; step 6
(check-type (if #t 1 2) int)
(check-type (if #f 'Richard 'Townsend) sym)
(check-type (if #t #f #t) bool)
(check-type-error (if #t 'cs 105))
(check-type-error (if #f #f 'cs))
(check-type-error (if 0 #f 'cs))


;; step 7
(check-type + (int int -> int))
(check-type = (forall ['a] ('a 'a -> bool)))
(check-type cons (forall ['a] ('a (list 'a) -> (list 'a))))
(check-type-error fake_function)

;; step 9
(val test_x 'cs)
(val test_y 105)
(val test_z #f)
(check-type test_x sym)
(check-type test_y int)
(check-type test_z bool)
(check-type-error (val test_d test_d))

;; step 10
(check-type (+ 1 2) int)
(check-type (< 1 test_y) bool)
(check-type (< 1 (+ 1 2)) bool)
(check-type-error (- test_x test_y))
(check-type-error (> test_x test_y))
(check-type-error ('func test_x test_y))


;; step 11
(check-type (let ([a (+ 1 2)] [b (- 10 5)]) (* a b)) int)
(check-type-error (let ([a 1] [b 'two]) (+ a b)))
(check-type-error (let ([a b] [b a]) (+ a b)))


;; step 12
(check-type (lambda ([x : int]) (+ x 1)) (int -> int))
(check-type (lambda ([x : int] [y : int]) (+ x y)) (int int -> int))
(check-type-error (lambda ([x : bool]) (+ x 1)))

;; step 13
(val x 5)
(val y #t)
(check-type (set x 2) int)
(check-type (set y #f) bool)    
(check-type-error (set x #f))
(check-type-error (set y 10))
(check-type (while (> x 5) (set x 10)) unit)
(check-type-error (while (= x 10) (+ x 1)))
(check-type (begin (set x 7) #t (+ x 4)) int)
(check-type-error (begin #t (+ 1 #f) #f))


;; step 14
(check-type (let* ([x 5] [y (+ x 5)]) (+ x y)) int)
(check-type (let* ([x #t] [y #f]) (set x #f)) bool)
(check-type-error (let* ([x 5] [y #t]) (+ x y)))

;; step 15 
(check-type
  (letrec ([len ( (list int) -> int )
                (lambda ([xs : (list int)])
                  (if (null? xs) 
                      0 
                      (+ 1 (len (cdr xs)))))])
    (len '(1 2 3)))
  int)

;; step 16
(val-rec pow (int int -> int)
  (lambda ([base : int] [exp : int])
    (if (= exp 0)
        1
        (* base (pow base (- exp 1))))))

(check-type pow (int int -> int))

(define int count-up ([n : int]) (if ([@ = int] n 10) 10 (count-up (+ n 1))))
(check-type count-up (int -> int))

(check-type-error (define bool bad-def ([n : int]) (+ n 1)))


;; step 17
(val poly-id (type-lambda ['a] (lambda ([x : 'a]) x)))
(check-type poly-id (forall ['a] ('a -> 'a)))

(val int-id (@ poly-id int))
(check-type int-id (int -> int))

(check-type-error (@ 5 int))
(check-type-error (@ poly-id int bool))

; ;; step 18
; (check-type '() (forall ['a] (list 'a)))
; (check-type '(1 2 3) (list int))
; (check-type-error '(1 #t 3))
