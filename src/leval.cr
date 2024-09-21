require "./lparser.cr"
require "./interpreter/tree.cr"
require "./interpreter/utils.cr"
require "./interpreter/functions.cr"

module LEval
  extend self
  def eval(content : Array(Node | Leaf))
    if content.size == 0
      return
    end

    first = content[0]
    case first
    when Node
      eval first.children
    when Leaf
      evalExpr(first, content[1..-1])
    else
      raise "unhandled case #{content[0]}"
    end
  end

  def evalExpr(head : Leaf, rest : Array(Node | Leaf))
    case head.leaf
    when "puts"
      evalPutsWith rest
    else
      raise "unhandled case #{head.leaf}"
    end
  end

  def evalPutsWith(args : Array(Node | Leaf))
    puts (toString args)
    evalOne(args[0])
  end

  def evalOne(arg : Node | Leaf)
  end

end


