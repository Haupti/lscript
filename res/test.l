; comment

(let x 2)
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
