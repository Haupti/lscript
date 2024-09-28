require "./parser/lparser.cr"
require "./interpreter/interpreter.cr"

def main
  str = File.read(ARGV[0])
  before = Time.utc
  parsed = LParser.parse(str)
  Interpreter.run parsed
  after =  Time.utc

  puts "#{before.millisecond}:#{before.nanosecond}"
  puts "#{after.millisecond}:#{after.nanosecond}"
end

main
