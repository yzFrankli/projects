;;;;;;;;;;;;;;;;;;; 105 IMPCORE ASSIGNMENT ;;;;;;;;;;;;;;;

;; Your Name: yli57

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 2

(define list-of? (A? v)
  (lambda ()
    (cond
      ((null? v) #t)
      ((pair? v) (and (A? (car v)) 
                      (list-of? A? (cdr v))))
      (else #f))))

;; (solve-formula x             bool cur fail succeed) == (solve-symbol x bool cur fail succeed)
;; (solve-formula (make-not f)  bool cur fail succeed) == (solve-symbol f (not bool) cur fail succeed)
;; (solve-formula (make-or  fs) #t   cur fail succeed) == (solve-any fs #t cur fail succeed)
;; (solve-formula (make-or  fs) #f   cur fail succeed) == (solve-all fs #f cur fail succeed)
;; (solve-formula (make-and fs) #t   cur fail succeed) == (solve-all fs #t cur fail succeed)
;; (solve-formula (make-and fs) #f   cur fail succeed) == (solve-any fs #f cur fail succeed)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 3

;; Record definitions for boolean formulas
(record not [arg])
(record or  [args])
(record and [args])

;; formula? : value -> boolean
;; Returns #t if v is a valid boolean formula representation, #f otherwise.
(define formula? (v)
  (if (symbol? v) 
      #t
      (if (not? v) 
          (formula? (not-arg v))
          (if (or? v)  
              (list-of? formula? (or-args v))
              (if (and? v) 
                  (list-of? formula? (and-args v))
                  #f)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 4

(define eval-formula (f env)
  (if (symbol? f)
      (find f env)
      (if (not? f)
          (not (eval-formula (not-arg f) env))
          (if (or? f)
              (exists? (lambda (sub) (eval-formula sub env)) (or-args f))
              (if (and? f)
                  (all? (lambda (sub) (eval-formula sub env)) (and-args f))
                  #f)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;  Problem 5

;; solve-symbol
;; (solve-symbol x bool cur fail succeed) == (succeed (bind x bool cur) fail)      ;; where x is not bound in cur
;; (solve-symbol x bool cur fail succeed) == (succeed cur fail)                    ;; where x is bool in cur
;; (solve-symbol x bool cur fail succeed) == (fail)                                ;; where x is (not bool) in cur

;; solve-all
;; (solve-all '()         bool cur fail succeed) == (succeed cur fail)
;; (solve-all (cons f fs) bool cur fail succeed) == (solve-formula f bool cur fail (lanbda (env resume) (solve-all fs bool env resume succeed)))

;; solve-any
;; (solve-any '()         bool cur fail succeed) == (fail)
;; (solve-any (cons f fs) bool cur fail succeed) == (solve-formula f bool cur (lambda () (solve-any fs bool cur fail succeed)) succeed)


(define solve-sat (f fail succ)
  (letrec

  ;; solve-formula

    ([solve-formula 
      (lambda (f bool cur fail succeed)
        (if (symbol? f)
            (solve-symbol f bool cur fail succeed)
            (if (not? f)
                (solve-formula (not-arg f) (not bool) cur fail succeed)
                (if (or? f)
                    (if bool
                        (solve-any (or-args f) #t cur fail succeed)
                        (solve-all (or-args f) #f cur fail succeed))
                    (if (and? f)
                        (if bool
                            (solve-all (and-args f) #t cur fail succeed)
                            (solve-any (and-args f) #f cur fail succeed))
                        (fail))))))]

     ;; solve-all

     [solve-all 
      (lambda (fs bool cur fail succeed)
        (if (null? fs)
            (succeed cur fail)
            (solve-formula (car fs) 
                           bool 
                           cur 
                           fail 
                           (lambda (env resume) 
                             (solve-all (cdr fs) bool env resume succeed)))))]
     
     ;; solve-any

     [solve-any 
      (lambda (fs bool cur fail succeed)
        (if (null? fs)
            (fail)
            (solve-formula (car fs)
                           bool
                           cur
                           (lambda () (solve-any (cdr fs) bool cur fail succeed))
                           succeed)))]
     ;; solve-symbol
     
     [solve-symbol 
      (lambda (x bool cur fail succeed)
        ;; We use an internal loop to safely check bindings without relying 
        ;; on 'find', which might throw a runtime error if the symbol is unbound.
        (letrec ([check-env 
                  (lambda (env)
                    (if (null? env)
                        (succeed (bind x bool cur) fail)
                        (if (= x (car (car env)))
                            (if (= bool (cadr (car env))) 
                                (succeed cur fail)
                                (fail)) 
                            (check-env (cdr env)))))])
          (check-env cur)))])
    
    ;; Kick off the solver by asking it to make the initial formula #t
    (solve-formula f #t '() fail succ)))


;; unit tests
(check-assert (function? solve-sat))            ; correct name
(check-error  (solve-sat))                      ; not 0 arguments
(check-error  (solve-sat 'x))                   ; not 1 argument
(check-error  (solve-sat 'x (lambda () 'fail))) ; not 2 args
(check-error  (solve-sat 'x (lambda () 'fail) (lambda (c r) 'succeed) 'z)) ; not 4 args

(check-error (solve-sat 'x (lambda () 'fail) (lambda () 'succeed))) ; success continuation expects 2 arguments, not 0
(check-error (solve-sat 'x (lambda () 'fail) (lambda (_) 'succeed))); success continuation expects 2 arguments, not 1
(check-error (solve-sat                                             ; failure continuation expects 0 arguments, not 1
                   (make-and (list2 'x (make-not 'x)))
                   (lambda (_) 'fail)
                   (lambda (_) 'succeed)))

(check-expect   ; x can be solved
  (solve-sat 'x (lambda () 'fail)
                (lambda (cur resume) 'succeed))
  'succeed)

(check-expect   ; x is solved by '((x #t))
  (solve-sat 'x (lambda () 'fail)
                (lambda (cur resume) (find 'x cur)))
  #t)

(check-expect   ; (make-not 'x) can be solved
  (solve-sat (make-not 'x)
             (lambda () 'fail)
             (lambda (cur resume) 'succeed))
  'succeed)

(check-expect   ; (make-not 'x) is solved by '((x #f))
  (solve-sat (make-not 'x)
             (lambda () 'fail)
             (lambda (cur resume) (find 'x cur)))
  #f)

(check-expect   ; (make-and (list2 'x (make-not 'x))) cannot be solved
  (solve-sat (make-and (list2 'x (make-not 'x)))
             (lambda () 'fail)
             (lambda (cur resume) 'succeed))
  'fail)

