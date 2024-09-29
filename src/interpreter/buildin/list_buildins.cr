module ListBuildin
  extend self

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
