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
  # tcp server
  # http server
  # get element of list
  # foreach list
  # filter list
  # car cdr
  # char-at chat et string position

  class BuildIn

    @fns = [
      "+", "-", "*", "/", "mod", "lt?", "lte?", "gt?", "gte?", # number stuff
      "and", "or", "not", # bool stuff
      "out", "debug", "to-str", "typeof", # weird stuff
      "contains?", "length", "sublist", "map", "concat", # list stuff
      "eq?", # comparison
      "str-concat", "substr", "str-replace" ,"str-replace-all", "str-contains?", "str-length", # string stuff
    ];

    def hasFunction(ref : LRef | DefunRef) : Bool
      return @fns.includes? ref.name
    end

    def evaluateFunction(ref : LRef | DefunRef, arguments : Array(RuntimeValue), context : EvaluationContext) : RuntimeValue
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
        when "eq?"
          return evaluateEquals(arguments)
        when "debug"
          return evaluateDebug(arguments)
        when "to-str"
          return evaluateToStr(arguments)
        when "typeof"
          return evaluateType(arguments)
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
