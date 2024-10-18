require "../../error_utils.cr"

module NumberBuildin
  extend self

  def evaluateLT(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'lt?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    unless fst.is_a? NumberValue
      raise Err.unexpectedValue(position, "'lt?' expects a number as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'lt?' expects a number as second argument", snd)
    end
    if fst.value < snd.value
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
    end
  end

  def evaluateLTE(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'lte?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    unless fst.is_a? NumberValue
      raise Err.unexpectedValue(position, "'lte?' expects a number as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'lte?' expects a number as second argument", snd)
    end
    if fst.value <= snd.value
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
    end
  end

  def evaluateGTE(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'gte?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    unless fst.is_a? NumberValue
      raise Err.unexpectedValue(position, "'gte?' expects a number as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'gte?' expects a number as second argument", snd)
    end
    if fst.value >= snd.value
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
    end
  end

  def evaluateGT(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'gt?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    unless fst.is_a? NumberValue
      raise Err.unexpectedValue(position, "'gt?' expects a number as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'gt?' expects a number as second argument", snd)
    end
    if fst.value > snd.value
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
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
        raise Err.unexpectedValue(position, "'+' expects number arguments", arg)
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
        raise Err.unexpectedValue(position, "'*' expects number arguments", arg)
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
    unless fst.is_a? NumberValue
      raise Err.unexpectedValue(position, "'/' expects a number as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'/' expects a number as second argument", snd)
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
      raise Err.unexpectedValue(position, "'-' expects number arguments", initial)
    end
    result = initial.value
    arguments[1..].each do |arg|
      if arg.is_a? NumberValue
        result -= arg.value
      else
        raise Err.unexpectedValue(position, "'-' expects number arguments", arg)
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
    unless fst.is_a? NumberValue && fst.value.integer?
      raise Err.unexpectedValue(position, "'mod' expects a integer as first argument", fst)
    end
    unless snd.is_a? NumberValue && snd.value.integer?
      raise Err.unexpectedValue(position, "'mod' expects a integer as second argument", snd)
    end
    fstVal = fst.value
    sndVal = snd.value
    if fstVal.integer?
      if sndVal.integer?
        return NumberValue.new (fstVal % sndVal.as Int)
      else
        raise Err.unexpectedValue(position, "'mod' expects a integer as second argument", snd)
      end
    else
      raise Err.unexpectedValue(position, "'mod' expects a integer as first argument", fst)
    end
  end
end
