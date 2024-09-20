require "./lparser.cr"
require "./leval.cr"

def main
  str = File.read(ARGV[0])
  parsed = LParser.doParse(str)
  LEval.eval(parsed)
end

main
