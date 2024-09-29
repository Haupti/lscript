
module LeafParser
  extend self
  def parseLeaf(leaf : Leaf) : LAtom
    if leaf.leaf.starts_with? /[0-9]+.*/
        if leaf.leaf.includes? '.'
          floatparsed = leaf.leaf.to_f?
          if floatparsed.nil?
            raise "not a valid float number"
          else
            return LNumber.new floatparsed
          end
        elsif
          intparsed = leaf.leaf.to_i?
          if intparsed.nil?
            raise "not a valid int number"
          else
            return LNumber.new intparsed
          end
        end
    elsif leaf.leaf.starts_with?('"') && leaf.leaf.ends_with?('"')
      return LString.new leaf.leaf[1..-2]
    elsif leaf.leaf.includes? '"'
      raise "'\"' is not allowed in symbols"
    elsif leaf.leaf.starts_with? "'"
      return LSymbol.new leaf.leaf
    else
      return LRef.new leaf.leaf
    end
    raise "BUG: how did i even get here?"
  end
end
