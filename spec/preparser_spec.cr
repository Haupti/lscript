require "./spec_helper"
require "../src/parser/preparser.cr"
require "../src/parser/expression.cr"
require "../src/parser/position.cr"
require "../src/parser/tree.cr"

describe PreParser do
  it "empty brackets is a node" do
    PreParser.doParse("()").should eq([Node.new([] of Tree, Position.new(1,2))])
  end

  it "top level value is ignored" do
    PreParser.doParse("1").should eq([] of Tree)
  end

  it "list of number" do
    PreParser.doParse("'(1)").should eq([
      Node.new([Leaf.new("quote", Position.new(1,4)),
                Leaf.new("1", Position.new(1,3))
    ] of Tree, Position.new(1,4))])
  end

  it "expr" do
    result = PreParser.doParse("(hi 1 1.1 \"lol\" 'test)")
    result.should eq([
      Node.new([Leaf.new("hi", Position.new(1,3)),
                Leaf.new("1", Position.new(1,5)),
                Leaf.new("1.1", Position.new(1,9)),
                Leaf.new("\"lol\"", Position.new(1,15)),
                Leaf.new("'test", Position.new(1,21)),
    ] of Tree, Position.new(1,22))
    ])
  end
  it "ignores comments" do
    result = PreParser.doParse("(hi ;1 1.1; \"lol;\" 'test)\n; hallo \"y\"")
    result.should eq([
      Node.new([Leaf.new("hi", Position.new(1,3)),
                Leaf.new("\"lol;\"", Position.new(1,18)),
                Leaf.new("'test", Position.new(1,24)),
    ] of Tree, Position.new(1,25))
    ])
  end

  it "counts rows and columns correctly" do
    result = PreParser.parseWords("(out \"\nhi\"\n)")
    result.should eq([
      Token.new("(", Position.new(1,1)),
      Token.new("out", Position.new(1,4)),
      Token.new("\"\nhi\"", Position.new(2,3)),
      Token.new(")", Position.new(3,1)),
    ])
  end
end
