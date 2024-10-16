require "./tree.cr"
require "./preparser.cr"
require "./expression.cr"
require "./leafparser.cr"
require "../error_utils.cr"

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
      else raise Err.bug("expected Node or Leaf")
      end
    end

    return data
  end

  def parseNode(node : Node) : LData
    if node.children.size == 0
      return LNil.new node.position
    end

    first = node.children[0]
    case first
    when Leaf
      if first.leaf == PreParser::QUOTE_MARK
        return LList.new(parseMany(node.children[1..-1]), node.position)
      else
        firstLeaf = LeafParser.parseLeaf first
        case firstLeaf
        when LString
          raise Err.msgAt(firstLeaf.position, "expected a identifier as first argument of an expression, but got string")
        when LNumber
          raise Err.msgAt(firstLeaf.position, "expected a identifier as first argument of an expression, but got number")
        when LSymbol
          raise Err.msgAt(firstLeaf.position, "expected a identifier as first argument of an expression, but got symbol")
        when LRef
          return LExpression.new(firstLeaf, parseMany(node.children[1..]), firstLeaf.position)
        else
          raise Err.bugAt(firstLeaf.position, "expected Leaf type here but got '#{firstLeaf}'")
        end
      end
    when Node
      parsedFirst = parseNode(first)
      if parsedFirst.is_a? LExpression
        return LExpression.new(parsedFirst, parseMany(node.children[1..]), positionOf(parsedFirst))
      else
        raise Err.msgAt(parsedFirst.position, "expected a expression or identifier as first argument of an expression")
      end
    else
      raise Err.bugAt(first.position, "expected tree type here but got '#{first}'")
    end
  end
end
