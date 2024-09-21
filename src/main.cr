require "./parser/lparser.cr"
require "./interpreter/leval.cr"

def main
  str = File.read(ARGV[0])
  parsed = LParser.doParse(str)
  LEval.eval(parsed)
end

main
