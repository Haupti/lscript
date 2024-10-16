require "./tree.cr"
require "./token.cr"
require "./position.cr"
require "../error_utils.cr"

module PreParser
  extend self

  QUOTE_MARK = "quote"

  def parseWords(str : String) : Array(Token)

    words = [] of Token
    word = ""

    inString = false
    inComment = false
    row = 1
    col = 0
    str.chars.each do |c|
      col += 1

      if inComment && inString
        raise Err.bug("cannot be in comment and in string at the same time")
      end
      if c == '"' && !inComment
        inString = !inString
      end

      if inString
        word += c
      end

      unless inString
        # 0 semicolon start comment until end of line or until next semicolon
        # I quote end word and is added to next word
        # II whitespaces end words and are ignored
        # III brackets end words and are added as separate words
        # IV only special: quote before bracket is added as quoted bracket word : '(

        # 0
        if c == ';'
          inComment = !inComment;
          next
        end

        if inComment && c == '\n'
          row += 1
          col = 0
          inComment = false
          next
        elsif inComment
          next
        end

        # I
        if c == '\'' && word.strip != ""
          words << Token.new(word, Position.new(row, col - 1))
          word = "'"
          next
        elsif c == '\''
          word = "'"
          next
        end

        # II
        if (c == ' ' || c == '\n') && word.strip != ""
          if word == "'"
            raise Err.msgAt(Position.new(row, col), "standalone quotes are not allowed")
          end
          words << Token.new(word, Position.new(row, col - 1))
          word = ""
          if c == '\n'
            row += 1
            col = 0
          end
          next
        end

        # III
        if c == '(' || c == ')'
          # IV
          if c == '(' && word == "'"
            words << Token.new("'(", Position.new(row, col))
            word = ""
            next
          elsif word.strip != ""
            words << Token.new(word, Position.new(row, col - 1))
            words << Token.new(("" + c), Position.new(row,col))
            word = ""
            next
          else
            words << Token.new(("" + c), Position.new(row, col))
            word = ""
            next
          end
        end

        unless c == ' ' || c == '\n'
          word += c
        end
      end

      if c == '\n'
        row += 1
        col = 0
      end
    end
    return words
  end

  def parse(words : Array(Token)) : Array(Node | Leaf)
    nodes = [] of Node | Leaf

    hasQuote = false
    inBrackets = false
    brCounter = 0
    sectionWords = [] of Token
    words.each do |word|
      if word.value == "("
        inBrackets = true
        brCounter += 1
      elsif word.value == "'("
        if brCounter > 0
          inBrackets= true
          brCounter += 1
        else
          inBrackets= true
          brCounter += 1
          hasQuote = true
        end
      elsif word.value == ")"
        brCounter -= 1
      end

      if inBrackets && brCounter == 0
        if hasQuote
          sectionWords[1...1] = Token.new(QUOTE_MARK, word.position)
          hasQuote = false
        end
        inBrackets = false
        nodes.push Node.new(parse(sectionWords[1..-1]), word.position)
        sectionWords = [] of Token
      elsif inBrackets
        sectionWords.push word
      elsif !inBrackets
        nodes.push Leaf.new(word.value, word.position)
      end
    end
    unless brCounter == 0
      raise Err.msgAt(words[-1].position, "expected ')'")
    else
      return nodes
    end
  end

  def doParse(str : String) : Array(Node | Leaf)
    return parse(parseWords str)
  end
end
