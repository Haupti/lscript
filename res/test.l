; comment

(let x 1)
(let y 5)
(defun (fizzbuzz a)
  (if (eq? (mod a 3) (mod a 5) 0) "fizzbuzz" 
  (if (eq? (mod a 3) 0) "fizz"
  (if (eq? (mod a 5) 0) "buzz"
  (to-str a)
  )))
)

(out (fizzbuzz 15))
(out (fizzbuzz 5))
(out (fizzbuzz 3))
(out (fizzbuzz 2))

(out (contains? '(x 2 3) 1))

(out (str-concat "a" "b"))
(out (str-contains? "cab" "a"))

(out (map fizzbuzz '(1 2 3 4 5)))
(out (concat '(3 2 1 0) '(1 2 3 4 5)))
(out (head '(32 1)))
(out (head '(1)))
(out (tail '()))
(out (tail '(1)))
(out (tail '(1 2)))

(defun (lt5filter num)
  (if (lt? num 5) '#t '#f)
)
(out (filter lt5filter '(1 2 3 4 5 6)))
(out (get '(1 2) 1))

(out (err "hi"))
(out (err? (err "hi")))
(out (err-reason (err "hi")))

(out (char-at "hallo" 2))

;(let asdf (get-input))
;(out asdf)


(defun (outer)
    (let z 3)
    (defun (inner a)
        (+ a z)
    )
    inner
)

(defun (inside-out) (outer))
(out "hwa")
(debug ((inside-out) 2))

(defun (returnsplus)
  +
)

(out ((returnsplus) 2 1))
