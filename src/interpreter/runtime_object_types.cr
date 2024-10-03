TRUE = "'#t"
FALSE = "'#f"

class FunctionObject
  @name : LRef
  @arguments : Array(LRef)
  @body : Array(LData)
  @enclosed : EvaluationContext
  def initialize(@name : LRef, @arguments : Array(LRef), @body : Array(LData), @enclosed : EvaluationContext)
  end

  def name()
    return @name
  end
  def arguments()
    return @arguments
  end
  def body()
    return @body
  end
  def enclosed()
    return @enclosed
  end
end

record NumberValue,
  value : Int64 | Int32 | Float64 | Float32

record StringValue,
  value : String

record BuildinFunctionRef,
  name  : String

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

record ErrorValue,
  reason : String


alias RuntimeValue = NumberValue | StringValue | SymbolValue | ListObject | FunctionObject | BuildinFunctionRef | NilValue | ErrorValue

def rtvToStr(rtv : RuntimeValue) : String
  case rtv
  when FunctionObject
    return "function"
  when BuildinFunctionRef
    return "function"
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
    if rtv.elems.size >= 1
      rtv.elems[1..].each do |elem|
        result += " #{rtvToStr(elem)}"
      end
    end
    result += ")"
    return result
  when ErrorValue
    return "(error \"#{rtv.reason}\")"
  else
    raise "unexpected no case matched while converting to string"
  end
end
