require "./tree.cr"
require "./preparser.cr"
require "./expression.cr"
require "./leafparser.cr"

module LParser
  extend self

  def parse(str : String) : Array(LData)
    preparsed = PreParser.doParse(str)
    return parseMany(preparsed)
  end

  def parseMany(nodes : Array(Leaf | Node)) : Array(LData)
    data = [] of LData
    nodes.each do |node|
      case node
      when Node
        data << parseNode node
      when Leaf
        data << LeafParser.parseLeaf node
      else raise "expected Node or Leaf"
      end
    end

    return data
  end

  def parseNode(node : Node) : LData
    if node.children.size == 0
      return LList.new([] of LData)
    end

    first = node.children[0]
    case first
    when Leaf
      if first.leaf == PreParser::QUOTE_MARK
        return LList.new(parseMany node.children[1..-1])
      else
        firstLeaf = LeafParser.parseLeaf first
        case firstLeaf
        when LString
          raise "expected a symbol as first argument of an expression, but got String"
        when LNumber
          raise "expected a symbol as first argument of an expression, but got Number"
        when LSymbol
          return LExpression.new(firstLeaf, parseMany(node.children[1..-1]))
        else
          raise "BUG: expected Leaf type here but got '#{firstLeaf}'"
        end
      end
    when Node
      raise "BUG: expected Leaf here"
    else
      raise "BUG: expected tree type here"
    end
  end
end
