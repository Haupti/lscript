require "../error_utils.cr"
require "./runtime_object_types.cr"
require "./function_evaluator.cr"

class EvaluationContext
  @constants : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new
  @variables : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new

  def nameFree?(ref : LRef) : Bool
    fn = @constants[ref.name]?
    if fn.nil?
      fn = @variables[ref.name]?
    end

    return fn.nil? && !BuildIn::INSTANCE.hasFunction(ref)
  end

  def setFunction(ref : LRef, arguments : Array(LRef), body : Array(LData))
    #
    # on captured scope:
    # self is passed in to the function.
    # this is because the scope its defined in is
    # the scope it encloses when passed somewhere else.
    #
    @constants[ref.name] = FunctionObject.new(ref, arguments, body, self)
  end

  def evaluateFunction(ref : LRef, arguments : Array(RuntimeValue)) : RuntimeValue
    fn = @constants[ref.name]?
    if fn.nil?
      fn = @variables[ref.name]?
    end

    if !fn.nil? && fn.is_a? FunctionObject
      return FunctionEvaluator.evaluateFunction(ref.position, fn, arguments)
    elsif !fn.nil? && fn.is_a? TableObject
      return FunctionEvaluator.evaluateTableFunction(ref.position, fn, arguments)
    else
      return FunctionEvaluator.evaluateReferencedFunction(ref.position, ref, arguments, self)
    end
  end

  def getFunction(ref : LRef) : RuntimeValue
    fn = @constants[ref.name]?
    if fn.nil?
      fn = @variables[ref.name]?
    end

    unless fn.nil?
      return fn
    else
      if BuildIn::INSTANCE.hasFunction(ref)
        return BuildinFunctionRef.new ref.name
      else
        raise Err.msgAt(ref.position, "#'{ref.name}' not in scope")
      end
    end
  end

  def hasVariable(ref : LRef) : Bool
    return @variables[ref.name]? != nil
  end

  def getVariableValue(ref : LRef) : RuntimeValue
    val = @variables[ref.name]?
    if val.nil?
      raise Err.msgAt(ref.position, "#{ref.name} not in scope")
    else
      return val
    end
  end

  def setVariable(ref : LRef, value : RuntimeValue)
    if @variables[ref.name]? != nil
      @variables[ref.name] = value
    else
      raise Err.msgAt(ref.position, "'#{ref.name}' not in scope")
    end
  end

  def setNewVariable(ref : LRef, value : RuntimeValue)
    if @variables[ref.name]? != nil
      raise Err.msgAt(ref.position, "'#{ref.name}' already defined")
    else
      @variables[ref.name] = value
    end
  end

  def hasConstant(ref : LRef) : Bool
    return @constants[ref.name]? != nil
  end

  def getConstantValue(ref : LRef) : RuntimeValue
    val = @constants[ref.name]?
    if val.nil?
      raise Err.msgAt(ref.position, "#{ref.name} not in scope")
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

  def nameFree?(ref : LRef) : Bool
    fn = @constants[ref.name]?
    if fn.nil?
      fn = @variables[ref.name]?
    end

    return fn.nil? && @parent.nameFree?(ref)
  end

  def setFunction(ref : LRef, arguments : Array(LRef), body : Array(LData))
    @constants[ref.name] = FunctionObject.new(ref, arguments, body, self)
  end

  def evaluateFunction(ref : LRef, arguments : Array(RuntimeValue)) : RuntimeValue
    fn = @constants[ref.name]?
    if fn.nil?
      fn = @variables[ref.name]?
    end
    if fn.nil?
      fn = @arguments[ref.name]?
    end

    if !fn.nil? && fn.is_a? FunctionObject
      return FunctionEvaluator.evaluateFunction(ref.position, fn, arguments)
    elsif !fn.nil? && fn.is_a? TableObject
      return FunctionEvaluator.evaluateTableFunction(ref.position, fn, arguments)
    else
      return @parent.evaluateFunction(ref, arguments)
    end
  end

  def hasVariable(ref : LRef) : Bool
    return @variables[ref.name]? != nil || @parent.hasVariable(ref)
  end

  def getVariableValue(ref : LRef) : RuntimeValue
    val = @variables[ref.name]?
    if val.nil?
      return @parent.getVariableValue(ref)
    else
      return val
    end
  end

  def setVariable(ref : LRef, value : RuntimeValue)
    if @variables[ref.name]? != nil
      @variables[ref.name] = value
    else
     @parent.setVariable(ref, value)
    end
  end

  def setNewVariable(ref : LRef, value : RuntimeValue)
    if @variables[ref.name]? != nil
      raise Err.msgAt(ref.position, "'#{ref.name}' already defined")
    else
      @variables[ref.name] = value
    end
  end

  def hasArgument(ref : LRef) : Bool
    return @arguments[ref.name]? != nil
  end

  def getArgumentValue(ref : LRef) : RuntimeValue
    val = @arguments[ref.name]?
    if val.nil?
      raise Err.msgAt(ref.position, "#{ref.name} not an function argument")
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
        raise Err.msgAt(ref.position, "#{ref.name} not in scope")
      end
      return val
    elsif hasArgument(ref)
      return getArgumentValue(ref)
    elsif @parent.hasConstant(ref)
      puts "function parent used (get const)"
      return @parent.getConstantValue(ref)
    else
      raise Err.msgAt(ref.position, "#{ref.name} not in scope")
    end
  end

  def setConstant(ref : LRef, value : RuntimeValue)
    @constants[ref.name] = value
  end
end
