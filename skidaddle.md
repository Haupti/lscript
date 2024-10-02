# drawing board

## how do lambda functions keep reference ?

```
(defun (function-provider)
    (let x 1)
    (def fun (lambda (x) "hi"))
    fun
)

```
calling this function returns a function that depends on the scope of the function-provider function.
therefor it needs to capture the variables used. but how?
one idea is, that lambda functions or functions inside functions dont keep mutable references to 'external' variables.
-> i.e. they just take a copy of the variable, but not a reference.
this would however be a problem for callback functions as they would not work.
you could not do this:
```

(defun (some-other-function callback)
    (callback)
)

(defun (do-stuff)
    (let x 2)
    (let callback (lambda () (set x 3)))
    (some-other-function callback)
    (if (= x 2)
        "x was not touched"
        "x was changed"
        )
)
```

in all cases where the parent scope outlives the lambda function this would be easy to solve. just let the lambda function know its parent scope (where it was created).
however, this is not as trivial if the function is returned.
in these cases the funciton scope would not outlive the lambda function.
what happens if the function scope ends while the lambda function keeps a reference to the parent scope?
technically this would prevent the parent scope from beeing garbage collected, since it is still referenced. however, it would be gc'd after the lambda function is gc'd. this is technically exactly what i want. the last question that needs to be answered is: how do
i keep a reference to a scope preventing its cleanup. can i just pass 'self' and it survives?
