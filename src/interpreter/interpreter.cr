require "../parser/expression.cr"
require "../error_utils.cr"
require "./buildin/buildin.cr"
require "./evaluation_context.cr"
require "./runtime_object_types.cr"

module Interpreter
  extend self

  def loadModule(code : Array(LData)) : TableObject
    result, context = runAndYieldContext(code)
    tableData = Hash(TableKeyType, RuntimeValue).new
    context.@constants.keys.each do |key|
      puts key
      tableData[SymbolValue.new ("'" + key)] = context.@constants[key]
    end
    return TableObject.new tableData
  end

  def run(code : Array(LData)) : RuntimeValue
    return runAndYieldContext(code)[0]
  end

  def runAndYieldContext(code : Array(LData)) : {RuntimeValue, EvaluationContext}
    context = EvaluationContext.new

    result : RuntimeValue = NilValue.new
    code.each do |datum|
      case datum
      when LExpression
        result = evaluateExpression(datum, context)
      when LAtom
        result = evaluate(datum, context)
      when LList
        result = evaluate(datum, context)
      else
        raise Err.msgAt(datum.position, "unexpected no case matched while top level evaluation #{datum}")
      end
    end
    return result, context
  end

  def evaluate(datum : LData, context : EvaluationContext) : RuntimeValue
    case datum
    when LNumber
      return NumberValue.new datum.value
    when LString
      return StringValue.new datum.value
    when LRef
      if context.hasConstant datum
        return context.getConstantValue datum
      elsif context.hasVariable datum
        return context.getVariableValue datum
      elsif BuildIn::INSTANCE.hasFunction datum
        return BuildinFunctionRef.new datum.name
      else
        raise Err.msgAt(datum.position, "#{datum.name} not in scope")
      end
    when LSymbol
      return SymbolValue.new datum.name
    when LList
      return ListObject.new evaluateList(datum.elems, context)
    when LExpression
      return evaluateExpression(datum, context)
    else
      raise Err.msgAt(datum.position, "unexpected data, cannot evaluate: #{datum}")
    end
  end

  def evaluateList(datas : Array(LData), context : EvaluationContext) : Array(RuntimeValue)
    evaluatedListElements = datas.map do |datum|
      case datum
      when LRef
        if context.hasVariable datum
          context.getVariableValue datum
        elsif context.hasConstant datum
          context.getConstantValue(datum)
        else
          raise Err.msgAt(datum.position, "unexpected no case matched while evaluating list (#{datum})")
        end
      when LNumber
        NumberValue.new datum.value
      when LSymbol
        SymbolValue.new datum.name
      when LString
        StringValue.new datum.value
      when LList
        ListObject.new evaluateList(datum.elems, context)
      when LExpression
        evaluateExpression(datum, context)
      else
        raise Err.msgAt(datum.position, "unexpected no case matched while evaluating a list (#{datum})")
      end
    end
  return evaluatedListElements
  end

  def evaluateExpression(expr : LExpression, context : EvaluationContext) : RuntimeValue
    first = expr.first
    case first
    when LRef
      return evaluateDirectExpression(first, expr.arguments, context)
    when LExpression
      firstResult = evaluateExpression(first, context)
      if firstResult.is_a? FunctionObject
        return FunctionEvaluator.evaluateFunction(expr.position, firstResult, evaluateList(expr.arguments, context))
      elsif firstResult.is_a? TableObject
        return FunctionEvaluator.evaluateTableFunction(expr.position, firstResult, evaluateList(expr.arguments, context))
      elsif firstResult.is_a? BuildinFunctionRef
        return FunctionEvaluator.evaluateReferencedFunction(expr.position, firstResult, evaluateList(expr.arguments, context), context)
      else
        raise Err.msgAt(first.position, "expected a function name but got '#{rtvToStr(firstResult)}'")
      end
    else
      raise Err.bug("should not happen")
    end
  end

  def evaluateDirectExpression(first : LRef, arguments : Array(LData), context : EvaluationContext) : RuntimeValue
    refName = first.name
    case refName
    when "defun"
      if arguments.size < 2
        raise Err.msgAt(first.position, "defun expects at least two arguments")
      elsif !arguments[0].is_a? LExpression
        raise Err.msgAt(first.position,"defun expects an expression as first argument")
      end
      callTemplate = arguments[0].as LExpression
      body = arguments[1..]
      callTemplateFirst = callTemplate.first
      if !callTemplateFirst.is_a? LRef
        raise Err.msgAt(callTemplateFirst.position, "expected a valid identifier")
      elsif !context.nameFree? callTemplateFirst
        raise Err.msgAt(callTemplateFirst.position, "#{callTemplateFirst.name} already in scope")
      else
        callarguments : Array(LRef) = callTemplate.arguments.map do |arg|
          if !(arg.is_a? LRef)
            raise Err.msgAt(arg.position, "defun function call template expects only valid argument names")
          end
          arg
        end
        context.setFunction(callTemplateFirst, callarguments, body)
      end
      return NilValue.new
    when "lambda"
      if arguments.size < 2
        raise Err.msgAt(first.position, "'lambda' expects at least two arguments")
      elsif arguments[0].is_a? LNil
        lambdaCallTemplateArguments  = [] of LData
      elsif arguments[0].is_a? LExpression
        lambdaCallTemplate = arguments[0].as LExpression
        lambdaCallTemplateArguments  = [lambdaCallTemplate.first] + lambdaCallTemplate.arguments
      else
        raise Err.msgAt(first.position, "'lambda' expects an expression as first argument")
      end
      body = arguments[1..]

      lambdaCallArguments : Array(LRef) = lambdaCallTemplateArguments.map do |arg|
        if !(arg.is_a? LRef)
          raise Err.msgAt(arg.position, "'lambda' function call template expects only valid argument names")
        end
        arg
      end
      return FunctionObject.new(LRef.new("lambda", first.position), lambdaCallArguments, body, context)
    when "def"
      if arguments.size < 2 || arguments.size > 2
        raise Err.msgAt(first.position, "def expects exactly two arguments")
      elsif !arguments[0].is_a? LRef
        raise Err.msgAt(first.position, "def expects a identifier as first argument")
      else
        ref = arguments[0].as(LRef)
        if !context.nameFree? ref
          raise Err.msgAt(ref.position, "'#{ref.name}' already defined")
        end
        context.setConstant(ref, evaluate(arguments[1], context))
        return NilValue.new
      end
    when "set"
      if arguments.size < 2 || arguments.size > 2
        raise Err.msgAt(first.position, "set expects exactly two arguments")
      elsif !arguments[0].is_a? LRef
        raise Err.msgAt(first.position, "set expects a identifier as first argument")
      else
        ref = arguments[0].as(LRef)
        if !context.hasVariable ref
          raise Err.msgAt(ref.position, "variable #{ref.name} not defined")
        end
        context.setVariable(ref, evaluate(arguments[1], context))
        return NilValue.new
      end
    when "let"
      if arguments.size != 2
        raise Err.msgAt(first.position, "'let' expects exactly two arguments")
      elsif !arguments[0].is_a? LRef
        raise Err.msgAt(first.position, "'let' expects a identifier as first argument")
      else
        ref = arguments[0].as(LRef)
        if !context.nameFree? ref
          raise Err.msgAt(ref.position, "'#{ref.name}' already defined")
        end
        context.setNewVariable(ref, evaluate(arguments[1], context))
        return NilValue.new
      end
    when "table"
      data = Hash(TableKeyType, RuntimeValue).new
      arguments.each do |arg|
        if !arg.is_a? LExpression
          raise Err.msgAt(arg.position, "'table' expects key-value pairs as arguments")
        end
        fst = arg.first
        if !fst.is_a? NumberValue && !fst.is_a? StringValue && !fst.is_a? SymbolValue
          raise Err.msgAt(fst.position, "'table' keys can only be number, string and symbol")
        elsif fst.arguments.size != 1
          raise Err.msgAt(fst.position, "'table' expects key-value pairs as arguments")
        end
        data[fst] = arg.arguments[0]
      end
      return TableObject.new data
    when "if"
      if arguments.size != 3
        raise Err.msgAt(first.position, "'if' expects exactly three arguments")
      end
      cond = evaluate(arguments[0], context)
      trueVal = arguments[1]
      falseVal = arguments[2]
      if cond.is_a? SymbolValue
        if cond.name == TRUE
        return evaluate(trueVal, context)
        elsif cond.name == FALSE
          return evaluate(falseVal, context)
        else
          raise Err.msgAt(arguments[0].position, "'if' expects '#t or '#f as first argument value")
        end
      else
        raise Err.msgAt(arguments[0].position, "'if' expects '#t or '#f as first argument value")
      end

    else
      return evaluateNonKeywordExpression(first, arguments, context)
    end
  end

  def evaluateNonKeywordExpression(first : LRef, arguments : Array(LData), context : EvaluationContext) : RuntimeValue
    if BuildIn::INSTANCE.hasFunction first
      return FunctionEvaluator.evaluateReferencedFunction(first.position, first, evaluateList(arguments, context), context)
    else
      return context.evaluateFunction(first, evaluateList(arguments, context))
    end
  end
end
