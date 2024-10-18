require "../function_evaluator.cr"
require "../../error_utils.cr"

module ListBuildin
  extend self

  def evaluateTail(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise Err.msgAt(position, "'tail' expects one argument")
    end
    fst = arguments[0]
    if !fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'tail' expects a list as first argument", fst)
    elsif fst.elems.size <= 1
      return ListObject.new ([] of RuntimeValue)
    else
      return ListObject.new fst.elems[1..]
    end
  end

  def evaluateHead(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise Err.msgAt(position, "'head' expects one argument")
    end
    fst = arguments[0]
    if !fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'head' expects a list as first argument", fst)
    elsif fst.elems.size == 0
      raise Err.msgAt(position, "'head' expects a non-empty list as first argument")
    else
      return ListObject.new [fst.elems[0]]
    end
  end

  def evaluateGet(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'get' expects two argument")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'get' expects a list as first argument", fst)
    elsif snd.is_a? NumberValue
      sndVal : Int64 | Int32 | Float64 | Float32 = snd.value
      if sndVal.integer?
        if fst.elems.size <= sndVal
          raise Err.msgAt(position, "'get' index out of bounds: element #{sndVal} but length #{fst.elems.size}")
        end
        return fst.elems[sndVal.as Int]
      else
        raise Err.unexpectedValue(position, "'get' expects an integer as second argument", snd)
      end
    else
      raise Err.unexpectedValue(position, "'get' expects integer as second argument", snd)
    end
  end

  def evaluateConcat(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'concat' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'concat' expects a list as first argument", fst)
    end
    if !snd.is_a? ListObject
      raise Err.unexpectedValue(position, "'concat' expects a list as second argument", snd)
    end

    return ListObject.new (fst.elems + snd.elems)
  end

  def evaluateMap(position : Position, arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'map' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? FunctionObject
      raise Err.unexpectedValue(position, "'map' expects a function as first argument", fst)
    end
    if !snd.is_a? ListObject
      raise Err.unexpectedValue(position, "'map' expects a list as second argument", snd)
    end

    results = [] of RuntimeValue
    snd.elems.each do |elem|
      results << FunctionEvaluator.evaluateFunction(position, fst, [elem])
    end
    return ListObject.new results
  end

  def evaluateFilter(position : Position, arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'filter' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? FunctionObject
      raise Err.unexpectedValue(position, "'filter' expects a function as first argument", fst)
    end
    if !snd.is_a? ListObject
      raise Err.unexpectedValue(position, "'filter' expects a list as second argument", snd)
    end

    results = [] of RuntimeValue
    snd.elems.each do |elem|
      predicateResult = FunctionEvaluator.evaluateFunction(position, fst, [elem])
      if !predicateResult.is_a? SymbolValue
        raise Err.unexpectedValue(
          position,
          "'filter' expects a predicate function. '#{fst.name}' didn't return a booleanish symbol",
          predicateResult
        )
      elsif predicateResult.name == TRUE
        results << elem
      elsif predicateResult.name == FALSE
        next
      else
        raise Err.unexpectedValue(
          position,
          "'filter' expects a predicate function. '#{fst.name}' didn't return a booleanish symbol",
          predicateResult
        )
      end
    end
    return ListObject.new results
  end

  def evaluateLength(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise Err.msgAt(position, "'length' expects one arguments")
    end
    fst = arguments[0]
    if !fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'length' expects a list argument", fst)
    end
    return NumberValue.new fst.elems.size
  end

  def evaluateContains(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'contains?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'contains?' expects a list as fist argument", fst)
    end
    fst.elems.each do |elem|
      if elem == snd
        return SymbolValue.trueValue
      end
    end
    return SymbolValue.falseValue
  end

  def evaluateSublist(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2 || arguments.size > 3
      raise Err.msgAt(position, "'sublist' expects two or three arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]?
    unless fst.is_a? ListObject
      raise Err.unexpectedValue(position, "'sublist' expects a list as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'sublist' expects a integer as second argument", snd)
    end
    unless (trd == nil || trd.is_a? NumberValue)
      raise Err.unexpectedValue(position, "'sublist' expects nil or an integer as third argument", trd)
    end

    sndValPre = snd.value
    if sndValPre.integer?
      sndVal : Int64 = sndValPre.as Int64
      if trd.nil?
        return ListObject.new fst.elems[sndVal..]
      end
      if trd.is_a? NumberValue
        trdValPre = trd.value
        if trdValPre.integer?
          trdVal = trdValPre.as Int64
          return ListObject.new fst.elems[sndVal..trdVal]
        else
          raise Err.unexpectedValue(position, "'sublist' expects an integer or nil as third argument", trd)
        end
      else
        raise Err.unexpectedValue(position, "'sublist' expects an integer or nil as third argument", trd)
      end
    else
      raise Err.unexpectedValue(position, "'sublist' expects an integer as second argument", snd)
    end
  end
end
