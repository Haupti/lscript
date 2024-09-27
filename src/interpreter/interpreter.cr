require "../parser/expression.cr"
require "./buildin.cr"
require "./evaluation_context.cr"

module Interpreter
  extend self

  def run(code : Array(LData))

    # Special makros that are required to make the programming language

    # defun  - defines a function : (defun (name [args]) ...body)
    # def    - defines a constant : (def name ...value)
    # let    - defines a variable : (let name ...value)
    # set    - mutates a variable : (set name ...value)
    # LATER import - takes a path relative to the current file and imports the module : (import "path" alias)
    # LATER module/struct access syntax

    context = EvaluationContext.new
    # top level code: only evaluate expressions
    code.each do |datum|
      case datum
      when LExpression
        evaluateExpression(datum, context)
      when LAtom
        next
      when LList
        next
      end

    end

  end

  def evaluate(datum : LData, context : EvaluationContext) : LValue | LRef
    case datum
    when LNumber
      return datum
    when LString
      return datum
    when LRef
      if context.hasConstant datum
        return context.getConstantValue datum
      elsif context.hasVariable datum
        return context.getVariableValue datum
      elsif context.hasFunction datum
        return datum
      else
        raise "#{datum.name} not in scope"
      end
    when LSymbol
      return datum
    when LList
      return evaluateList(datum.elems, context)
    when LExpression
      return evaluateExpression(datum, context)
    else
      raise "unexpected data, cannot evaluate: #{datum}"
    end
  end

  def evaluateList(datas : Array(LData), context : EvaluationContext) : Array(LValue)
    raise "TODO" # TODO
  end

  def evaluateExpression(expr : LExpression, context : EvaluationContext) : LValue
    refName = expr.first.name
    case refName
    when "defun"
      if expr.arguments.size < 2
        raise "defun expects at least two arguments"
      elsif !expr.arguments[0].is_a? LExpression
        raise "defun expects an expression as first argument"
      elsif (expr.arguments[0].as LExpression).arguments.size < 1
        raise "defun expects an expression as first argument with at least a valid function name"
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
      return LNil.new
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
        return LNil.new
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
        return LNil.new
      end
    when "let"
      if expr.arguments.size < 2 || expr.arguments.size > 2
        raise "let expects exactly two arguments"
      elsif !expr.arguments[0].is_a? LRef
        raise "let expects a identifier as first argument"
      else
        ref = expr.arguments[0].as(LRef)
        if context.hasVariable ref
          raise "variable #{ref.name} already defined"
        end
        context.setVariable(ref, evaluate(expr.arguments[1], context))
        return LNil.new
      end
    else
      if BuildIn.hasFunction expr.first
        BuildIn.evaluateFunction(expr.first, evaluateList(expr.arguments, context))
      elsif context.hasFunction expr.first
        context.evaluateFunction(expr.first, evaluateList(expr.arguments,context))
      else
        raise "not in scope #{expr.first.name}"
      end
    end
  end
end
