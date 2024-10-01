# lscript

this is a interpreted scripting language with lisp-inspired syntax.\
currently it is dynamically typed, this might change.

## types
there are a few types: numbers, strings, symbols, lists, errors and functions.
there are no booleans at the moment.

## symbols
symbols start with a quote and then contain any arbitrary characters except quotes, spaces and newlines.\
there are two special symbols, which are used for boolean operations:\
`'#f` and `'#t`.

## lists
lists are 'expressions of data'. like a expressions lists are simply stuff withing braces. however, to prevent evaluation like an expression,
you quote the first bracket:
`'(+ 1 2) ; -> list of +, 1 and 2
(+ 1 2) ; -> 3`

## build-in functions
these functions are available without importing anything (which at the moment is not possible at all).
here is simply a list of functions that exist:

### Number operations
* `(+ number number)`
* `(- number number)`
* `(* number number)`
* `(/ number number)`
* `(mod interger interger)`
* `(lt? number number)`
* `(lte? number number)`
* `(gt? number number)`
* `(gte? number number)`

### Booleanish-Symbol operations
these functions expect the true or false symbols
* `(and symbol symbol)`
* `(or symbol symbol)`
* `(not symbol symbol)`

### special functions
* `debug`
* `to-str`
* `typeof`

### error handling
* `err`
* `err?`
* `err-reason`

### io
* `out`
* `get-input`

### list
* `contains?`
* `length`
* `sublist`
* `map`
* `concat`
* `head`
* `tail`
* `filter`
* `get`

### equality
* `eq?`

### strings
* `str-concat`
* `substr`
* `str-replace` 
* `str-replace-all`
* `str-contains?`
* `str-length`
* `char-at`

- [redstar](https://github.com/haupti) - creator and maintainer
