module StringBuildin
  extend self

  def evaluateStrConcat(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2
      raise "'str-concat' expects at least two arguments"
    end
    result = ""
    arguments.each do |arg|
      if arg.is_a? StringValue
        result += arg.value
      else
        raise Err.unexpectedValue(position, "'str-concat' expects string arguments", arg)
      end
    end
    return StringValue.new result
  end

  def evaluateSubstr(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size < 2 || arguments.size > 3
      raise Err.msgAt(position, "'substr' expects two or three arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]?
    unless fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'substr' expects a string as first argument", fst)
    end
    unless snd.is_a? NumberValue
      raise Err.unexpectedValue(position, "'substr' expects a integer as second argument", snd)
    end
    unless (trd == nil || trd.is_a? NumberValue)
      raise Err.unexpectedValue(position, "'substr' expects nil or an integer as third argument", trd)
    end

    sndValPre = snd.value
    if sndValPre.integer?
      sndVal : Int64 = sndValPre.as Int64
      if trd.nil?
        return StringValue.new fst.value[sndVal..]
      end
      if trd.is_a? NumberValue
        trdValPre = trd.value
        if trdValPre.integer?
          trdVal = trdValPre.as Int64
          return StringValue.new fst.value[sndVal..trdVal]
        else
          raise Err.unexpectedValue(position, "'substr' expects an integer or nil as third argument", trd)
        end
      else
        raise Err.unexpectedValue(position, "'substr' expects an integer or nil as third argument", trd)
      end
    else
      raise Err.unexpectedValue(position, "'substr' expects an integer as second argument", snd)
    end
  end

  def evaluateCharAt(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'char-at' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'char-at' expects a string as first argument", fst)
    elsif snd.is_a? NumberValue
      sndVal : Int64 | Int32 | Float64 | Float32 = snd.value
      if sndVal.integer?
        if fst.value.size <= sndVal
          raise Err.msgAt(position, "'char-at' index out of bounds: char-at #{sndVal} but length #{fst.value.size}")
        end
        return StringValue.new "#{fst.value[sndVal.as Int]}"
      else
        raise Err.unexpectedValue(position, "'chat-at' expects an integer as second argument", snd)
      end
    else
      raise Err.unexpectedValue(position, "'chat-at' expects integer as second argument", snd)
    end
  end

  def evaluateStrReplace(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 3
      raise Err.msgAt(position, "'str-replace' expects three arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]
    unless fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-replace' expects a string as first argmument", fst)
    end
    unless snd.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-replace' expects a string as second argmument", snd)
    end
    unless trd.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-replace' expects a string as third argmument", trd)
    end
    return StringValue.new fst.value.sub(snd.value, trd.value)
  end

  def evaluateStrReplaceAll(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 3
      raise Err.msgAt(position, "'str-replace-all' expects three arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]
    unless fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-replace-all' expects a string as first argmument", fst)
    end
    unless snd.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-replace-all' expects a string as second argmument", snd)
    end
    unless trd.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-replace-all' expects a string as third argmument", trd)
    end
    return StringValue.new fst.value.gsub(snd.value, trd.value)
  end

  def evaluateStrContains(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'str-contains?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    unless fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-contains?' expects a string as first argmument", fst)
    end
    unless snd.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-contains?' expects a string as second argmument", snd)
    end
    if fst.value.includes? snd.value
      return SymbolValue.trueValue
    else
      return SymbolValue.falseValue
    end
  end

  def evaluateStrLength(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'str-length' expects one argument")
    end
    fst = arguments[0]
    unless fst.is_a? StringValue
      raise Err.unexpectedValue(position, "'str-length' expects a string argmument", fst)
    else
      return NumberValue.new fst.value.size
    end
  end
end
