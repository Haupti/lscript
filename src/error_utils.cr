require "./interpreter/runtime_object_types.cr"

module Err
  extend self
  def unexpectedValue(at : Position, msg : String, value : RuntimeValue | Nil) : String
    if value.nil?
      return "ERROR at (#{at.row},#{at.col}): #{msg} but got nil"
    end
    return "ERROR at (#{at.row},#{at.col}): #{msg} but got #{rtvToStr(value)}"
  end
  def msgAt(at : Position, msg : String) : String
    return "ERROR at (#{at.row},#{at.col}): #{msg}"
  end
  def msgAt(at : Position, msg : String) : String
    return "ERROR at (#{at.row},#{at.col}): #{msg}"
  end
  def msg(msg : String) : String
    return "ERROR: #{msg}"
  end
  def bugAt(at : Position, msg : String) : String
    return "BUG at (#{at.row},#{at.col}): #{msg}"
  end
  def bug(msg : String) : String
    return "BUG: #{msg}"
  end
end
