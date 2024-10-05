require "../src/interpreter/buildin/buildin.cr"
require "../src/interpreter/evaluation_context.cr"
describe BuildIn do
  context = EvaluationContext.new
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
end
