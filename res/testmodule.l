(let x 3)

(defun (hello name)
  (set x (+ x 1))
  (out (str-concat "hello " name "! (" (to-str x) ")"))
)


(def y 3)


