require "./lparser.cr"

module LEval
  extend self
  def eval(content : Array(LParser::Node | LParser::Leaf))
    if content.size == 0
      return
    end

    case content[0]
    when LParser::Node
      eval content[0].child
    when LParser::Leaf
      evalExpr content
    else
      raise "unhandled case #{content[0]}"
    end
  end

  def evalExpr(leaf : Array(LParser::Node | LParser::Leaf))
    # TODO
  end

  def evalPutsWith(args : Array(LParser::Node | LParser::Leaf))
    # TODO
  end
end


