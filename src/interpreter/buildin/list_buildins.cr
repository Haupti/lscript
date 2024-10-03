require "../function_evaluator.cr"

module ListBuildin
  extend self

  def evaluateTail(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise "'tail' expects one argument"
    end
    fst = arguments[0]
    if !fst.is_a? ListObject
      raise "'tail' expects a list as first argument"
    elsif fst.elems.size <= 1
      return ListObject.new ([] of RuntimeValue)
    else
      return ListObject.new fst.elems[1..]
    end
  end

  def evaluateHead(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise "'head' expects one argument"
    end
    fst = arguments[0]
    if !fst.is_a? ListObject
      raise "'head' expects a list as first argument"
    elsif fst.elems.size == 0
      raise "'head' expects a non-empty list as first argument"
    else
      return ListObject.new [fst.elems[0]]
    end
  end

  def evaluateGet(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'get' expects two argument"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? ListObject
      raise "'get' expects a list as first argument"
    elsif snd.is_a? NumberValue
      sndVal : Int64 | Int32 | Float64 | Float32 = snd.value
      if sndVal.integer?
        if fst.elems.size <= sndVal
          raise "'get' index out of bounds: element #{sndVal} but length #{fst.elems.size}"
        end
        return fst.elems[sndVal.as Int]
      else
        raise "'get' expects an integer as second argument"
      end
    else
      raise "'get' expects integer as second argument"
    end
  end

  def evaluateConcat(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'concat' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? ListObject
      raise "'concat' expects a list as first argument"
    end
    if !snd.is_a? ListObject
      raise "'concat' expects a list as second argument"
    end

    return ListObject.new (fst.elems + snd.elems)
  end

  def evaluateMap(arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
    if arguments.size != 2
      raise "'map' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? FunctionObject
      raise "'map' expects a function as first argument"
    end
    if !snd.is_a? ListObject
      raise "'map' expects a list as second argument"
    end

    results = [] of RuntimeValue
    snd.elems.each do |elem|
      results << FunctionEvaluator.evaluateFunction(fst, [elem])
    end
    return ListObject.new results
  end

  def evaluateFilter(arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
    if arguments.size != 2
      raise "'filter' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? FunctionObject
      raise "'filter' expects a function as first argument"
    end
    if !snd.is_a? ListObject
      raise "'filter' expects a list as second argument"
    end

    results = [] of RuntimeValue
    snd.elems.each do |elem|
      predicateResult = FunctionEvaluator.evaluateFunction(fst, [elem])
      if !predicateResult.is_a? SymbolValue
        raise "'filter' expects a predicate function. '#{fst.name}' didn't return a booleanish symbol"
      elsif predicateResult.name == TRUE
        results << elem
      elsif predicateResult.name == FALSE
        next
      else
        raise "'filter' expects a predicate function. '#{fst.name}' didn't return a booleanish symbol"
      end
    end
    return ListObject.new results
  end

  def evaluateLength(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise "'length' expects one arguments"
    end
    fst = arguments[0]
    if !fst.is_a? ListObject
      raise "'length' expects a list argument"
    end
    return NumberValue.new fst.elems.size
  end

  def evaluateContains(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise "'contains?' expects two arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? ListObject
      raise "'contains?' expects a list as fist argument"
    end
    fst.elems.each do |elem|
      if elem == snd
        return SymbolValue.trueValue
      end
    end
    return SymbolValue.falseValue
  end

  def evaluateSublist(arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2 || arguments.size > 3
      raise "'sublist' expects two or three arguments"
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]?
    unless fst.is_a? ListObject
      raise "'sublist' expects a list as first argument"
    end
    unless snd.is_a? NumberValue
      raise "'sublist' expects a integer as second argument"
    end
    unless (trd == nil || trd.is_a? NumberValue)
      raise "'sublist' expects nil or an integer as third argument"
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
          raise "'sublist' expects an integer or nil as third argument"
        end
      else
        raise "'sublist' expects an integer or nil as third argument"
      end
    else
      raise "'sublist' expects an integer as second argument"
    end
  end
end
