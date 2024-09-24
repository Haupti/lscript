record LSymbol, name : String
record LRef, name : String
record LString, value : String
record LNil

alias LNumberType = Int64 | Float64 | Int32 | Float32
record LNumber, value : LNumberType

alias LAtom = LNumber | LString | LSymbol | LRef

record LExpression, first : LRef, arguments : Array(LData)

record LList, elems : Array(LData)

alias LData = LAtom | LList | LExpression

alias LValue = LNumber | LString | LSymbol | LList | LNil

