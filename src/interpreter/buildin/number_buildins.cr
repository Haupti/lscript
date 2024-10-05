module NumberBuildin
  extend self

  def evaluateLT(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'lt?' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if fst.is_a? NumberValue && snd.is_a? NumberValue
      if fst.value < snd.value
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    else
      raise "'lt?' expects two number arguments"
    end
  end

  def evaluateLTE(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'lte?' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if fst.is_a? NumberValue && snd.is_a? NumberValue
      if fst.value <= snd.value
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    else
      raise "'lte?' expects two number arguments"
    end
  end

  def evaluateGTE(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'gte?' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if fst.is_a? NumberValue && snd.is_a? NumberValue
      if fst.value >= snd.value
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    else
      raise "'gte?' expects two number arguments"
    end
  end

  def evaluateGT(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'gt?' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if fst.is_a? NumberValue && snd.is_a? NumberValue
      if fst.value > snd.value
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    else
      raise "'gt?' expects two number arguments"
    end
  end

  def evaluateAdd(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise "'+' expects at least two arguments"
    end
    result = 0
    arguments.each do |arg|
      if arg.is_a? NumberValue
        result += arg.value
      else
        raise "'+' expects number arguments but got #{typeName(arg)}"
      end
    end
    return NumberValue.new result
  end

  def evaluateMultiply(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise "'*' expects at least two arguments"
    end
    result = 0
    fst = arguments[0]
    if fst.is_a? NumberValue
      result = fst.value
    end
    arguments[1..].each do |arg|
      if arg.is_a? NumberValue
        result += arg.value
      else
        raise "'*' expects number arguments but got #{arg}"
      end
    end
    return NumberValue.new result
  end

  def evaluateDivide(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'/' expects exaclty two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !(fst.is_a? NumberValue && snd.is_a? NumberValue)
      raise "'/' expects two integer arguments but got '#{fst}' and '#{snd}'"
    end
    fstVal = fst.value
    sndVal = snd.value
    return NumberValue.new (fstVal / sndVal)
  end

  def evaluateMinus(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise "'-' expects at least two arguments"
    end
    initial = arguments[0]
    if !(initial.is_a? NumberValue)
      raise "'-' expects number arguments but got #{typeName(initial)}"
    end
    result = initial.value
    arguments[1..].each do |arg|
      if arg.is_a? NumberValue
        result -= arg.value
      else
        raise "'-' expects number arguments but got #{typeName(arg)}"
      end
    end
    return NumberValue.new result
  end

  def evaluateModulo(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'mod' expects exactly two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !(fst.is_a? NumberValue  && snd.is_a? NumberValue && snd.value.integer?)
      raise "'mod' expects two integer arguments but got #{typeName(fst)} and #{typeName(snd)}"
    end
    fstVal = fst.value
    sndVal = snd.value
    if fstVal.integer?
      if sndVal.integer?
        return NumberValue.new (fstVal % sndVal.as Int)
      else
        raise "'mod' expects two integer arguments but got '#{fst.value}' and '#{snd.value}'"
      end
    else
      raise "'mod' expects two integer arguments but got '#{fst.value}' and '#{snd.value}'"
    end
  end
end
