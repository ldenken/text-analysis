module Derivational 
# find usr/rules/affixes/ -type f -exec rm {} \;
  #----------------------------------------------------------------------------#
  def Derivational.document(document)
    # 
    # 
    puts "Derivational"
    

    # Load prefix and suffixes into arrays
    filename = "usr/rules/prefix.rules"
    prefix = FileIO.fileToArray(filename, "")
    filename = "usr/rules/suffix.rules"
    suffix = FileIO.fileToArray(filename, "")

    document.each do |line|                                # each line
      aryPrefix_loaded = ""
      aryPrefix = []
      arySuffix_loaded = ""
      arySuffix = []
      fileLoaded = "x" 
      ruleString = ""

      line["NOR"].each_with_index do |word,index|      # each word
        if word.length > 3
          #Var.info("-> word", word)
          first = word[0..1]
          last = word[word.length-2..word.length-1]
          length = word.length
          #puts "-> #{word} first:#{first} last:#{last} length:#{length}"

          # build prefix array based on the first two character of the word if not already built
          if aryPrefix_loaded != first
            aryPrefix_loaded = first
            regExp = Regexp.new("\\A#{first}")
            #Var.info("-> regExp", regExp)
            aryPrefix = prefix.select { |e| e =~ regExp }
            #Var.info("aryPrefix", aryPrefix)
          end

          # build suffix array based on the last two character of the word if not already built
          if arySuffix_loaded != last
            arySuffix_loaded = last
            regExp = Regexp.new("#{last}\\z")
            #Var.info("-> regExp", regExp)
            arySuffix = suffix.select { |e| e =~ regExp }
          end

          # build affix regexp string array for word if regexp < word length
          affixRegExpString = []
          aryPrefix.each do |p|
            arySuffix.each do |s|
              if (p.length + s.length) < length
                regExpString = "\\A#{p}.*#{s}\\z"
                affixRegExpString << regExpString
                #puts "#{regExpString}"
              end
            end
          end
          #affixRegExpString.each { |e| puts "  #{e}" }

          # build prefix regexp string array for word if regexp < word length
          prefixRegExpString = []
          aryPrefix.each do |p|
            if (p.length + 1) < length
              regExpString = "\\A#{p}"
              prefixRegExpString << regExpString
              #puts "#{regExpString}"
            end
          end
          #prefixRegExpString.each { |e| puts "  #{e}" }

          # build suffix regexp string array for word if regexp < word length
          suffixRegExpString = []
          arySuffix.each do |s|
            if (s.length + 1) < length
              regExpString = "#{s}\\z"
              suffixRegExpString << regExpString
              #puts "#{regExpString}"
            end
          end
          #suffixRegExpString.each { |e| puts "  #{e}" }


          # Affixes
          if affixRegExpString.length > 0
            if line["RUL"][index] !~ /_/
              affixRegExpString.each do |r|
                regExp = Regexp.new(r)
                if word =~ regExp
                  ruleArray = r.split(".*")
                  replaceRegExpA = Regexp.new(ruleArray[0])
                  replaceRegExpB = Regexp.new(ruleArray[1])
                  tmpString = word.gsub(replaceRegExpA, "")
                  clipped = tmpString.gsub(replaceRegExpB, "")

                  clipped = word.gsub(replaceRegExpB, "")

                  ruleString = "#{ruleArray[0]}_#{ruleArray[1]}".gsub(/\\A|\\z/, "")
                  ruleFilename = "usr/rules/affixes/#{ruleArray[0][2]}/#{ruleString}.rules"
                  rulesHash = FileIO.fileToHash(ruleFilename, ",", 0)
                  rulesHash ||= {} # create rulesHash if not returned
                  if rulesHash && rulesHash.include?(word)
                    line["LEM"][index] = rulesHash[word][0]
                    line["RUL"][index] = rulesHash[word][2]
                    tmpNum = rulesHash[word][1].to_i
                    rulesHash[word][1] = tmpNum += 1
                  else
                    hshWNover = WN.over(word, 0)
                    if hshWNover.length > 0 && hshWNover["words"][0] != word
                      wnWord = hshWNover["words"][0]
                      line["LEM"][index] = wnWord
                      line["RUL"][index] = ruleString
                      rulesHash[word] = ["#{wnWord}", 1, "#{ruleString}"]
                    else
                      line["LEM"][index] = clipped
                      line["RUL"][index] = ruleString
                      rulesHash[word] = ["#{clipped}", 1, "#{ruleString}", "NEW"]
                      FileIO.log($logfile, "#{ruleFilename} #{ruleString} #{word}")
                    end 
                  end
                  FileIO.hashToFile(rulesHash, ",", ruleFilename, "w")
                  break
                end # if word =~ regExp
              end
            end # if line["RUL"][index] !~ /_/
          end # if affixRegExpString.length > 0

          # Suffixies
          if line["RUL"][index] !~ /_/
            suffixRegExpString.each do |r|
              regExp = Regexp.new(r)
              if word =~ regExp
                clipped = word.gsub(regExp, "")
                ruleString = "_#{r}".gsub(/\\A|\\z/, "")
                ruleFilename = "usr/rules/suffixies/#{ruleString}.rules"
                rulesHash = FileIO.fileToHash(ruleFilename, ",", 0)
                rulesHash ||= {} # create rulesHash if not returned
                if rulesHash.include?(word)
                  line["LEM"][index] = rulesHash[word][0]
                  line["RUL"][index] = rulesHash[word][2]
                  tmpNum = rulesHash[word][1].to_i
                  rulesHash[word][1] = tmpNum += 1
                else
                  hshWNover = WN.over(word, 0)
                  if hshWNover.length > 0 && hshWNover["words"][0] != word
                    wnWord = hshWNover["words"][0]
                    line["LEM"][index] = wnWord
                    line["RUL"][index] = ruleString
                    rulesHash[word] = ["#{wnWord}", 1, "#{ruleString}"]
                  else
                    line["LEM"][index] = clipped
                    line["RUL"][index] = ruleString
                    rulesHash[word] = ["#{clipped}", 1, "#{ruleString}", "NEW"]
                    FileIO.log($logfile, "#{ruleFilename} #{ruleString} #{word}")
                  end 
                end
                FileIO.hashToFile(rulesHash, ",", ruleFilename, "w")
                break
              end # if word =~ regExp
            end 
          end # if line["RUL"][index] !~ /_/


          # Prefixes
          if line["RUL"][index] !~ /_/
            prefixRegExpString.each do |r|
              regExp = Regexp.new(r)
              if word =~ regExp
                clipped = word.gsub(regExp, "")
                ruleString = "#{r}_".gsub(/\\A|\\z/, "")
                ruleFilename = "usr/rules/prefixes/#{ruleString}.rules"
                rulesHash = FileIO.fileToHash(ruleFilename, ",", 0)
                rulesHash ||= {} # create rulesHash if not returned
                if rulesHash.include?(word)
                  line["LEM"][index] = rulesHash[word][0]
                  line["RUL"][index] = rulesHash[word][2]
                  tmpNum = rulesHash[word][1].to_i
                  rulesHash[word][1] = tmpNum += 1
                else
                  hshWNover = WN.over(word, 0)
                  if hshWNover.length > 0 && hshWNover["words"][0] != word
                    wnWord = hshWNover["words"][0]
                    line["LEM"][index] = wnWord
                    line["RUL"][index] = ruleString
                    rulesHash[word] = ["#{wnWord}", 1, "#{ruleString}"]
                  else
                    line["LEM"][index] = clipped
                    line["RUL"][index] = ruleString
                    rulesHash[word] = ["#{clipped}", 1, "#{ruleString}", "NEW"]
                    FileIO.log($logfile, "#{ruleFilename} #{ruleString} #{word}")
                  end 
                end
                FileIO.hashToFile(rulesHash, ",", ruleFilename, "w")
                break
              end # if word =~ regExp
            end 
          end # if line["RUL"][index] !~ /_/




        end # if word.length > 3
        if line["LEM"][index] == ""
          line["LEM"][index] = word
        end
      end # line["NOR"].each_with_index do |word,index|

    end # document.each do |line|

    return document
  end # def Derivational.document(document)
end # Derivational




puts ""
#------------------------------------------------------------------------------#
__END__



=begin
      prefixRegExpString.each do |r|
        regExp = Regexp.new(r)
        if word =~ regExp
          puts "  #{r} (p)"
          break
        end
      end 
=end






      if line["RUL"][index] !~ /_/
        suffixRegExpString.each do |r|
          regExp = Regexp.new(r)
          if word =~ regExp
            clipped = word.gsub(regExp, "")

            if fileLoaded != ruleString
              ruleString = r.gsub(/\\A|\\z/, "")
              fileLoaded = ruleString
              ruleFilename = "usr/rules/#{r[0]}/suffixes_#{ruleString}.rules"
              rulesHash = doLoadRulesHash(ruleFilename)
            end

            if rulesHash.include?(word)
              line["LEM"][index] = rulesHash[word][0]
              line["RUL"][index] = rulesHash[word][2]
              tmpNum = rulesHash[word][1].to_i
              rulesHash[word][1] = tmpNum += 1
              doWriteHashArray(rulesHash, ruleFilename)
            else
              line["LEM"][index] = clipped
              line["RUL"][index] = ruleString
              rulesHash[word] = ["#{clipped}", 1, "#{ruleString}"]
              doWriteHashArray(rulesHash, ruleFilename)
            end # if rulesHash.include?(word)

            break
          end # if word =~ regExp
        end
      end # if line["RUL"][index] !~ /_/






