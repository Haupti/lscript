; comment

;(let x 1)
;(let y 5)
;(defun (fizzbuzz a)
;  (if (eq? (mod a 3) (mod a 5) 0) "fizzbuzz" 
;  (if (eq? (mod a 3) 0) "fizz"
;  (if (eq? (mod a 5) 0) "buzz"
;  (to-str a)
;  )))
;)
;
;(out (fizzbuzz 15))
;(out (fizzbuzz 5))
;(out (fizzbuzz 3))
;(out (fizzbuzz 2))
;
;(out (contains? '(x 2 3) 1))
;
;(out (str-concat "a" "b"))
;(out (str-contains? "cab" "a"))
;
;(out (map fizzbuzz '(1 2 3 4 5)))
;(out (concat '(3 2 1 0) '(1 2 3 4 5)))
;(out (head '(32 1)))
;(out (head '(1)))
;(out (tail '()))
;(out (tail '(1)))
;(out (tail '(1 2)))
;
;(defun (lt5filter num)
;  (if (lt? num 5) '#t '#f)
;)
;(out (filter lt5filter '(1 2 3 4 5 6)))
;(out (get '(1 2) 1))
;
;(out (err "hi"))
;(out (err? (err "hi")))
;(out (err-reason (err "hi")))
;
;(out (char-at "hallo" 2))

;(let asdf (get-input))
;(out asdf)
;
;(defun (returnsplus)
;  +
;)
;
;(out ((returnsplus) 2 1))
;
;(defun (return-lambda)
;  (def myfun (lambda (a b) (+ a b)))
;  (out "WHOOOOP")
;  (out (myfun 1 2))
;  myfun
;)
;
;(out ((return-lambda) 2 2))


;(defun (outer)
;    (out "what")
;    (let z 3)
;    (def inner (lambda (a)
;        (+ a z)
;      )
;    )
;    inner
;)

;(debug ((outer) 88))
;(debug ((outer) 111111))

(defun (call-twice db)
  (db)
  (db)
)

(defun (with-counter)
  (let z 0)
  (def callback (lambda ()
    (set z (+ z 1))
  ))
  (callback)
  (call-twice callback)
  (out z)
)

(with-counter)
