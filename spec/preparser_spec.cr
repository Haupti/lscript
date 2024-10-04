require "./spec_helper"
require "../src/parser/preparser.cr"
require "../src/parser/expression.cr"
require "../src/parser/tree.cr"

describe PreParser do
  it "empty brackets is a node" do
    PreParser.doParse("()").should eq([Node.new ([] of Tree)])
  end
  it "top level value is ignored" do
    PreParser.doParse("1").should eq([] of Tree)
  end

  it "list of number" do
    PreParser.doParse("'(1)").should eq([Node.new([Leaf.new("quote"), Leaf.new("1")] of Tree)])
  end

  it "expr" do
    result = PreParser.doParse("(hi 1 1.1 \"lol\" 'test)")
    result.should eq([
      Node.new([Leaf.new("hi"),
                Leaf.new("1"),
                Leaf.new("1.1"),
                Leaf.new("\"lol\""),
                Leaf.new("'test"),
    ] of Tree)
    ])
  end
  it "ignores comments" do
    result = PreParser.doParse("(hi ;1 1.1; \"lol\" 'test)\n; hallo")
    result.should eq([
      Node.new([Leaf.new("hi"),
                Leaf.new("\"lol\""),
                Leaf.new("'test"),
    ] of Tree)
    ])
  end
end
