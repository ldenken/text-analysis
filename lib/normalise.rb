module Normalise 

  #----------------------------------------------------------------------------#
  def Normalise.raw(fileArray)
    #
    #
    puts "Normalise raw"

    def Normalise.rules(fileArray, fileHash, filename, rule)
      fileHash.each do |k,v|
        regExp = Regexp.new("#{k}")
        fileArray.each do |line|
          if line != ""
            if line =~ regExp
              line.gsub!(regExp, "#{v[0]}")
              tmpNum = fileHash[k][1].to_i
              fileHash[k][1] = tmpNum += 1
            end
          end
        end
      end

      case rule
      when "@"
        fileArray.each do |line|
          regExp = Regexp.new("[a-zA-Z0-9\.\_\-]{1,}" + rule + "[a-zA-Z0-9\.\-]{1,}\.[a-zA-Z]{2,4}") # 
          if line =~ regExp 
            tmpStr = line.slice(regExp)
            tmpAry = tmpStr.split(" ")
            string = tmpAry[0]
            if fileHash.has_key?("#{string}") == false
              time = Time.new
              values = time.to_a
              fileHash[string] = [Time.utc(*values), 1]
            end
          end
          regExp = Regexp.new(rule + "[a-zA-Z0-9\_\-]{1,}") # twitter @XXX names
          if line =~ regExp 
            tmpStr = line.slice(regExp)
            tmpAry = tmpStr.split(" ")
            string = tmpAry[0]
            if fileHash.has_key?("#{string}") == false
              time = Time.new
              values = time.to_a
              fileHash[string] = [Time.utc(*values), 1]
            end
          end
        end        

      when "http"
        fileArray.each do |line|
          regExp = Regexp.new(rule + "[:\/a-zA-Z0-9\.\-\_]{1,}") # 
          if line =~ regExp
            tmpStr = line.slice(regExp)
#Var.info("tmpStr", tmpStr)
            tmpAry = tmpStr.split(" ")
            string = tmpAry[0]
            if fileHash.has_key?("#{string}") == false
              time = Time.new
              values = time.to_a
              fileHash[string] = [Time.utc(*values), 1]
            end
          end
        end        

        
      when "'"
        fileArray.each do |line|
          regExp = Regexp.new("[a-zA-Z0-9]{1,}" + rule + "[delmrtv]{1,}\z") # NOT 's
          if line =~ regExp
            tmpStr = line.slice(regExp)
            tmpAry = tmpStr.split(" ")
            string = tmpAry[0]
            if fileHash.has_key?("#{string}") == false
              fileHash[string] = [string, 1, "NEW"]
              #Var.info("NEW string", string)
            else
              #Var.info("-> string", string)
            end
          end
        end        

      else
        fileArray.each do |line|
          if line != ""
            regExp = Regexp.new("[a-zA-Z0-9]{1,}" + rule + "[ a-zA-Z0-9]{1,}")
            if line =~ regExp
              tmpStr = line.slice(regExp)
              tmpAry = tmpStr.split(" ")
              string = tmpAry[0]
              if fileHash.has_key?("#{string}") == false
                fileHash[string] = [string, 1, "NEW"]
                #Var.info("NEW string", string)
              else
                #Var.info("-> string", string)
              end
            end
          end
        end
      end

      FileIO.hashToFile(fileHash, ",", filename, "w")
      return fileArray
    end

    # email and twitter @handels 
    filename = "usr/rules/emailandats.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "@")

    # urls
    filename = "usr/rules/urls.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "http")

    # Ampersand
    filename = "usr/rules/ampersand.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "&")

    # Apostrophe FIX FOR NOT 's words
    filename = "usr/rules/apostrophe.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "'")

    # Hyphen
    filename = "usr/rules/hyphen.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "-")

    # Clipped
#    filename = "usr/rules/clipped.rules"
#    fileHash = FileIO.fileToHash(filename, ",", 0)
#    fileArray = Normalise.rules(fileArray, fileHash, filename, "")

    # Run together
    filename = "usr/rules/runtogether.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "")

    # Spelling
    filename = "usr/rules/spelling.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "")

    # Typo
    filename = "usr/rules/typo.rules"
    fileHash = FileIO.fileToHash(filename, ",", 0)
    fileArray = Normalise.rules(fileArray, fileHash, filename, "")

    return fileArray
  end # def Normalise.raw(fileArray)


  #----------------------------------------------------------------------------#
  def Normalise.text(text)
    # 
    # 
    puts "Normalise text"

    aryRules = [
      "[\!]",     # 0 ! exclamation mark
      "[\£]",     # 1 £ pound sign
      "[\$]",     # 2 $ dollar sign
      "[\%]",     # 3 % percent sign
      "[\']",     # 4 '      
      "[\*]",     # 5 * asterisk
      "[\_]",     # 6 _ low line
      "[\+]",     # 7 + plus sign
      "[\=]",     # 8 = equals sign
      "[\:]",     # 9 : colon
      "[\;]",     # 10 ; semicolon
      "[\"]",     # 11 " quotation mark
      "[\|]",     # 12 | vertical line
      "[\,]",     # 13 , comma
      "[\.]",     # 14 . full stop
      "[\?]",     # 15 ? question mark
      "[\/]",     # 16 / solidus
      "[\`]",     # 17 ` grave accent
      "[\~]",     # 18 ~ tilde
      "[\#]",     # 19 # number sign
      "[\\^]",    # 20 ^ circumflex accent
      "[\(|\)]",  # 21 () left and right parenthesis
      "[\{|\}]",  # 22 {} left and right curly brackets
      "[\<|\>]"   # 23 <> less-than and greater-than sign

    ] # aryRules

    text.each do |line|
      line["RAW"].each_with_index do |w,index|
        word = w.dup

        if word =~ /[A-Z]/ # replace - upercase with lowercase
          word.downcase!
          line["RUL"][index] << "d|"
          line["NOR"][index] = word
        end

        if word =~ /\[|\]|\\/ # ], [ and \ dont work in array
          line["RUL"][index] << "30|"
          line["NOR"][index] = word.gsub!(/\[|\]|\\/, "") 
        end

        if word =~ /\W/ # any non-word character
          aryRules.each_with_index do |rule,i|
            regExp = Regexp.new(rule)
            if word =~ regExp
              line["RUL"][index] << "#{i}|"
              line["NOR"][index] = word.gsub!(regExp, "") 
            end
          end
        end
        
        if line["NOR"][index] == ""
          line["NOR"][index] = word
        end

      end
    end 

  	return text
  end # def doNormaliseWord(style, hash)
end # module Normalise

