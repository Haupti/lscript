module FunctionEvaluator
  extend self

  def evaluateFunction(fn : FunctionDefinition, args : Array(RuntimeValue)) : RuntimeValue
    if fn.arguments.size != args.size
      raise "#{fn.name.name} expects #{fn.arguments.size} arguments, but got #{args.size}"
    end

    argsMap : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new
    fn.arguments.each_with_index do |fnarg, index|
      argsMap[fnarg.name] = args[index]
    end

    scope : FunctionScope = FunctionScope.new(argsMap, fn.enclosed)
    result : RuntimeValue = NilValue.new
    fn.body.each do |datum|
      result = Interpreter.evaluate(datum, scope)
    end
    return result
  end
end
