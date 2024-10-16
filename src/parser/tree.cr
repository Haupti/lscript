alias Tree = Leaf | Node

struct Leaf
  property position : Position
  property leaf : String

  def initialize(@leaf, @position)
  end
end

struct Node
  property position : Position
  property children : Array(Node | Leaf)

  def initialize(@children, @position)
  end
end
