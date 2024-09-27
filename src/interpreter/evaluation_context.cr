record FunctionDefinition,
  name : LRef,
  arguments : Array(LRef),
  body : Array(LData)

class EvaluationContext
  @constants : Hash(String, LValue | LRef) = Hash(String, LValue | LRef).new
  @functions : Hash(String, FunctionDefinition) = Hash(String, FunctionDefinition).new
  @variables : Hash(String, LValue | LRef) = Hash(String, LValue | LRef).new


  def hasFunction(ref : LRef) : Bool
    return @functions[ref.name]? != nil
  end

  def setFunction(ref : LRef, arguments : Array(LRef), body : Array(LData))
    @functions[ref.name] = FunctionDefinition.new(ref, arguments, body)
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
