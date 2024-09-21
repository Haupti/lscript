record LSymbol, name : String

record LExpression, first : LAtom, arguments : Array(LExpression)

alias LNumber = Int64 | Float64 | Int32 | Float32

alias LAtom = LNumber | String | LSymbol

alias LData = LAtom | Array(LData) | LExpression

alias LList = Array(LData)

