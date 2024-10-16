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
        raise Err.msgAt(position, "'str-concat' expects string arguments but got #{arg}")
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
      raise Err.msgAt(position, "'substr' expects a string as first argument")
    end
    unless snd.is_a? NumberValue
      raise Err.msgAt(position, "'substr' expects a integer as second argument")
    end
    unless (trd == nil || trd.is_a? NumberValue)
      raise Err.msgAt(position, "'substr' expects nil or an integer as third argument")
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
          raise Err.msgAt(position, "'substr' expects an integer or nil as third argument")
        end
      else
        raise Err.msgAt(position, "'substr' expects an integer or nil as third argument")
      end
    else
      raise Err.msgAt(position, "'substr' expects an integer as second argument")
    end
  end

  def evaluateCharAt(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'char-at' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    if !fst.is_a? StringValue
      raise Err.msgAt(position, "'char-at' expects a string as first argument")
    elsif snd.is_a? NumberValue
      sndVal : Int64 | Int32 | Float64 | Float32 = snd.value
      if sndVal.integer?
        if fst.value.size <= sndVal
          raise Err.msgAt(position, "'char-at' index out of bounds: char-at #{sndVal} but length #{fst.value.size}")
        end
        return StringValue.new "#{fst.value[sndVal.as Int]}"
      else
        raise Err.msgAt(position, "'chat-at' expects an integer as second argument")
      end
    else
      raise Err.msgAt(position, "'chat-at' expects integer as second argument")
    end
  end

  def evaluateStrReplace(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 3
      raise Err.msgAt(position, "'str-replace' expects three arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]
    unless fst.is_a? StringValue && snd.is_a? StringValue && trd.is_a? StringValue
      raise Err.msgAt(position, "'str-replace' expects only string argmuments")
    else
      return StringValue.new fst.value.sub(snd.value, trd.value)
    end
  end

  def evaluateStrReplaceAll(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 3
      raise Err.msgAt(position, "'str-replace-all' expects three arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    trd = arguments[2]
    unless fst.is_a? StringValue && snd.is_a? StringValue && trd.is_a? StringValue
      raise Err.msgAt(position, "'str-replace-all' expects only string argmuments")
    else
      return StringValue.new fst.value.gsub(snd.value, trd.value)
    end
  end

  def evaluateStrContains(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'str-contains?' expects two arguments")
    end
    fst = arguments[0]
    snd = arguments[1]
    unless fst.is_a? StringValue && snd.is_a? StringValue
      raise Err.msgAt(position, "'str-contains?' expects only string argmuments")
    else
      if fst.value.includes? snd.value
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    end
  end

  def evaluateStrLength(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(position, "'str-length' expects one argument")
    end
    fst = arguments[0]
    unless fst.is_a? StringValue
      raise Err.msgAt(position, "'str-length' expects a string argmument")
    else
      return NumberValue.new fst.value.size
    end
  end
end
