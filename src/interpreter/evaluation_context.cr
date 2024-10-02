require "./runtime_object_types.cr"
require "./function_evaluator.cr"

class EvaluationContext
  @constants : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new
  @functions : Hash(String, FunctionDefinition) = Hash(String, FunctionDefinition).new
  @variables : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new


  def hasFunction(ref : LRef | DefunRef) : Bool
    return @functions[ref.name]? != nil
  end

  def setFunction(ref : LRef, arguments : Array(LRef), body : Array(LData))
    #
    # on captured scope:
    # self is passed in to the function.
    # this is because the scope its defined in is
    # the scope it encloses when passed somewhere else.
    #
    @functions[ref.name] = FunctionDefinition.new(ref, arguments, body, self)
  end

  def evaluateFunction(ref : LRef | DefunRef, arguments : Array(RuntimeValue)) : RuntimeValue
    if @functions[ref.name]? != nil
      return FunctionEvaluator.evaluateFunction(@functions[ref.name], arguments)
    elsif BuildIn::INSTANCE.hasFunction(ref)
      return BuildIn::INSTANCE.evaluateFunction(ref, arguments, self)
    else
      raise "'#{ref.name}' not in scope"
    end
  end

  def hasVariable(ref : LRef) : Bool
    return @variables[ref.name]? != nil
  end

  def getVariableValue(ref : LRef) : RuntimeValue
    val = @variables[ref.name]?
    if val.nil?
      raise "#{ref.name} not in scope"
    else
      return val
    end
  end

  def setVariable(ref : LRef, value : RuntimeValue)
    @variables[ref.name] = value
  end

  def hasConstant(ref : LRef) : Bool
    return @constants[ref.name]? != nil
  end

  def getConstantValue(ref : LRef) : RuntimeValue
    val = @constants[ref.name]?
    if val.nil?
      raise "#{ref.name} not in scope"
    else
      return val
    end
  end

  def setConstant(ref : LRef, value : RuntimeValue)
    @constants[ref.name] = value
  end
end

class FunctionScope < EvaluationContext
  @arguments : Hash(String, RuntimeValue)
  @parent : EvaluationContext

  def initialize(@arguments : Hash(String, RuntimeValue), @parent : EvaluationContext)
  end

  def hasFunction(ref : LRef) : Bool
    return @functions[ref.name]? != nil || @parent.hasFunction(ref)
  end

  def setFunction(ref : LRef, arguments : Array(LRef), body : Array(LData))
    @functions[ref.name] = FunctionDefinition.new(ref, arguments, body, self)
  end

  def evaluateFunction(ref : LRef, arguments : Array(RuntimeValue)) : RuntimeValue
    if @functions[ref.name]? != nil
      return FunctionEvaluator.evaluateFunction(@functions[ref.name], arguments)
    elsif @parent.hasFunction(ref)
      puts "function parent used (eval fn)"
      return @parent.evaluateFunction(ref, arguments)
    elsif BuildIn::INSTANCE.hasFunction(ref)
      return BuildIn::INSTANCE.evaluateFunction(ref, arguments, self)
    else
      raise "'#{ref.name}' not in scope"
    end
  end

  def hasVariable(ref : LRef) : Bool
    return @variables[ref.name]? != nil || @parent.hasVariable(ref)
  end

  def getVariableValue(ref : LRef) : RuntimeValue
    val = @variables[ref.name]?
    if val.nil?
      puts "function parent used (get var)"
      return @parent.getVariableValue(ref)
    else
      return val
    end
  end

  def setVariable(ref : LRef, value : RuntimeValue)
    @variables[ref.name] = value
  end

  def hasArgument(ref : LRef) : Bool
    return @arguments[ref.name]? != nil
  end

  def getArgumentValue(ref : LRef) : RuntimeValue
    val = @arguments[ref.name]?
    if val.nil?
      raise "#{ref.name} not an function argument"
    else
      return val
    end
  end

  def hasConstant(ref : LRef) : Bool
    return @constants[ref.name]? != nil || hasArgument(ref) || @parent.hasConstant(ref)
  end

  def getConstantValue(ref : LRef) : RuntimeValue
    if !@constants[ref.name]?.nil?
      val = @constants[ref.name]?
      if val.nil?
        raise "#{ref.name} not in scope"
      end
      return val
    elsif hasArgument(ref)
      return getArgumentValue(ref)
    elsif @parent.hasConstant(ref)
      puts "function parent used (get const)"
      return @parent.getConstantValue(ref)
    else
      raise "#{ref.name} not in scope"
    end
  end

  def setConstant(ref : LRef, value : RuntimeValue)
    @constants[ref.name] = value
  end
end
