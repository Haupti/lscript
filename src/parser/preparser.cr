require "./tree.cr"


module PreParser
  extend self

  QUOTE_MARK = "quote"

  def parseWords(str : String) : Array(String)
    inString = false

    words = [] of String
    word = ""

    hasQuote = false
    str.chars.each do |c|
      if c == '"'
        inString = !inString
      elsif c == '\''
        hasQuote = true
        next
      end

      if inString
        word += c
      end

      unless inString
        if hasQuote && c != '('
          raise Exception.new("quote must be before bracket")
        end
        if c == '(' || c == ')'
          unless word.strip == ""
            words.push word
            word = ""
          end
          if hasQuote
            words.push ("'" + c)
            hasQuote = false
          else
            words.push ("" + c)
          end
        end
        unless c == ' ' ||  c == '\n' ||  c == '(' ||  c == ')'
          word += c
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

    hasQuote = false
    inBrackets = false
    brCounter = 0
    sectionWords = [] of String
    words.each do |word|
      if word == "("
        inBrackets = true
        brCounter += 1
      elsif word == "'("
        if brCounter > 0
          inBrackets= true
          brCounter += 1
        else
          inBrackets= true
          brCounter += 1
          hasQuote = true
        end
      elsif word == ")"
        brCounter -= 1
      end

      if inBrackets && brCounter == 0
        if hasQuote
          sectionWords[1...1] = QUOTE_MARK
          hasQuote = false
        end
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

  def doParse(str : String) : Array(Node | Leaf)
    return parse (parseWords str)
  end
end
