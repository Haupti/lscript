require "../parser/expression.cr"
require "./buildin/buildin.cr"
require "./evaluation_context.cr"
require "./runtime_object_types.cr"

module Interpreter
  extend self

  def run(code : Array(LData)) : RuntimeValue

    # Special makros that are required to make the programming language

    # defun  - defines a function : (defun (name [args]) ...body)
    # def    - defines a constant : (def name ...value)
    # let    - defines a variable : (let name ...value)
    # set    - mutates a variable : (set name ...value)
    # LATER import - takes a path relative to the current file and imports the module : (import "path" alias)
    # LATER module/struct access syntax

    context = EvaluationContext.new
    # top level code: only evaluate expressions
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
      elsif context.hasFunction datum
        return DefunRef.new datum.name
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
        elsif context.hasFunction datum
          DefunRef.new datum.name
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
    refName = expr.first.name
    case refName
    when "defun"
      if expr.arguments.size < 2
        raise "defun expects at least two arguments"
      elsif !expr.arguments[0].is_a? LExpression
        raise "defun expects an expression as first argument"
      end
      callTemplate = expr.arguments[0].as LExpression
      body = expr.arguments[1..]
      if context.hasFunction callTemplate.first
        raise "#{callTemplate.first.name} already in scope"
      else
        arguments : Array(LRef) = callTemplate.arguments.map do |arg|
          if !(arg.is_a? LRef)
            raise "defun function call template expects only valid argument names"
          end
          arg
        end
        context.setFunction(callTemplate.first, arguments, body)
      end
      return NilValue.new
    when "def"
      if expr.arguments.size < 2 || expr.arguments.size > 2
        raise "def expects exactly two arguments"
      elsif !expr.arguments[0].is_a? LRef
        raise "def expects a identifier as first argument"
      else
        ref = expr.arguments[0].as(LRef)
        if context.hasConstant ref
          raise "constant #{ref.name} already defined"
        end
        context.setConstant(ref, evaluate(expr.arguments[1], context))
        return NilValue.new
      end
    when "set"
      if expr.arguments.size < 2 || expr.arguments.size > 2
        raise "set expects exactly two arguments"
      elsif !expr.arguments[0].is_a? LRef
        raise "set expects a identifier as first argument"
      else
        ref = expr.arguments[0].as(LRef)
        if !context.hasVariable ref
          raise "variable #{ref.name} not defined"
        end
        context.setVariable(ref, evaluate(expr.arguments[1], context))
        return NilValue.new
      end
    when "let"
      if expr.arguments.size != 2
        raise "let expects exactly two arguments"
      elsif !expr.arguments[0].is_a? LRef
        raise "let expects a identifier as first argument"
      else
        ref = expr.arguments[0].as(LRef)
        if context.hasVariable ref
          raise "variable #{ref.name} already defined"
        end
        context.setVariable(ref, evaluate(expr.arguments[1], context))
        return NilValue.new
      end
    when "if"
      if expr.arguments.size != 3
        raise "'if' expects exactly three arguments"
      end
      cond = evaluate(expr.arguments[0], context)
      trueVal = expr.arguments[1]
      falseVal = expr.arguments[2]
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
      if BuildIn::INSTANCE.hasFunction expr.first
        return BuildIn::INSTANCE.evaluateFunction(expr.first, evaluateList(expr.arguments, context), context)
      elsif context.hasFunction expr.first
        return context.evaluateFunction(expr.first, evaluateList(expr.arguments,context))
      else
        raise "no function '#{expr.first.name}' in scope"
      end
    end
  end
end
