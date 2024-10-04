require "./spec_helper"
require "../src/parser/lparser.cr"
require "../src/parser/expression.cr"
require "../src/parser/tree.cr"

describe LParser do
  it "parses list" do
    LParser.parse("'()").should eq [LList.new ([] of LData)]
  end
  it "parses list with content" do
    LParser.parse("'(1.2 3 'hi)").should eq [LList.new ([LNumber.new(1.2), LNumber.new(3), LSymbol.new("'hi")] of LData)]
  end
  it "parses list with string" do
    LParser.parse("'(\"hello\")").should eq [LList.new ([LString.new("hello")] of LData)]
  end
  it "parses defun expression" do
    LParser.parse("(defun (fnname x z y) (lambda (a b c) (+ a b c x z y)))").should eq [
      LExpression.new(LRef.new("defun"), [
        LExpression.new(LRef.new("fnname"), [LRef.new("x"), LRef.new("y"), LRef.new("z")] of LData),
        LExpression.new(LRef.new("lambda"), [LRef.new("a"), LRef.new("b"), LRef.new("c")] of LData)
      ] of LData)
      ]
  end
end
