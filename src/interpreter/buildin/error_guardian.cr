require "../runtime_object_types.cr"

module ErrorGuardian
  extend self

  def shield(value : RuntimeValue)
    if value.is_a? ErrorValue
      raise value.reason
    end
  end
end
