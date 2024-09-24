require "../parser/expression.cr"
require "./buildin.cr"

class EvaluationContext
  @constants : Hash(String, LValue | LRef) = Hash(String, LValue | LRef).new
  @functions : Hash(String, LRef) = Hash(String, LRef).new
  @variables : Hash(String, LValue | LRef) = Hash(String, LValue | LRef).new


  def hasFunction(ref : LRef) : Bool
    return @functions[ref.name]? != nil
  end

  def evaluateFunction(ref : LRef, arguments : Array(LValue)) : LValue
    raise "TODO" # TODO
  end

  def hasVariable(ref : LRef) : Bool
    return @variables[ref.name]? != nil
  end

  def getVariableValue(ref : LRef) : LValue | LRef
    val = @variables[ref.name]?
    if val.nil?
      raise "#{ref.name} not in scope"
    else
      return val
    end
  end

  def setVariable(ref : LRef, value : LValue | LRef)
    @variables[ref.name] = value
  end

  def hasConstant(ref : LRef) : Bool
    return @constants[ref.name]? != nil
  end

  def getConstantValue(ref : LRef) : LValue | LRef
    val = @constants[ref.name]?
    if val.nil?
      raise "#{ref.name} not in scope"
    else
      return val
    end
  end

  def setConstant(ref : LRef, value : LValue | LRef)
    @constants[ref.name] = value
  end
end


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
      raise "TODO" # TODO
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
