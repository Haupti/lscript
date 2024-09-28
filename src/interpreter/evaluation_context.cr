require "./runtime_object_types.cr"

class EvaluationContext
  @constants : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new
  @functions : Hash(String, FunctionDefinition) = Hash(String, FunctionDefinition).new
  @variables : Hash(String, RuntimeValue) = Hash(String, RuntimeValue).new


  def hasFunction(ref : LRef) : Bool
    return @functions[ref.name]? != nil
  end

  def setFunction(ref : LRef, arguments : Array(LRef), body : Array(LData))
    @functions[ref.name] = FunctionDefinition.new(ref, arguments, body)
  end

  def evaluateFunction(ref : LRef, arguments : Array(RuntimeValue)) : LValue
    raise "TODO" # TODO
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
