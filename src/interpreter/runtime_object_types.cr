TRUE = "'#t"
FALSE = "'#f"

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

record SymbolValue, name : String do
  def self.trueValue
    return SymbolValue.new TRUE
  end
  def self.falseValue
    return SymbolValue.new FALSE
  end
end

record NilValue

record ListObject,
  elems : Array(RuntimeValue)

alias RuntimeValue = NumberValue | StringValue | SymbolValue | ListObject | DefunRef | NilValue

def rtvToStr(rtv : RuntimeValue) : String
  case rtv
  when DefunRef
    return "#{rtv.name}"
  when SymbolValue
    return "#{rtv.name}"
  when StringValue
    return "#{rtv.value}"
  when NumberValue
    return "#{rtv.value}"
  when NilValue
    return "nil"
  when ListObject
    result = "'("
    if rtv.elems.size > 0
      result += "#{rtvToStr(rtv.elems[0])}"
    end
    rtv.elems[1..].each do |elem|
      result += " #{rtvToStr(elem)}"
    end
    result += ")"
    return result
  else
    raise "unexpected no case matched while converting to string"
  end
end
