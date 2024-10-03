require "./spec_helper"
require "../src/parser/leafparser.cr"
require "../src/parser/expression.cr"
require "../src/parser/tree.cr"

describe LeafParser do
  it "parses number" do
    LeafParser.parseLeaf(Leaf.new("1")).should eq(LNumber.new 1)
    LeafParser.parseLeaf(Leaf.new("1.1")).should eq(LNumber.new 1.1)
  end
  it "parses string" do
    LeafParser.parseLeaf(Leaf.new("\"hi\"")).should eq(LString.new "hi")
  end
  it "parses symbol" do
    LeafParser.parseLeaf(Leaf.new("'hi")).should eq(LSymbol.new "'hi")
  end
  it "parses ref" do
    LeafParser.parseLeaf(Leaf.new("hi")).should eq(LRef.new "hi")
  end
end
