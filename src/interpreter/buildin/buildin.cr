require "../runtime_object_types.cr"
require "./list_buildins.cr"
require "./number_buildins.cr"
require "./string_buildins.cr"
require "./io_buildin.cr"
require "./symbol_buildin.cr"


module BuildIn
  extend self

  # TODO build-in functions to implement
  # read file / write file
  # program arguments
  # sockets: tcp / http ?
  # parse number

  class BuildIn

    @fns = [
      "+", "-", "*", "/", "mod", "lt?", "lte?", "gt?", "gte?", # number stuff
      "and", "or", "not", # bool stuff
      "debug", "to-str", "typeof", "err", "err?", "err-reason", "panic", # weird stuff
      "out", "get-input", # io stuff
      "contains?", "length", "sublist", "map", "concat", "head", "tail", "filter", "get", # list stuff
      "eq?", # comparison
      "str-concat", "substr", "str-replace" ,"str-replace-all", "str-contains?", "str-length", "char-at", # string stuff
    ];

    def hasFunction(ref : LRef) : Bool
      return @fns.includes? ref.name
    end

    def evaluateFunction(ref : LRef | BuildinFunctionRef, arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
      found = @fns.includes? ref.name
      if !found
        raise "#{ref.name} not in scope"
      else
        case ref.name
        when "+"
          return NumberBuildin.evaluateAdd(arguments)
        when "-"
          return NumberBuildin.evaluateMinus(arguments)
        when "*"
          return NumberBuildin.evaluateMultiply(arguments)
        when "/"
          return NumberBuildin.evaluateDivide(arguments)
        when "gt?"
          return NumberBuildin.evaluateGT(arguments)
        when "lt?"
          return NumberBuildin.evaluateLT(arguments)
        when "gte?"
          return NumberBuildin.evaluateGTE(arguments)
        when "lte?"
          return NumberBuildin.evaluateLTE(arguments)
        when "mod"
          return NumberBuildin.evaluateModulo(arguments)
        when "and"
          return SymbolBuildin.evaluateAnd(arguments)
        when "or"
          return SymbolBuildin.evaluateOr(arguments)
        when "not"
          return SymbolBuildin.evaluateNot(arguments)
        when "out"
          return IOBuildin.evaluateOut(arguments)
        when "get-input"
          return IOBuildin.evaluateGetInput(arguments)
        when "contains?"
          return ListBuildin.evaluateContains(arguments)
        when "sublist"
          return ListBuildin.evaluateSublist(arguments)
        when "concat"
          return ListBuildin.evaluateConcat(arguments)
        when "map"
          return ListBuildin.evaluateMap(arguments, context)
        when "length"
          return ListBuildin.evaluateLength(arguments)
        when "head"
          return ListBuildin.evaluateHead(arguments)
        when "tail"
          return ListBuildin.evaluateTail(arguments)
        when "filter"
          return ListBuildin.evaluateFilter(arguments, context)
        when "get"
          return ListBuildin.evaluateGet(arguments)
        when "str-concat"
          return StringBuildin.evaluateStrConcat(arguments)
        when "str-replace"
          return StringBuildin.evaluateStrReplace(arguments)
        when "str-replace-all"
          return StringBuildin.evaluateStrReplaceAll(arguments)
        when "str-contains?"
          return StringBuildin.evaluateStrContains(arguments)
        when "str-length"
          return StringBuildin.evaluateStrLength(arguments)
        when "substr"
          return StringBuildin.evaluateSubstr(arguments)
        when "char-at"
          return StringBuildin.evaluateCharAt(arguments)
        when "eq?"
          return evaluateEquals(arguments)
        when "debug"
          return evaluateDebug(arguments)
        when "to-str"
          return evaluateToStr(arguments)
        when "typeof"
          return evaluateType(arguments)
        when "err"
          return evaluateError(arguments)
        when "err?"
          return evaluateIsError(arguments)
        when "err-reason"
          return evaluateErrorReason(arguments)
        when "panic"
          return evaluateErrorPanic(arguments)
        else
          raise "#{ref.name} not in scope"
        end
      end
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
      when FunctionObject
        return StringValue.new "function"
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

    def evaluateError(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise "'err' expects one argument"
      end
      fst = arguments[0]
      if !fst.is_a? StringValue
        raise "'err' expects a string argument"
      end
      return ErrorValue.new fst.value
    end

    def evaluateIsError(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise "'err?' expects one arguments"
      end
      if arguments[0].is_a? ErrorValue
        return SymbolValue.trueValue
      else
        return SymbolValue.falseValue
      end
    end

    def evaluateErrorReason(arguments : Array(RuntimeValue)) : RuntimeValue
      if arguments.size != 1
        raise "'err-reason' expects one arguments"
      end
      fst = arguments[0]
      if !fst.is_a? ErrorValue
        raise "'err-reason' expects an error value as argument"
      end
      return StringValue.new fst.reason
    end

    def evaluateErrorPanic(arguments : Array(RuntimeValue))
      if arguments.size != 1
        raise "'panic' expects one arguments"
      end
      error = arguments[0]
      if error.is_a? ErrorValue
        puts "panic: #{error.reason}"
        exit 1
      else
        raise "'panic' expects an error value"
      end

    end

  end

  INSTANCE = BuildIn.new
end
