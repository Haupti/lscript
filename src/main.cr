require "./parser/lparser.cr"
require "./interpreter/module_loader.cr"
require "./interpreter/interpreter.cr"

def main
  before = Time.utc
  ModuleLoader::INSTANCE.runMain(ARGV[0])
  after =  Time.utc

  puts "#{before.millisecond}:#{before.nanosecond}"
  puts "#{after.millisecond}:#{after.nanosecond}"
end

main
