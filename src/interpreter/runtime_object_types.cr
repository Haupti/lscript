record FunctionDefinition,
  name : LRef,
  arguments : Array(LRef),
  body : Array(LData)

record DefunRef,
  name : String

record NumberValue,
  value : Int64 | Int32 | Float64 | Float32

record StringValue,
  value : String

record SymbolValue,
  name : String

record NilValue

record ListObject,
  elems : Array(RuntimeValue)

alias RuntimeValue = NumberValue | StringValue | SymbolValue | ListObject | DefunRef | NilValue
