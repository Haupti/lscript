module Functions
  extend self
  enum Function
    PUTS
    STRCONCAT
  end

  def toFunction(str : String) : Function | Nil
    case str
    when "puts"
      return Function::PUTS
    when "STRCONCAT"
      return Function::STRCONCAT
    else
      return nil
    end
  end

end
