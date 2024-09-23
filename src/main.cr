require "./parser/lparser.cr"
require "./interpreter/interpreter.cr"

def main
  str = File.read(ARGV[0])
  parsed = LParser.parse(str)
  Interpreter.run parsed
end

main
