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
      end

      if inString
        word += c
      end

      unless inString
        # I quote end word and is added to next word
        # II whitespaces end words and are ignored
        # III brackets end words and are added as separate words
        # IV only special: quote before bracket is added as quoted bracket word : '(


        # I
        if c == '\'' && word.strip != ""
          words << word
          word = "'"
          next
        elsif c == '\''
          word = "'"
          next
        end

        # II
        if (c == ' ' || c == '\n') && word.strip != ""
          if word == "'"
            raise "standalone quotes are not allowed"
          end
          words << word
          word = ""
          next
        end

        # III
        if c == '(' || c == ')'
          # IV
          if c == '(' && word == "'"
            words << "'("
            word = ""
            next
          elsif word.strip != ""
            words << word
            words << ("" + c)
            word = ""
            next
          else
            words << ("" + c)
            word = ""
            next
          end
        end

        unless c == ' ' || c == '\n'
          word += c
        end

      end
    end
    return words
  end

  def parse(words : Array(String)) : Array(Node | Leaf)

    puts words
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
