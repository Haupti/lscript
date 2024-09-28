require "./runtime_object_types.cr"


module BuildIn
  extend self

  class BuildIn

    @fns = [
      "+", "-", "*", "/", "mod",
      "out", "debug", "to-str", "typeof",
      "contains?",
      "eq?",
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
        else
          raise "#{ref.name} not in scope"
        end
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
  end

  INSTANCE = BuildIn.new
end
