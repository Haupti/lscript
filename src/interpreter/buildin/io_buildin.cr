module IOBuildin
  extend self

  def evaluateOut(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 1
      raise "'out' expects at least one arguments"
    end
    result = ""
    arguments.each do |arg|
        result += "#{rtvToStr(arg)}"
    end
    puts result
    return NilValue.new
  end

end
