require "../parser/expression.cr"
require "./buildin/buildin.cr"
require "./evaluation_context.cr"
require "./runtime_object_types.cr"

module Interpreter
  extend self

  def run(code : Array(LData)) : RuntimeValue

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
        raise "unexpected no case matched while top level evaluation #{datum}"
      end
    end
    return result

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
      else
        raise "#{datum.name} not in scope"
      end
    when LSymbol
      return SymbolValue.new datum.name
    when LList
      return ListObject.new evaluateList(datum.elems, context)
    when LExpression
      return evaluateExpression(datum, context)
    else
      raise "unexpected data, cannot evaluate: #{datum}"
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
          raise "unexpected no case matched while evaluating list (#{datum})"
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
        raise "unexpected no case matched while evaluating a list (#{datum})"
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
        return FunctionEvaluator.evaluateFunction(firstResult, evaluateList(expr.arguments, context))
      elsif firstResult.is_a? BuildinFunctionRef
        return FunctionEvaluator.evaluateReferencedFunction(firstResult, evaluateList(expr.arguments, context), context)
      else
        raise "expected a function name but got '#{rtvToStr(firstResult)}'"
      end
    else
      raise "BUG: should not happen"
    end
  end

  def evaluateDirectExpression(first : LRef, arguments : Array(LData), context : EvaluationContext) : RuntimeValue
    refName = first.name
    case refName
    when "defun"
      if arguments.size < 2
        raise "defun expects at least two arguments"
      elsif !arguments[0].is_a? LExpression
        raise "defun expects an expression as first argument"
      end
      callTemplate = arguments[0].as LExpression
      body = arguments[1..]
      callTemplateFirst = callTemplate.first
      if !callTemplateFirst.is_a? LRef
        raise "expected a valid identifier"
      elsif !context.nameFree? callTemplateFirst
        raise "#{callTemplateFirst.name} already in scope"
      else
        callarguments : Array(LRef) = callTemplate.arguments.map do |arg|
          if !(arg.is_a? LRef)
            raise "defun function call template expects only valid argument names"
          end
          arg
        end
        context.setFunction(callTemplateFirst, callarguments, body)
      end
      return NilValue.new
    when "lambda"
      if arguments.size < 2
        raise "'lambda' expects at least two arguments"
      elsif arguments[0].is_a? LNil
        lambdaCallTemplateArguments  = [] of LData
      elsif arguments[0].is_a? LExpression
        lambdaCallTemplate = arguments[0].as LExpression
        lambdaCallTemplateArguments  = [lambdaCallTemplate.first] + lambdaCallTemplate.arguments
      else
        raise "'lambda' expects an expression as first argument"
      end
      body = arguments[1..]

      lambdaCallArguments : Array(LRef) = lambdaCallTemplateArguments.map do |arg|
        if !(arg.is_a? LRef)
          raise "'lambda' function call template expects only valid argument names"
        end
        arg
      end
      return FunctionObject.new(LRef.new("lambda"), lambdaCallArguments, body, context)
    when "def"
      if arguments.size < 2 || arguments.size > 2
        raise "def expects exactly two arguments"
      elsif !arguments[0].is_a? LRef
        raise "def expects a identifier as first argument"
      else
        ref = arguments[0].as(LRef)
        if !context.nameFree? ref
          raise "'#{ref.name}' already defined"
        end
        context.setConstant(ref, evaluate(arguments[1], context))
        return NilValue.new
      end
    when "set"
      if arguments.size < 2 || arguments.size > 2
        raise "set expects exactly two arguments"
      elsif !arguments[0].is_a? LRef
        raise "set expects a identifier as first argument"
      else
        ref = arguments[0].as(LRef)
        if !context.hasVariable ref
          raise "variable #{ref.name} not defined"
        end
        context.setVariable(ref, evaluate(arguments[1], context))
        return NilValue.new
      end
    when "let"
      if arguments.size != 2
        raise "'let' expects exactly two arguments"
      elsif !arguments[0].is_a? LRef
        raise "'let' expects a identifier as first argument"
      else
        ref = arguments[0].as(LRef)
        if !context.nameFree? ref
          raise "'#{ref.name}' already defined"
        end
        context.setNewVariable(ref, evaluate(arguments[1], context))
        return NilValue.new
      end
    when "if"
      if arguments.size != 3
        raise "'if' expects exactly three arguments"
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
          raise "'if' expects '#t or '#f as first argument value"
        end
      else
          raise "'if' expects '#t or '#f as first argument value"
      end

    else
      return evaluateNonKeywordExpression(first, arguments, context)
    end
  end

  def evaluateNonKeywordExpression(first : LRef, arguments : Array(LData), context : EvaluationContext) : RuntimeValue
    if BuildIn::INSTANCE.hasFunction first
      return FunctionEvaluator.evaluateReferencedFunction(first, evaluateList(arguments, context), context)
    else
      return context.evaluateFunction(first, evaluateList(arguments, context))
    end
  end
end
