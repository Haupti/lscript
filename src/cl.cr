struct Leaf
  property leaf : String
  def initialize(@leaf)
    leaf = @leaf
  end
end
struct Node
  property child : Array(Node | Leaf)
  def initialize(@child)
    child = @child
  end
end

def parseWords(str : String) : Array(String)
  inString = false

  words = [] of String
  word = ""

  str.chars.each do |c|
    if c == '"'
      inString = !inString
    end
    if inString
      word += c
    end
    unless inString
      unless c == ' ' ||  c == '\n' ||  c == '(' ||  c == ')'
        word += c
      end
      if c == '('  || c == ')'
        unless word.strip == ""
          words.push word
          word = ""
        end
        words.push ("" + c)
      end
      if (c == ' ' || c == '\n') && word.strip != ""
        words.push word
        word = ""
      end
    end
  end
  return words
end

def parse(words : Array(String)) : Array(Node | Leaf)

  nodes = [] of Node | Leaf

  inBrackets = false
  brCounter = 0
  sectionWords = [] of String
  words.each do |word|
    if word == "("
      inBrackets = true
      brCounter += 1
    elsif word == ")"
      brCounter -= 1
    end

    if inBrackets && brCounter == 0
      inBrackets = false
      nodes.push (Node.new (parse sectionWords[1..-1]))
      sectionWords = [] of String
    elsif inBrackets
      sectionWords.push word
    elsif !inBrackets
      nodes.push (Leaf.new word)
    end
  end
  unless brCounter == 0
    raise Exception.new("expected ')'")
  else
    return nodes
  end
end

#puts (parse (parseWords "(defun (say-hello x) (puts (str-concat \"(hello \" x \"!)\")))"))
puts (parse (parseWords "(for-each '(1 2 3) (lambda (x) puts x))"))
