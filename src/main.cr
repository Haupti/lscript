require "./parser/lparser.cr"
require "./interpreter/interpreter.cr"

def main
  puts Time.utc.millisecond
  str = File.read(ARGV[0])
  puts Time.utc.millisecond
  parsed = LParser.parse(str)
  Interpreter.run parsed
  puts Time.utc.millisecond
end

main
