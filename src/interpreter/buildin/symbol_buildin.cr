module SymbolBuildin
  extend self

  def evaluateAnd(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise "'and' expects at least two arguments"
    end
    result = arguments.all? do |arg|
      if arg.is_a? SymbolValue && arg.name == TRUE
        true
      elsif arg.is_a? SymbolValue && arg.name == FALSE
        false
      else
        raise "'and' expects either the symbol #{TRUE} or #{FALSE}"
      end
    end
    if result
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
    end
  end

  def evaluateOr(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise "'or' expects at least two arguments"
    end
    result = arguments.any? do |arg|
      if arg.is_a? SymbolValue && arg.name == TRUE
        true
      elsif arg.is_a? SymbolValue && arg.name == FALSE
        false
      else
        raise "'or' expects either the symbol #{TRUE} or #{FALSE}"
      end
    end
    if result
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
    end
  end

  def evaluateNot(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise "'not' expects one arguments"
    end
    arg = arguments[0]
    if arg.is_a? SymbolValue && arg.name == TRUE
      return SymbolValue.falseValue
    elsif arg.is_a? SymbolValue && arg.name == FALSE
      return SymbolValue.trueValue
    else
      raise "'or' expects either the symbol #{TRUE} or #{FALSE}"
    end

  end
end
