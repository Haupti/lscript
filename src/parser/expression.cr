record Symbol, name : String

record Expression, first : Atom, arguments : Array(Expression)

alias Atom = Number | String | Symbol

alias List = Array(Data)

alias Data = Atom | List | Expression

