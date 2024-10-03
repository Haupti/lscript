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

  def evaluateGetInput(arguments : Array(RuntimeValue)) : RuntimeValue
    result = gets
    if result.nil?
      return NilValue.new
    else
      return StringValue.new result
    end
  end

end
