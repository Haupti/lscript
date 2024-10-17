
class ModuleLoader
  @mainpath : String = ""

  INSTANCE = ModuleLoader.new

  def loadModule(relativePath : String) : TableObject
    str = File.read(File.dirname(@mainpath) + "/" + relativePath)
    parsed = LParser.parse(str)
    return Interpreter.loadModule parsed
  end

  def runMain(path : String)
    @mainpath = path
    str = File.read(path)
    parsed = LParser.parse(str)
    return Interpreter.run parsed
  end
end
