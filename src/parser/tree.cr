struct Leaf
  property leaf : String

  def initialize(@leaf)
    leaf = @leaf
  end
end

struct Node
  property children : Array(Node | Leaf)

  def initialize(@children)
    child = @children
  end
end
