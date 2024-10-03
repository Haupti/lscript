record LSymbol, name : String
record LRef, name : String
record LString, value : String

alias LNumberType = Int64 | Float64 | Int32 | Float32
record LNumber, value : LNumberType

alias LAtom = LNumber | LString | LSymbol | LRef

class LExpression
   @first : LRef | LExpression
   @arguments : Array(LData)
   def initialize(@first : LRef | LExpression, @arguments : Array(LData))
   end
   def first()
     return @first
   end
   def arguments()
     return @arguments
   end
end

record LList, elems : Array(LData)

alias LData = LAtom | LList | LExpression

