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
```
'(+ 1 2) ; -> list of +, 1 and 2
(+ 1 2) ; -> 3
```

## keywords
currently there are only very few keywords, and i like to keep the list short.
these are:
* `(defun (name (...args) ...body))` - defines a function in the current scope
* `(lambda (...args) ...body)` - creates a function object and returns it
* `(def name value-expession)` - defines a constant in the current scope
* `(let name value-expession)` - defines a mutable value in the current scope
* `(set name value-expession)` - mutates a already defined mutable value
* `(if condition-expession then-expression else-expression)` - dont have to explain this
* `(load-module string)` - loads a module from a file as table containing the functions and constants. path must be relative to entrypoint file
* ; - comment

## comments
comments start at a ';' character but also *end* at a ';' character.
comments also end at '\n' newline characters.
here is an example:
```
; comment
(defun ;this is my cool funciton; (funcy (bla) (body bla)))
(funcy "123" ;whoop;) ; also a comment

```

### defining stuff
examples speak more that lots of text:
```
; functions
(defun (add-one a) (+ a 1))
(add-one 1) ; -> 2

; constants
(def a 5)
(add-one a) ; -> 6

; variables
(let b 3)
(add-one b) ; -> 4
(set b 8)
(add-one b) ; -> 9

; comments, heh
; this is a comment

; if
(if (lt? 5 3) (out "5 is less than 3") (out "3 is less than 5")) ; -> prints "3 is less than 5" to stdout
; special behaviour here is, that the first conditional expression is not evaluated unless the condition is '#t
```

## functions
i should really understand how my functions work. they work. and they work the way i want to. i'm just not really sure how.


## build-in functions
these functions are available without importing anything (which at the moment is not possible at all).
here is simply a list of functions that exist:

### Number operations
* `(+ number number) -> number`
* `(- number number) -> number`
* `(* number number) -> number`
* `(/ number number) -> number`
* `(mod interger interger) -> number`
* `(lt? number number) -> symbol`
* `(lte? number number) -> symbol`
* `(gt? number number) -> symbol`
* `(gte? number number) -> symbol`

### Booleanish-Symbol operations
these functions expect the true or false symbols
* `(and symbol symbol) -> symbol`
* `(or symbol symbol) -> symbol`
* `(not symbol symbol) -> symbol`

### special functions
* `(debug *) -> nil`
* `(to-str *) -> string`
* `(typeof *) -> string`

### error handling
* `(err string) -> error`
* `(err? *) -> symbol`
* `(err-reason error) -> string`
* `(panic error) -> nil`

### io
* `(out *) -> nil`
* `(get-input) -> string`

### list
* `(contains? list elem) -> symbol`
* `(length list) -> number`
* `(sublist list number [number]) -> list`
* `(map function list) -> list`
* `(concat list list) -> list`
* `(head list<T>) -> T`
* `(tail list) -> list`
* `(filter function list) -> list` 
* `(get list<T> integer) -> T`

### equality
* `(eq? * *) -> symbol`

### strings
* `(str-concat string string) -> string`
* `(substr string number [number]) -> string`
* `(str-replace string string string) -> string` 
* `(str-replace-all string string string) -> string`
* `(str-contains? string string) -> symbol`
* `(str-length string) -> number`
* `(char-at string integer) -> string`

## tables
tables are a versatile data type. they kind of act like maps, structures or dictionaries (depending on which language you know).\
i'll just give you an example how to use them:
```
; defines a table with one key "'hi" with value "user"
(let mytable (table ('hi "user")))

; access a tables value:
(mytable 'hi) ; -> "user"
; or
((table ('hi "steve")) 'hi) ; -> "steve"

; to create a modified table do this:
(let mynewtable (table))
(set mynewtable (mynewtable 'hi "paul"))
```
if you give a table one value, it will be interpreted as a access to the data stored at this key.\
if you give a table two values, this will be interpreted as a set operation at this given key with given data at the second argument.

## modules

you can import functions and constants from other files, you cannot import variables from other files.\
to do that, you can use the `load-module` keyword. here is a example:
```
; code/files/fileA.l
(defun (hello name)
    (out (str-concat "hello " name "!"))
    )

; code/fileB.l
(def mymodule (load-module "files/fileA.l"))
((mymodule 'hello) "steve")
```
the path given must be a relative path from the directory of the main file as shown in the example.\
the `load-module` function will read the files code, interpret it and then build a table object out of its 
**constant** values. this includes everything that is defined via the `def` and `defun` keywords.\
this does **not** include variables. however, variables can be modified and read. you have to use getters and setters for them though.\
the table contains all constants and functions as keys. to access them, you just have to call the table (as with regular tables) with a symbol with the same name as the function or constant. this returns a value or function to use or evaluate.


## Planned

### buildin
* read file & write file
* json decoding and encoding of tables
* program arguments
* env vars
* eval which evaluates symbols and lists (treats them as function name ?, lists are treated as expession ?)
* network: tcp / http / socket ?
* parse number
* 'block' and expression that does nothing except evalute a list of expression in the body with its own scope

### features
* type verification
* macros (either the c-like ones or better, but this is really for the future)

### optimizations
* loading modules and keeping the parsed code in memory so this part does not have to be done again when importing the same module somewhere else.
* evaluat the code and keep the prebuild module table and copy it when loaded again

### other
* language server for editors

### about the planned features: type verification
id really like to have typing (somehow).\
i have two ideas on how to achieve that.\
the first is to only run verifications based on what is written down. i.e.
if you see somehing like this:
```
(def x 1)
(char-at x 1)
```
the type verifier should be able to determine beforehand, that this will not succeed.\
however, there is one big problem with this: let. \
with mutable variables, this is not possible (or really difficult, im not sure), since a variable\
can change its type and therefor i will not really be sure if this can work always.\
so in this first scenario: the type verifier can only check some code for type safety.\

which is why i have anohter idea which would fix that problem but also take away some of the freedom:\
variables, once assigned a value, can only be assigned values of the same type like the one originally defined with.\

the third idea is to implement a feature to type stuff. this would probably introduce new syntax like this:
```
(let :int x 1)
```
where type values would start with `:` and are then used for checking.
this however would make function definitions kind of ugly:
```
(defun :int (sum :int x :int y) ...)
```
not sure if i like that.


- [redstar](https://github.com/haupti) - creator and maintainer
