require "../error_utils.cr"

TRUE = "'#t"
FALSE = "'#f"

class FunctionObject
  @name : LRef
  @arguments : Array(LRef)
  @body : Array(LData)
  @enclosed : EvaluationContext
  @hasBeenEvaluated : Bool = false
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
  def hasBeenEvaluated()
    return @hasBeenEvaluated
  end
  def flagAsEvaluated()
    puts "flagged"
    @hasBeenEvaluated = true
  end
end

alias TableKeyType = StringValue | NumberValue | SymbolValue

record TableObject,
  data : Hash(TableKeyType, RuntimeValue)

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


alias RuntimeValue = NumberValue | StringValue | SymbolValue | ListObject | FunctionObject | TableObject | BuildinFunctionRef | NilValue | ErrorValue

def typeName(rtv : RuntimeValue) : String
  case rtv
  when StringValue
    return "string"
  when NumberValue
    return "number"
  when SymbolValue
    return "symbol"
  when ListObject
    return "list"
  when FunctionObject
    return "function"
  when TableObject
    return "table"
  when NilValue
    return "nil"
  else
    raise Err.bug("unexpected no case matched while evaluating type")
  end
end

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
  when TableObject
    result = "(table"
    if rtv.data.keys.size > 0
      result += " (#{rtvToStr(rtv.data.keys[0])} #{rtvToStr(rtv.data[rtv.data.keys[0]])})"
    end
    if rtv.data.keys.size >= 1
      rtv.data.keys[1..].each do |key|
        result += " (#{rtvToStr(key)} #{rtvToStr(rtv.data[key])})"
      end
    end
    result += ")"
    return result
  when ErrorValue
    return "(error \"#{rtv.reason}\")"
  else
    raise Err.bug("unexpected no case matched while converting to string")
  end
end
