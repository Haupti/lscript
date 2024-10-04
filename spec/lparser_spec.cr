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
    result = LParser.parse("(defun (fnname x z y) (lambda (a b c) (+ a b c x z y)))")[0].as LExpression
    result.first.should eq LRef.new("defun")
    (result.arguments[0].as LExpression).first.should eq LRef.new("fnname")
    (result.arguments[0].as LExpression).arguments.should eq ([LRef.new("x"), LRef.new("z"), LRef.new("y")] of LData)
    (result.arguments[1].as LExpression).first.should eq LRef.new("lambda")
    ((result.arguments[1].as LExpression).arguments[0].as LExpression).first.should eq LRef.new("a")
    ((result.arguments[1].as LExpression).arguments[0].as LExpression).arguments.should eq ([LRef.new("b"), LRef.new("c")] of LData)
    ((result.arguments[1].as LExpression).arguments[1].as LExpression).first.should eq LRef.new("+")
    ((result.arguments[1].as LExpression).arguments[1].as LExpression).arguments.should eq ([LRef.new("a"), LRef.new("b"), LRef.new("c"), LRef.new("x"), LRef.new("z"), LRef.new("y")] of LData)


    #result.should eq LExpression.new(LRef.new("defun"), [
    #    LExpression.new(LRef.new("fnname"), [LRef.new("x"), LRef.new("z"), LRef.new("y")] of LData),
    #    LExpression.new(LRef.new("lambda"), [
    #      LExpression.new(LRef.new("a"), [
    #        LRef.new("b"),
    #        LRef.new("c")
    #      ] of LData),
    #      LExpression.new(LRef.new("+"), [
    #        LRef.new("a"),
    #        LRef.new("b"),
    #        LRef.new("c"),
    #        LRef.new("x"),
    #        LRef.new("z"),
    #        LRef.new("y")
    #      ] of LData)
    #  ] of LData),
    #  ] of LData)

  end
end
