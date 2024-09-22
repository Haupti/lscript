record LSymbol, name : String

record LExpression, first : LAtom, arguments : Array(LData)

alias LNumberType = Int64 | Float64 | Int32 | Float32
record LNumber, value : LNumberType

alias LAtomType = LNumber | String | LSymbol
record LAtom, value = LAtomType

record LList, elems : Array(LData)

alias LData = LAtom | LList | LExpression


