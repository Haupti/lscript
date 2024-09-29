require "./runtime_object_types.cr"


module BuildIn
  extend self

  # TODO build-in functions to implement
  # and or not for 'booleans'
  # get element of list
  # size of list
  # sublist
  # map list
  # foreach list
  # filter list
  # concat lists

  class BuildIn

    @fns = [
      "+", "-", "*", "/", "mod", "lt?", "lte?", "gt?", "gte?", # number stuff
      "out", "debug", "to-str", "typeof", # weird stuff
      "contains?", # list stuff
      "eq?", # comparison
      "str-concat", "substr", "str-replace" ,"str-replace-all", "str-contains?" # string stuff
    ];

    def hasFunction(ref : LRef) : Bool
      return @fns.includes? ref.name
    end

    def evaluateFunction(ref : LRef, arguments : Array(RuntimeValue)) : RuntimeValue
      found = @fns.includes? ref.name
      if !found
        raise "#{ref.name} not in scope"
      else
        case ref.name
        when "+"
          return evaluateAdd(arguments)
        when "-"
          return evaluateMinus(arguments)
        when "*"
          return evaluateMultiply(arguments)
        when "/"
          return evaluateDivide(arguments)
        when "gt?"
          return evaluateGT(arguments)
        when "lt?"
          return evaluateLT(arguments)
        when "gte?"
          return evaluateGTE(arguments)
        when "lte?"
          return evaluateLTE(arguments)
        when "mod"
          return evaluateModulo(arguments)
        when "out"
          return evaluateOut(arguments)
        when "debug"
          return evaluateDebug(arguments)
        when "to-str"
          return evaluateToStr(arguments)
        when "typeof"
          return evaluateType(arguments)
        when "contains?"
          return evaluateContains(arguments)
        when "eq?"
          return evaluateEquals(arguments)
        when "str-concat"
          return evaluateStrConcat(arguments)
        when "str-replace"
          return evaluateStrReplace(arguments)
        when "str-replace-all"
          return evaluateStrReplaceAll(arguments)
        when "str-contains?"
          return evaluateStrContains(arguments)
        when "substr"
          return evaluateSubstr(arguments)
        else
          raise "#{ref.name} not in scope"
        end
      end
    end

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
        raise "+ expects at least two arguments"
      end
      result = 0
      arguments.each do |arg|
        if arg.is_a? NumberValue
          result += arg.value
        else
          raise "+ expects number arguments but got #{arg}"
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
        raise "- expects at least two arguments"
      end
      initial = arguments[0]
      if !(initial.is_a? NumberValue)
        raise "- expects number arguments but got #{initial}"
      end
      result = initial.value
      arguments[1..].each do |arg|
        if arg.is_a? NumberValue
          result -= arg.value
        else
          raise "- expects number arguments but got #{arg}"
        end
      end
      return NumberValue.new result
    end

    def evaluateModulo(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 2
        raise "'mod' expects exaclty two arguments"
      end
      fst = arguments[0]
      snd = arguments[1]
      if !(fst.is_a? NumberValue  && snd.is_a? NumberValue && snd.value.integer?)
        raise "'mod' expects two integer arguments but got '#{fst}' and '#{snd}'"
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

    def evaluateOut(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size < 1
        raise "'out' expects at least one arguments"
      end
      result = ""
      arguments.each do |arg|
          result += "#{rtvToStr(arg)}"
      end
      puts result
      return NilValue.new
    end

    def evaluateToStr(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise "'to-str' expects one arguments"
      end
      return StringValue.new rtvToStr(arguments[0])
    end

    def evaluateType(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise "'typeof' expects one arguments"
      end
      arg = arguments[0]
      case arg
      when StringValue
        return StringValue.new "string"
      when NumberValue
        return StringValue.new "number"
      when SymbolValue
        return StringValue.new "symbol"
      when ListObject
        return StringValue.new "list"
      when DefunRef
        return StringValue.new "function-reference"
      when NilValue
        return StringValue.new "nil"
      else
        raise "unexpected no case matched while evaluating type"
      end
    end

    def evaluateDebug(arguments : Array(RuntimeValue)) : RuntimeValue
      result = ""
      arguments.each do |arg|
          result += "#{arg}"
      end
      puts result
      return NilValue.new
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

    def evaluateEquals(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size < 2
        raise "'=' expects at least two arguments"
      end
      result = true
      first = arguments[0]
      arguments[1..].each do |arg|
        result = first == arg
        if !result
          return SymbolValue.falseValue
        end
      end
      if result
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    end

    def evaluateStrConcat(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size < 2
        raise "'str-concat' expects at least two arguments"
      end
      result = ""
      arguments.each do |arg|
        if arg.is_a? StringValue
          result += arg.value
        else
          raise "'str-concat' expects string arguments but got #{arg}"
        end
      end
      return StringValue.new result
    end

    def evaluateSubstr(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size < 2 || arguments.size > 3
        raise "'substr' expects two or three arguments"
      end
      fst = arguments[0]
      snd = arguments[1]
      trd = arguments[2]?
      unless fst.is_a? StringValue
        raise "'substr' expects a string as first argument"
      end
      unless snd.is_a? NumberValue
        raise "'substr' expects a integer as second argument"
      end
      unless (trd == nil || trd.is_a? NumberValue)
        raise "'substr' expects nil or an integer as third argument"
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
            raise "'substr' expects an integer or nil as third argument"
          end
        else
          raise "'substr' expects an integer or nil as third argument"
        end
      else
        raise "'substr' expects an integer as second argument"
      end
    end

    def evaluateStrReplace(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 3
        raise "'str-replace' expects three arguments"
      end
      fst = arguments[0]
      snd = arguments[1]
      trd = arguments[2]
      unless fst.is_a? StringValue && snd.is_a? StringValue && trd.is_a? StringValue
        raise "'substr' expects only string argmuments"
      else
        return StringValue.new fst.value.sub(snd.value, trd.value)
      end
    end

    def evaluateStrReplaceAll(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 3
        raise "'str-replace' expects three arguments"
      end
      fst = arguments[0]
      snd = arguments[1]
      trd = arguments[2]
      unless fst.is_a? StringValue && snd.is_a? StringValue && trd.is_a? StringValue
        raise "'substr' expects only string argmuments"
      else
        return StringValue.new fst.value.gsub(snd.value, trd.value)
      end
    end

    def evaluateStrContains(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 2
        raise "'str-contains?' expects two arguments"
      end
      fst = arguments[0]
      snd = arguments[1]
      unless fst.is_a? StringValue && snd.is_a? StringValue
        raise "'str-contains?' expects only string argmuments"
      else
        if fst.value.includes? snd.value
          return SymbolValue.trueValue
        else
          return SymbolValue.falseValue
        end
      end
    end
  end

  INSTANCE = BuildIn.new
end
