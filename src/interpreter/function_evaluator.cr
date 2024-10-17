require "./interpreter.cr"
require "../error_utils.cr"

module FunctionEvaluator
  extend self

  def evaluateFunction(callPosition : Position, fn : FunctionObject, args : Array(RuntimeValue)) : RuntimeValue
    if fn.arguments.size != args.size
      raise Err.msgAt(callPosition, "#{fn.name.name} expects #{fn.arguments.size} arguments, but got #{args.size}")
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

  def evaluateTableFunction(callPosition : Position, table : TableObject, args : Array(RuntimeValue)) : RuntimeValue
    if args.size < 1 || args.size > 2
      raise Err.msgAt(callPosition, "table access function expects one or two arguments, but got #{args.size}")
    end

    if args.size == 1
      key = args[0]
      if !key.is_a? StringValue && !key.is_a? NumberValue && !key.is_a? SymbolValue
        raise Err.msgAt(callPosition, "table there can only be values at valid keys (string, number and symbol)")
      end
      value = table.data[key]?
      if value.nil?
        raise Err.msgAt(callPosition, "no value at key #{rtvToStr(args[0])} in table")
      else
        return value
      end
    else
      data = table.data
      key = args[0]
      value = args[1]
      if !key.is_a? StringValue && !key.is_a? NumberValue && !key.is_a? SymbolValue
        raise Err.msgAt(callPosition, "table keys must be string, number or symbol")
      end
      data[key] = value
      return TableObject.new data
    end
  end

  def evaluateReferencedFunction(callPosition : Position,
      fn : LRef | BuildinFunctionRef,
      args : Array(RuntimeValue),
      context : EvaluationContext
  ) : RuntimeValue
    if BuildIn::INSTANCE.hasFunction(fn)
      return BuildIn::INSTANCE.evaluateFunction(callPosition, fn, args, context)
    else
      raise "'#{fn.name}' not in scope"
    end
  end
end
