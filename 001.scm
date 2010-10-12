;; Exercice 1 of programming praxis
;; http://programmingpraxis.com/2009/02/19/rpn-calculator/

;; TODO comply to the one line rule

;; no srfi-1 avail (function useless in here)
(define fold
  (lambda (f init l)
    (cond
     ((null? l) init)
     (else (f (car l) (fold f init (cdr l))))
     )
    )
  )

;; s -> boolean
(define exit?
  (lambda (s)
    (and (string? s) (eq? (string->symbol s) 'exit))
    )
  )

(define-structure
  operand
  ;; char
  name
  ;; function
  action
  )

;; assume that we act on numbers
(define *operands*
  `(
    ,(make-operand "+" (lambda (a b) (+ a b)))
    ,(make-operand "-" (lambda (a b) (- a b)))
    ,(make-operand "*" (lambda (a b) (* a b)))
    ;; TODO check for div by 0
    ,(make-operand "/" (lambda (a b) (/ a b)))
    )
  )

;; -> operand or #f
(define get-operand
  (lambda (what search-in f)
    (cond
     ((null? search-in) #f)
     ((equal? (f (car search-in)) what) (car search-in))
     (else (get-operand what (cdr search-in) f))
     )
    )
  )

;; small helper
;; string -> operand or #f
(define get-operand-by-name
  (lambda (name)
    (get-operand name *operands* (lambda (operand) (operand-name operand)))
    )
  )

;; string -> boolean
(define operand?
  (lambda (s)
    (and (string? s) (get-operand-by-name s))
    )
  )

(define dispatch-operand
  (lambda (operand rest)
    (if (or (not (operand? operand)) (not (eq? 2 (length rest))))
        (error "Invalid operand name")
        (apply (operand-action (get-operand-by-name operand)) rest)
        )
    )
  )

(define rpn
  (lambda ()
    (define empty-stack '())
    (define push
      (lambda (item stack)
        (cons item stack)
        )
      )
    (define next-token
      (lambda ()
        (read)
        )
      )
    (let loop (
               [stack empty-stack]
               [token (next-token)]
               )
      (cond
       ;; number
       (
        (number? token)
        (loop (push token stack) (next-token))
        )
       ;; operand
       (
        (operand? (symbol->string token))
        (if (>= (length stack) 2)
            (let ([result (dispatch-operand (symbol->string token) (list (cadr stack) (car stack)))])
              (println "result: " result)
              (loop (push result (cddr stack)) (next-token))
              )
            (error "An operand should only be run against a stack of 2 numbers")
          )
        )
       ;; exit?
       (
        (exit? (symbol->string token))
        (println "bye")
        )
       ;; catch all
       (else (error "Invalid (unrecognized token)"))
       )
      )
    )
  )

