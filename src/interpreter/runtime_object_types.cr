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

# TODO add an error value type which will be returned on all failed operations instead of an error
# program should only 'panic' if an error is received as argument to any function except:
# error related functions, these obviously dont panic if they receive an error

record ListObject,
  elems : Array(RuntimeValue)

record ErrorValue,
  reason : String


alias RuntimeValue = NumberValue | StringValue | SymbolValue | ListObject | DefunRef | NilValue | ErrorValue

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
