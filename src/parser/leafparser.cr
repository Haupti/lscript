require "../error_utils.cr"

module LeafParser
  extend self
  def parseLeaf(leaf : Leaf) : LAtom
    if leaf.leaf.starts_with? /[0-9]+.*/
        if leaf.leaf.includes? '.'
          floatparsed = leaf.leaf.to_f?
          if floatparsed.nil?
            raise Err.msgAt(leaf.position, "not a valid float number")
          else
            return LNumber.new(floatparsed, leaf.position)
          end
        else
          intparsed = leaf.leaf.to_i?
          if intparsed.nil?
            raise Err.msgAt(leaf.position, "not a valid number")
          else
            return LNumber.new(intparsed, leaf.position)
          end
        end
    elsif leaf.leaf.starts_with?('"') && leaf.leaf.ends_with?('"')
      return LString.new(leaf.leaf[1..-2], leaf.position)
    elsif leaf.leaf.includes? '"'
      raise Err.msgAt(leaf.position, "'\"' is not allowed in symbols")
    elsif leaf.leaf.starts_with? "'"
      return LSymbol.new(leaf.leaf, leaf.position)
    else
      return LRef.new(leaf.leaf, leaf.position)
    end
    raise Err.bug("how did i even get here?")
  end
end
