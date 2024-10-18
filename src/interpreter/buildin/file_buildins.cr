module FileBuildin
  extend self

  def evaluateFileRead(callPosition : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 1
      raise Err.msgAt(callPosition, "'file-read' expects one argument")
    end
    first = arguments[0]
    unless first.is_a? StringValue
      raise Err.unexpectedValue(callPosition, "'file-read' expects a file path", first)
    end
    if !File.exists?(first.value)
      return ErrorValue.new("'#{first.value}' file not found")
    end
    if !File.file?(first.value)
      return ErrorValue.new("'#{first.value}' not a file")
    end
    if !File.readable?(first.value)
      return ErrorValue.new("'#{first.value}' not readable")
    end
    return StringValue.new(File.read(first.value))
  end

  def evaluateFileWrite(callPosition : Position, arguments : Array(RuntimeValue)) : RuntimeValue
    if arguments.size != 2
      raise Err.msgAt(callPosition, "'file-write' expects two argument")
    end
    first = arguments[0]
    second = arguments[0]
    unless first.is_a? StringValue
      raise Err.unexpectedValue(callPosition, "'file-write' expects a file path as first argument", first)
    end
    unless second.is_a? StringValue
      raise Err.unexpectedValue(callPosition, "'file-write' expects a string as second argument", second)
    end
    if !File.writable?(first.value)
      return ErrorValue.new("'#{first.value}' not writeable")
    end
    File.write(first.value, second.value)
    return NilValue.new
  end

end
