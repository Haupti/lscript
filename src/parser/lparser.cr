require "./tree.cr"
require "./preparser.cr"
require "./expression.cr"

module LParser
  extend self

  def parse(str : String) : Array(Data)
    # TODO
    preparsed = PreParser.doParse(str)
    # then parsing into language data
    # return data
    raise "not yet implemented"
  end
end
