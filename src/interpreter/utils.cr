require "./tree.cr"

def toString(args : Array(Node | Leaf))
  resultStr = ""
  args.each do |x|
    case x
    when Node
      resultStr = "#{resultStr} (#{toStringOne(x)})"
    when Leaf
      resultStr = "#{resultStr} #{toStringOne(x)}"
    else
      raise "unhandled case #{x}"
    end
  end
  return resultStr
end

def toStringOne(arg : Node | Leaf)
  case arg
  when Node
    return "(#{toString(arg.children)})"
  when Leaf
    return "#{arg.leaf}"
  else
    raise "unhandled case #{arg}"
  end
end
