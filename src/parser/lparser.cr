require "./tree.cr"
require "./preparser.cr"
require "./expression.cr"
require "./leafparser.cr"

module LParser
  extend self

  def parse(str : String) : Array(LData)
    preparsed = PreParser.doParse(str)

    # parsing into language data
    data = [] of LData
    preparsed.each do |node|
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
      return [] of LData
    end
    first = node.children[0]
    case first
    when Leaf
      if first.leaf == PreParser::QUOTE_MARK
        #TODO
      end
      #TODO
    end
  end
end
