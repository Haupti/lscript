record LSymbol, name : String

record LExpression, first : LAtom, arguments : Array(LData)

alias LNumberType = Int64 | Float64 | Int32 | Float32
record LNumber, value : LNumberType

record LString, value : String
alias LAtom = LNumber | LString | LSymbol

record LList, elems : Array(LData)

alias LData = LAtom | LList | LExpression


