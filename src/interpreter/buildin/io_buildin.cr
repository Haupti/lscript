module IOBuildin
  extend self

  def evaluateOut(arguments : Array(RuntimeValue)) : RuntimeValue
    result = ""
    arguments.each do |arg|
        result += "#{rtvToStr(arg)}"
    end
    puts result
    return NilValue.new
  end

  def evaluateGetInput(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 0
      raise Err.msgAt(position, "'get-input' expects one argument")
    end
    result = gets
    if result.nil?
      return NilValue.new
    else
      return StringValue.new result
    end
  end

  def evaluateEnvGet(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise Err.msgAt(position, "'env-get' expects one argument")
    end
    fst = arguments[0]
    unless fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'env-get' expects a string", fst)
    end
    env = ENV[fst.value]?
    if env.nil?
      return ErrorValue.new "'#{fst.value}' not in environment"
    else
      return StringValue.new env
    end
  end

  def evaluateArgsGet(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 0
      raise Err.msgAt(position, "'args-get' expects no arguments")
    end

    strs : Array(RuntimeValue) = ARGV.map do |elem|
      (StringValue.new elem).as RuntimeValue
    end
    return ListObject.new strs
  end

end
