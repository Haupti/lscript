require "json"

module JsonBuildin
  extend self

  def evaluateToJson(callPosition : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise Err.msgAt(callPosition, "'json-to' expects one argument")
    end
    fst = arguments[0]
    unless fst.is_a? TableObject
      raise Err.unexpectedValue(callPosition, "'json-to' expects a table", fst)
    end

    return StringValue.new toJsonString(fst)
  end

  def evaluateFromJson(callPosition : Position, arguments : Array(RuntimeValue)) : RuntimeValue
  end


  def toJsonString(rtv : TableObject) : StringValue | ErrorValue
    for
  end

end
