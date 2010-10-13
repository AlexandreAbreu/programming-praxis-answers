;;; Solution to the 2nd exercices - Gambit Scheme version
;;; http://programmingpraxis.com/2009/02/19/sieve-of-eratosthenes/

;; srfi-1 stuff
(define filter
  (lambda (f l)
    (cond
     ((null? l) '())
     ((f (car l)) (filter f (cdr l)))
     (else (cons (car l) (filter f (cdr l))))
     )
    )
  )

(define compute-max-factor
  (lambda (n)
    (if (< n 0)
        (error "cannot compute sqrt of negative number")
        (exact->inexact (floor (sqrt n)))
        )
    )
  )

;; integer -> list
;; retrieves the list from 3 (2 is obvious and even numbers are removed from the list)
(define create-list-of-factors
  (lambda (n)
    (define create-list-of-factors-internal
      (lambda (n)
        (if (<= n 3)
            (list 3)
            (cons n (create-list-of-factors (- n 2)))
            )
        )
      )
    (if (even? n)
        (create-list-of-factors-internal (- n 1))
        (create-list-of-factors-internal n)
        )
    )
  )

(define non-multiples-of-from-list
  (lambda (n l)
    (filter (lambda (num) (= 0 (remainder num n))) l)
    )
  )

(define sieve
  (lambda (n)
    (cond
     ((or (not (number? n)) (< n 0)) (error "invalid input (must be a positive number)"))
     ((= n 1) (println "result: 1"))
     ((= n 2) (println "result: 1 2"))
     (else
      (let loop (
                 [factors (reverse (create-list-of-factors n))]
                 [primes '()]
                 [max-factor (compute-max-factor n)]
                 )
        (if (or (null? factors) (> (car factors) max-factor))
            (pretty-print (append primes factors))
            (loop (non-multiples-of-from-list (car factors) factors)
                  (cons (car factors) primes)
                  max-factor)
            )
        )
      )
     )
    )
  )

