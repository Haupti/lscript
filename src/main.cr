require "./parser/lparser.cr"

def main
  str = File.read(ARGV[0])
  parsed = LParser.parse(str)
end

main
