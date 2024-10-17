require "../runtime_object_types.cr"
require "./list_buildins.cr"
require "./number_buildins.cr"
require "./string_buildins.cr"
require "./io_buildin.cr"
require "./symbol_buildin.cr"


module BuildIn
  extend self

  class BuildIn

    @fns = [
      "+", "-", "*", "/", "mod", "lt?", "lte?", "gt?", "gte?", # number stuff
      "and", "or", "not", # bool stuff
      "debug", "to-str", "typeof", "err", "err?", "err-reason", "panic", # weird stuff
      "out", "get-input", # io stuff
      "contains?", "length", "sublist", "map", "concat", "head", "tail", "filter", "get", # list stuff
      "eq?", # comparison
      "str-concat", "substr", "str-replace" ,"str-replace-all", "str-contains?", "str-length", "char-at", # string stuff
      "load-module", # module stuff
    ];

    def hasFunction(ref : LRef | BuildinFunctionRef) : Bool
      return @fns.includes? ref.name
    end

    def evaluateFunction(callPosition : Position, ref : LRef | BuildinFunctionRef, arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
      found = @fns.includes? ref.name
      if !found
        raise Err.msgAt(callPosition, "#{ref.name} not in scope")
      else
        case ref.name
        when "+"
          return NumberBuildin.evaluateAdd(callPosition, arguments)
        when "-"
          return NumberBuildin.evaluateMinus(callPosition, arguments)
        when "*"
          return NumberBuildin.evaluateMultiply(callPosition, arguments)
        when "/"
          return NumberBuildin.evaluateDivide(callPosition, arguments)
        when "gt?"
          return NumberBuildin.evaluateGT(callPosition, arguments)
        when "lt?"
          return NumberBuildin.evaluateLT(callPosition, arguments)
        when "gte?"
          return NumberBuildin.evaluateGTE(callPosition, arguments)
        when "lte?"
          return NumberBuildin.evaluateLTE(callPosition, arguments)
        when "mod"
          return NumberBuildin.evaluateModulo(callPosition, arguments)
        when "and"
          return SymbolBuildin.evaluateAnd(callPosition, arguments)
        when "or"
          return SymbolBuildin.evaluateOr(callPosition, arguments)
        when "not"
          return SymbolBuildin.evaluateNot(callPosition, arguments)
        when "out"
          return IOBuildin.evaluateOut(arguments)
        when "get-input"
          return IOBuildin.evaluateGetInput(arguments)
        when "contains?"
          return ListBuildin.evaluateContains(callPosition, arguments)
        when "sublist"
          return ListBuildin.evaluateSublist(callPosition, arguments)
        when "concat"
          return ListBuildin.evaluateConcat(callPosition, arguments)
        when "map"
          return ListBuildin.evaluateMap(callPosition, arguments, context)
        when "length"
          return ListBuildin.evaluateLength(callPosition, arguments)
        when "head"
          return ListBuildin.evaluateHead(callPosition, arguments)
        when "tail"
          return ListBuildin.evaluateTail(callPosition, arguments)
        when "filter"
          return ListBuildin.evaluateFilter(callPosition, arguments, context)
        when "get"
          return ListBuildin.evaluateGet(callPosition, arguments)
        when "str-concat"
          return StringBuildin.evaluateStrConcat(callPosition, arguments)
        when "str-replace"
          return StringBuildin.evaluateStrReplace(callPosition, arguments)
        when "str-replace-all"
          return StringBuildin.evaluateStrReplaceAll(callPosition, arguments)
        when "str-contains?"
          return StringBuildin.evaluateStrContains(callPosition, arguments)
        when "str-length"
          return StringBuildin.evaluateStrLength(callPosition, arguments)
        when "substr"
          return StringBuildin.evaluateSubstr(callPosition, arguments)
        when "char-at"
          return StringBuildin.evaluateCharAt(callPosition, arguments)
        when "eq?"
          return evaluateEquals(callPosition, arguments)
        when "debug"
          return evaluateDebug(callPosition, arguments)
        when "to-str"
          return evaluateToStr(callPosition, arguments)
        when "typeof"
          return evaluateType(callPosition, arguments)
        when "err"
          return evaluateError(callPosition, arguments)
        when "err?"
          return evaluateIsError(callPosition, arguments)
        when "err-reason"
          return evaluateErrorReason(callPosition, arguments)
        when "panic"
          return evaluateErrorPanic(callPosition, arguments)
        when "load-module"
          return evaluateLoadModule(callPosition, arguments)
        else
          raise Err.msgAt(callPosition, "#{ref.name} not in scope")
        end
      end
    end

    def evaluateLoadModule(position : Position, arguments : Array(RuntimeValue)) : TableObject
      if arguments.size != 1
        raise Err.msgAt(position, "'load-module' one argument")
      end
      first = arguments[0]
      if !first.is_a? StringValue
        raise Err.msgAt(position, "'load-module' expects a string")
      end
      return ModuleLoader::INSTANCE.loadModule(first.value)
    end

    def evaluateToStr(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise Err.msgAt(position, "'to-str' expects one arguments")
      end
      return StringValue.new rtvToStr(arguments[0])
    end

    def evaluateType(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise Err.msgAt(position, "'typeof' expects one arguments")
      end
      arg = arguments[0]
      return StringValue.new(typeName(arg))
    end

    def evaluateDebug(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      result = ""
      arguments.each do |arg|
          result += "#{arg}"
      end
      puts result
      return NilValue.new
    end

    def evaluateEquals(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size < 2
        raise Err.msgAt(position, "'eq?' expects at least two arguments")
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

    def evaluateError(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise Err.msgAt(position, "'err' expects one argument")
      end
      fst = arguments[0]
      if !fst.is_a? StringValue
        raise Err.msgAt(position, "'err' expects a string argument")
      end
      return ErrorValue.new fst.value
    end

    def evaluateIsError(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise Err.msgAt(position, "'err?' expects one arguments")
      end
      if arguments[0].is_a? ErrorValue
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    end

    def evaluateErrorReason(position : Position, arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise Err.msgAt(position, "'err-reason' expects one arguments")
      end
      fst = arguments[0]
      if !fst.is_a? ErrorValue
        raise Err.msgAt(position, "'err-reason' expects an error value as argument")
      end
      return StringValue.new fst.reason
    end

    def evaluateErrorPanic(position : Position, arguments : Array(RuntimeValue))
      if arguments.size != 1
        raise Err.msgAt(position, "'panic' expects one arguments")
      end
      error = arguments[0]
      if error.is_a? ErrorValue
        puts "panic: #{error.reason}"
        exit 1
      else
        raise Err.msgAt(position, "'panic' expects an error value")
      end

    end

  end

  INSTANCE = BuildIn.new
end
