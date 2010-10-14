;;; programming praxis exercice http://programmingpraxis.com/2009/02/20/rot13/
;;; Gambit Scheme version

(define *sample-input* "Cebtenzzvat Cenkvf vf sha!")

;; srfi-1 stuff
(define first car)
(define second cadr)

(define lower-case-range '(#\a #\z))
(define upper-case-range '(#\A #\Z))

(define is-case-range-maker
  (lambda (first-char last-char)
    (lambda (c)
      (and (>= (char->integer c) (char->integer first-char)) (<= (char->integer c) (char->integer last-char)))
      )
    )
  )

(define is-uppercase-range (is-case-range-maker (first upper-case-range) (second upper-case-range)))
(define is-lowercase-range (is-case-range-maker (first lower-case-range) (second lower-case-range)))

;; only if necessary
;; char -> char
(define rot13-char
  (lambda (c)
    (define do-rot13-char
      (lambda (c first-char)
        (integer->char (+ (char->integer first-char) (modulo (+ (- (char->integer c) (char->integer first-char)) 13) 26)))
        )
      )
    (cond
     ((not (char? c)) (error "Got: Not a char"))
     ((is-uppercase-range c) (do-rot13-char c (first upper-case-range)))
     ((is-lowercase-range c) (do-rot13-char c (first lower-case-range)))
     (else c)
     )
    )
  )

(define rot13
  (lambda (input)
    (map
     (lambda (c)
       (rot13-char c)
       )
     (string->list input)
     )
    )
  )
