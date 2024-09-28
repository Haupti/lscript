require "./runtime_object_types.cr"


module BuildIn
  extend self

  class BuildIn

    @fns = ["+", "-", "out", "mod"];

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
        when "out"
          return evaluateOut(arguments)
        when "mod"
          return evaluateModulo(arguments)
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
          result += "#{arg}"
      end
      puts result
      return NilValue.new
    end
  end

  INSTANCE = BuildIn.new
end
