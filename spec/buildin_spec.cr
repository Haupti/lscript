require "../src/interpreter/buildin/buildin.cr"
require "../src/interpreter/evaluation_context.cr"
describe BuildIn do
  context = EvaluationContext.new

  # ADD
  it "+ adds numbers" do
    BuildIn::INSTANCE.hasFunction(LRef.new("+")).should eq(true)
    result = BuildIn::INSTANCE.evaluateFunction(
      LRef.new("+"),
      [NumberValue.new(12), NumberValue.new(1.1)] of RuntimeValue,
      context
    )
    (result.is_a? NumberValue).should eq(true)
    (result.as NumberValue).value.should eq(13.1)
  end
  expect_raises(Exception, /^'\+' expects at least two arguments$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("+"),
      [NumberValue.new(12)] of RuntimeValue,
      context
    )
  end
  expect_raises(Exception, /^'\+' expects number arguments but got symbol$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("+"),
      [SymbolValue.new("'hi'"), NumberValue.new(1)] of RuntimeValue,
      context
    )
  end

  # SUBTRACT
  it "- subracts numbers" do
    BuildIn::INSTANCE.hasFunction(LRef.new("+")).should eq(true)
    result = BuildIn::INSTANCE.evaluateFunction(
      LRef.new("-"),
      [NumberValue.new(12), NumberValue.new(1.1)] of RuntimeValue,
      context
    )
    (result.is_a? NumberValue).should eq(true)
    (result.as NumberValue).value.should eq(10.9)
  end
  expect_raises(Exception, /^'-' expects at least two arguments$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("-"),
      [NumberValue.new(12)] of RuntimeValue,
      context
    )
  end
  expect_raises(Exception, /^'-' expects number arguments but got symbol$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("-"),
      [SymbolValue.new("'hi'"), NumberValue.new(1)] of RuntimeValue,
      context
    )
  end

  # MODULO
  it "mod calculates modulo" do
    BuildIn::INSTANCE.hasFunction(LRef.new("+")).should eq(true)
    result = BuildIn::INSTANCE.evaluateFunction(
      LRef.new("mod"),
      [NumberValue.new(12), NumberValue.new(4)] of RuntimeValue,
      context
    )
    (result.is_a? NumberValue).should eq(true)
    (result.as NumberValue).value.should eq(0)
  end
  expect_raises(Exception, /^'mod' expects exactly two arguments$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("mod"),
      [NumberValue.new(12)] of RuntimeValue,
      context
    )
  end
  expect_raises(Exception, /^'mod' expects two integer arguments but got symbol and number$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("mod"),
      [SymbolValue.new("'hi'"), NumberValue.new(1)] of RuntimeValue,
      context
    )
  end
  expect_raises(Exception, /^'mod' expects two integer arguments but got '1.1' and '1'$/) do
    BuildIn::INSTANCE.evaluateFunction(
      LRef.new("mod"),
      [NumberValue.new(1.1), NumberValue.new(1)] of RuntimeValue,
      context
    )
  end
end
