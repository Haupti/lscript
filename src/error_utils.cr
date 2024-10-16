module Err
  extend self
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
