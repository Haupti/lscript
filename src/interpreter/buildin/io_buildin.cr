
require "./error_guardian.cr"
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

end
