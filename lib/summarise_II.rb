module Summarise_II

  @column = 14

  #----------------------------------------------------------------------------#
  def Summarise_II.createBoW(bow_excludes, text, key, regexp)
    hashBoW = {}
    regExp = Regexp.new(regexp)
    text.each do |line|
      (line[key].length).times do |i|
        if line[key][i] =~ regExp
          if bow_excludes.include?(line["LEM"][i]) == false
            token = line["LEM"][i]
            if hashBoW.has_key?(token) == true
              wordCount = hashBoW[token]
              wordCount += 1
              hashBoW[token] = wordCount
            else
              if token != ""
                hashBoW[token] = 1
              end
            end
          end
        end
      end
    end
    return hashBoW
    Var.info("hashBoW", hashBoW)
  end

  def Summarise_II.printBoW(hashBoW)
    width = 0
    hashBoW.sort_by {|k,v| v}.reverse.each do |k,v|
      width += (k.length + 5)
      if width > 75
        puts ""
        width = k.length
      end
      print "#{k}(#{v}) "
    end
    puts ""
  end

  def Summarise_II.printW5H(line)
    line["RAW"].each_with_index do |t,i|
      case line["W5H"][i]
      when "blue"
        print "#{t}".blue
      when "green"
        print "#{t}".green
      when "red"
        print "#{t}".red
      when "brown"
        print "#{t}".brown
      when "cyan"
        print "#{t}".cyan
      when "magenta"
        print "#{t}".magenta
      else
        print "#{t}"
      end
      print " "
    end
  end


  #puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
  #puts "0,    1,       2,          3,         4,        5,     6,   7,   8"

  #------------------------------------------------------------------------------#
  def Summarise_II.text(filename, text)

    puts "-"*80

    titleCount = 0
    textTokenCount = 0
    text.each do |line|
      if line["INF"][7] == "h1" || line["INF"][7] == "h2" || line["INF"][7] == "h3"
        titleCount += 1
      end
      textTokenCount += line["LEM"].length
    end
    tmpInt = (textTokenCount.to_s.length + 1)
    infoBlock = ""
    infoBlock << "lines".ljust(@column)       + "#{(text.last["INF"][0].to_i - text.first["INF"][0].to_i) + 1}".ljust(tmpInt) + text.first["INF"][0]  + "-" + text.last["INF"][0] + "\n"
    infoBlock << "section".ljust(@column)     + "#{(text.last["INF"][1].to_i - text.first["INF"][1].to_i) + 1}".ljust(tmpInt) + text.first["INF"][1]  + "-" + text.last["INF"][1] + "\n"
    infoBlock << "subsection".ljust(@column)  + "#{(text.last["INF"][2].to_i - text.first["INF"][2].to_i) + 1}".ljust(tmpInt) + text.first["INF"][2]  + "-" + text.last["INF"][2] + "\n"
    infoBlock << "paragraphs".ljust(@column)  + "#{(text.last["INF"][3].to_i - text[1]["INF"][3].to_i) + 1}".ljust(tmpInt)    + text[1]["INF"][3]     + "-" + text.last["INF"][3] + "\n"
    infoBlock << "titles".ljust(@column)      + titleCount.to_s  + "\n"
    infoBlock << "sentences".ljust(@column)   + "#{(text.last["INF"][4].to_i - text[1]["INF"][4].to_i) + 1}".ljust(tmpInt)    + text[1]["INF"][4]     + "-" + text.last["INF"][4] + "\n"
    infoBlock << "words".ljust(@column)       + textTokenCount.to_s  + "\n"
    puts "#{infoBlock}"
    puts ""

    # create All Bag of Words hashes
    allBoW = {}
    bow_excludes = FileIO.fileToArray("usr/data/bow_excludes.lst", "")
    allBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "")
    #puts "All BoW...#{allBoW.length}"
    #Summarise_II.printBoW(allBoW)
    #puts ""

    # build all token repetition matrix...
    allTokenMatrix = {}
    allTokenCounts = {}
    lineCounter = 0
    loopCounter = text.length
    largestCount = 0
    while lineCounter <= (text.length - 1)
      #print "#{lineCounter} - "
      countsArray = []
      lineCount = 0
      loopCounter.times do |l|
        if l != lineCounter
          tokenCount = 0
          text[l]["LEM"].each do |token|
            if text[lineCounter]["LEM"].include?(token)
              tokenCount += 1
            end
          end
          #print "#{tokenCount} "
          countsArray << tokenCount
          lineCount += tokenCount
        else
          countsArray << ""
          #print "x "
        end
      end
      #print "(#{lineCount})"
      if largestCount < lineCount
        largestCount = lineCount
      end
      countsArray << lineCount
      allTokenMatrix[lineCounter] = countsArray
      allTokenCounts[lineCounter] = lineCount
      lineCounter += 1
      #puts ""
    end

    # create token repetition matrix
    matrixText = ""
    block = largestCount.to_s.length + 1
    #print "".ljust(block)
    matrixText << "".ljust(block)
    #allTokenMatrix.length.times {|n| print "#{n+1}".ljust(block)}
    allTokenMatrix.length.times {|n| matrixText << "#{n+1}".ljust(block)}

    allTokenMatrix.each do |k,v|
      #puts ""
      matrixText << "\n"
      #print "#{k+1}".ljust(block)
      matrixText << "#{k+1}".ljust(block)
      v.each_with_index do |e,i|
        if i == (v.length - 1)
          #print "- #{e}".ljust(block)
          matrixText << "- #{e}".ljust(block)
        else
          #print "#{e}".ljust(block)
          matrixText << "#{e}".ljust(block)
        end
      end
    end
    #puts "Repetition matrix..."
    #puts "#{matrixText}"
    #puts ""

    # line scores
    lineScoresText = ""
    allTokenCounts.sort_by {|k,v| v}.reverse.each {|k,v| lineScoresText << "#{k+1}/#{v} "}
    #puts "Line scores..."
    #puts "#{lineScoresText}"
    #puts ""

    # create summary line array
    summaryLineArrayAll = []
    summaryTokenCount = 0
    allTokenCounts.sort_by {|k,v| v}.reverse.each do |k,v|
      if summaryTokenCount < textTokenCount/3 # divide by 3 HACK
        summaryLineArrayAll << k
        summaryTokenCount += text[k]["RAW"].length
      end
    end
    summaryLineArrayAll.sort!
    summaryLineArrayAllText = ""
    summaryLineArrayAll.each {|e| summaryLineArrayAllText << "#{e} "}
    #puts "Summary line array... total tokens #{textTokenCount} / 3 = #{textTokenCount/3} min summary tokens"
    #puts "#{summaryLineArrayAllText}"
    #puts ""

    summaryText = ""
    summaryTokenCount = 0
    unless summaryLineArrayAll.include?(0)
      text[0]["RAW"].each do |t|
        summaryText << "#{t} "
        summaryTokenCount += 1
      end
      Summarise_II.printW5H(text[0])
    end
    summaryLineArrayAll.each do |n|
      text[n]["RAW"].each do |t|
        summaryText << "#{t} "
        summaryTokenCount += 1
      end
      Summarise_II.printW5H(text[n])
    end
    puts ""
    print "All Tokens... "
    print "lines: "
    summaryLineArrayAll.each {|e| print "#{e} "}
    print "(#{summaryLineArrayAll.length}) "
    print "tokens: #{summaryTokenCount}"
    puts "\n\n"
    #puts "#{summaryText}"

=begin
    rawText = ""
    text.each do |line|
      line["RAW"].each {|e| rawText << "#{e} "}
    end
    puts "Text..."
    puts "#{rawText}"
    puts ""
=end


#------------------------------------------------------------------------------#

    # Penn Tree Tagset
    penntreeBoW = {}
    penntreeBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "\\A[FJNV]")
    #puts "Penn Tree Tagset BoW...#{penntreeBoW.length}"
    #Summarise_II.printBoW(penntreeBoW)
    #puts ""

    tokenCounts = {}
    text.each_with_index do |line,index|
      tokenCounts[index] = 0
      line["LEM"].each do |token|
        if penntreeBoW.include?(token)
          #puts "#{index} #{token} "
          tokenCounts[index] += 1
        end
      end
    end

    # line scores
    lineScoresText = ""
    tokenCounts.sort_by {|k,v| v}.reverse.each {|k,v| lineScoresText << "#{k+1}/#{v} "}
    #puts "Line scores..."
    #puts "#{lineScoresText}"
    #puts ""

    # create summary line array
    summaryLineArrayTagged = []
    summaryTokenCount = 0
    tokenCounts.sort_by {|k,v| v}.reverse.each do |k,v|
      if summaryTokenCount < textTokenCount/3 # divide by 3 HACK
        summaryLineArrayTagged << k
        summaryTokenCount += text[k]["RAW"].length
      end
    end
    summaryLineArrayTagged.sort!
    summaryLineArrayTaggedText = ""
    summaryLineArrayTagged.each {|e| summaryLineArrayTaggedText << "#{e} "}
    #puts "Summary line array... total tokens #{textTokenCount} / 3 = #{textTokenCount/3} min summary tokens"
    #puts "#{summaryLineArrayTaggedText}"
    #puts ""

    summaryText = ""
    summaryTokenCount = 0
    unless summaryLineArrayTagged.include?(0)
      text[0]["RAW"].each do |t|
        summaryText << "#{t} "
        summaryTokenCount += 1
      end
      Summarise_II.printW5H(text[0])
    end
    summaryLineArrayTagged.each do |n|
      text[n]["RAW"].each do |t|
        summaryText << "#{t} "
        summaryTokenCount += 1
      end
      Summarise_II.printW5H(text[n])
    end
    puts ""
    print "Penn Tree Tagged... "
    print "lines: "
    summaryLineArrayTagged.each {|e| print "#{e} "}
    print "(#{summaryLineArrayTagged.length}) "
    print "tokens: #{summaryTokenCount}"
    puts "\n\n"
    #puts "#{summaryText}"


#------------------------------------------------------------------------------#

    # Concatenate All and Tagged summaries into one
    summaryLineArrayConcat = []
    summaryLineArrayConcat.concat(summaryLineArrayAll)
    summaryLineArrayConcat.concat(summaryLineArrayTagged)
    summaryLineArrayConcat.uniq!
    summaryLineArrayConcat.sort!

    summaryText = ""
    summaryTokenCount = 0
    unless summaryLineArrayConcat.include?(0)
      text[0]["RAW"].each do |t|
        summaryText << "#{t} "
        summaryTokenCount += 1
      end
      Summarise_II.printW5H(text[0])
    end
    summaryLineArrayConcat.each do |n|
      text[n]["RAW"].each do |t|
        summaryText << "#{t} "
        summaryTokenCount += 1
      end
      Summarise_II.printW5H(text[n])
    end
    puts ""
    print "Concatenated... "
    print "lines: "
    summaryLineArrayConcat.each {|e| print "#{e} "}
    print "(#{summaryLineArrayConcat.length}) "
    print "tokens: #{summaryTokenCount}"
    puts ""
    #puts "#{summaryText}"


    puts "\n\n"
    puts "                 WHO".blue + " -> " + "WHAT".green + " -> " + "WHERE".red + " -> " + "WHEN".brown + " -> " + "HOW".cyan + " -> " + "WHY".magenta
    puts ""






    w5hCounts = {}
    w5hTokens ={}
    text.each_with_index do |line,index|
      line["W5H"].each_with_index do |t,i|
        if t =~ /[a-z]/
          if w5hCounts.has_key?(index) == true
            tokenCount = w5hCounts[index]
            tokenCount += 1
            w5hCounts[index] = tokenCount
          else
            w5hCounts[index] = 1
          end
          if w5hTokens.has_key?(line["LEM"][i]) == true
            tokenCount = w5hTokens[line["LEM"][i]]
            tokenCount += 1
            w5hTokens[line["LEM"][i]] = tokenCount
          else
            w5hTokens[line["LEM"][i]] = 1
          end
        end
      end
    end
#Var.info("w5hCounts", w5hCounts)
#w5hCounts.sort_by {|k,v| v}.reverse.each {|k,v| print "#{k}/#{v} "}; puts""
#Var.info("w5hTokens", w5hTokens)
#w5hTokens.sort_by {|k,v| v}.reverse.each {|k,v| print "#{k}/#{v} "}; puts""
puts "W5H..."
Summarise_II.printBoW(w5hTokens)
puts ""



  end # def Summarise_II.text(filename, text)
end # module Summarise_II

puts ""
#------------------------------------------------------------------------------#
__END__

Var.info("selectedWordCount", selectedWordCount)


=begin
    # adjectives
    adjectivesBoW = {}
    adjectivesBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "\\AJJ")
    puts "Adjectives BoW...#{adjectivesBoW.length}"
    Summarise_II.printBoW(adjectivesBoW)
    puts ""

    # nouns
    nounsBoW = {}
    nounsBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "\\ANN")
    puts "Nouns BoW...#{nounsBoW.length}"
    Summarise_II.printBoW(nounsBoW)
    puts ""

    # adverbs
    adverbsBoW = {}
    adverbsBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "\\ARB")
    puts "Adverbs BoW...#{adverbsBoW.length}"
    Summarise_II.printBoW(adverbsBoW)
    puts ""

    # verbs
    verbsBoW = {}
    verbsBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "\\AVB")
    puts "Verbs BoW...#{verbsBoW.length}"
    Summarise_II.printBoW(verbsBoW)
    puts ""

    # Penn Tree Tagset
    penntreeBoW = {}
    penntreeBoW = Summarise_II.createBoW(bow_excludes, text, "POS", "\\A[FJNRV]")
    puts "Penn Tree Tagset BoW...#{penntreeBoW.length}"
    Summarise_II.printBoW(penntreeBoW)
    puts ""
=end