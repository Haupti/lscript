require "./runtime_object_types.cr"


module BuildIn
  extend self

  class BuildIn

    @fns = ["+"];

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
        else
          raise "#{ref.name} not in scope"
        end
      end
    end

    def evaluateAdd(arguments : Array(RuntimeValue)) : RuntimeValue
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

  end

  INSTANCE = BuildIn.new
end
