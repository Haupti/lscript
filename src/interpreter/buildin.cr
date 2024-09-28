require "./runtime_object_types.cr"

class BuildIn
  def self.hasFunction(ref : LRef) : Bool
    raise "TODO"
  end
  def self.evaluateFunction(ref : LRef, arguments : Array(RuntimeValue)) : RuntimeValue
    raise "TODO"
  end
end
