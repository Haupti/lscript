require "./position.cr"

record LSymbol, name : String, position : Position
record LRef, name : String, position : Position
record LString, value : String, position : Position

alias LNumberType = Int64 | Float64 | Int32 | Float32
record LNumber, value : LNumberType, position : Position

alias LAtom = LNumber | LString | LSymbol | LRef

class LExpression
   @position : Position
   @first : LRef | LExpression
   @arguments : Array(LData)
   def initialize(@first : LRef | LExpression, @arguments : Array(LData), @position : Position)
   end
   def first()
     return @first
   end
   def arguments()
     return @arguments
   end
   def position()
     return @position
   end
end

record LList, elems : Array(LData), position : Position

record LNil, position : Position

alias LData = LAtom | LList | LExpression | LNil

def positionOf(datum : LData) : Position
  case datum
  when LNumber
    return datum.position
  when LString
    return datum.position
  when LSymbol
    return datum.position
  when LRef
    return datum.position
  when LList
    return datum.position
  when LExpression
    return datum.position
  when LNil
    return datum.position
  else raise Err.bug("unexpected not handed case")
  end
end

