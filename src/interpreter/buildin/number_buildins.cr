require "../../error_utils.cr"

module NumberBuildin
  extend self

  def evaluateLT(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'lt?' expects two arguments")
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
      raise Err.msgAt(position, "'lt?' expects two number arguments")
    end
  end

  def evaluateLTE(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'lte?' expects two arguments")
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
      raise Err.msgAt(position, "'lte?' expects two number arguments")
    end
  end

  def evaluateGTE(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'gte?' expects two arguments")
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
      raise Err.msgAt(position, "'gte?' expects two number arguments")
    end
  end

  def evaluateGT(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'gt?' expects two arguments")
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
      raise Err.msgAt(position, "'gt?' expects two number arguments")
    end
  end

  def evaluateAdd(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise Err.msgAt(position, "'+' expects at least two arguments")
    end
    result = 0
    arguments.each do |arg|
      if arg.is_a? NumberValue
        result += arg.value
      else
        raise Err.msgAt(position, "'+' expects number arguments but got #{typeName(arg)}")
      end
    end
    return NumberValue.new result
  end

  def evaluateMultiply(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise Err.msgAt(position, "'*' expects at least two arguments")
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
        raise Err.msgAt(position, "'*' expects number arguments but got #{arg}")
      end
    end
    return NumberValue.new result
  end

  def evaluateDivide(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'/' expects exaclty two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !(fst.is_a? NumberValue && snd.is_a? NumberValue)
      raise Err.msgAt(position, "'/' expects two integer arguments but got '#{fst}' and '#{snd}'")
    end
    fstVal = fst.value
    sndVal = snd.value
    return NumberValue.new (fstVal / sndVal)
  end

  def evaluateMinus(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise Err.msgAt(position, "'-' expects at least two arguments")
    end
    initial = arguments[0]
    if !(initial.is_a? NumberValue)
      raise Err.msgAt(position, "'-' expects number arguments but got #{typeName(initial)}")
    end
    result = initial.value
    arguments[1..].each do |arg|
      if arg.is_a? NumberValue
        result -= arg.value
      else
        raise Err.msgAt(position, "'-' expects number arguments but got #{typeName(arg)}")
      end
    end
    return NumberValue.new result
  end

  def evaluateModulo(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'mod' expects exactly two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !(fst.is_a? NumberValue  && snd.is_a? NumberValue && snd.value.integer?)
      raise Err.msgAt(position, "'mod' expects two integer arguments but got #{typeName(fst)} and #{typeName(snd)}")
    end
    fstVal = fst.value
    sndVal = snd.value
    if fstVal.integer?
      if sndVal.integer?
        return NumberValue.new (fstVal % sndVal.as Int)
      else
        raise Err.msgAt(position, "'mod' expects two integer arguments but got '#{fst.value}' and '#{snd.value}'")
      end
    else
      raise Err.msgAt(position, "'mod' expects two integer arguments but got '#{fst.value}' and '#{snd.value}'")
    end
  end
end
