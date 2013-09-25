module W5h
  #

  # WHO.blue -> WHAT.green -> WHERE.red -> WHEN.brown -> HOW.cyan -> WHY.magenta
  
  def W5h.hashToArray(tmpHsh)
    tmpAry = []
    tmpHsh.each do |k,v|
#      tmpAry << k
      tmpAry << "#{v[0]}".downcase.gsub("'s", "")
      tmpAry << "#{v[1]}".downcase.gsub("'s", "")
      tmpAry.uniq!
      tmpAry.compact!
    end
    return tmpAry
  end

  #----------------------------------------------------------------------------#
  def W5h.who(document)
    # WHO
    # Firstnames
    print "  Firstnames..."
    tmpAry = FileIO.fileToArray("usr/data/firstname.lst", "")
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          if line["RAW"][index][0] =~ /\A[A-Z]/
            line["W5H"][index] = "blue"
          end
        end 
      end
    end

    # Lastname
    puts ""; print "  Lastname..."
    tmpAry = FileIO.fileToArray("usr/data/lastname.lst", "")
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          if line["RAW"][index][0] =~ /\A[A-Z]/
            line["W5H"][index] = "blue"
          end
        end 
      end
    end
    
    # Peoples
    puts ""; print "  Peoples..."
    tmpHsh = FileIO.fileToHash("usr/data/countries.hsh", ",", 0)
    tmpAry = []
    tmpHsh.each do |k,v|
      if v[4] =~ /[a-z]/
        tmpAry << "#{v[4]}".downcase
      end
    end
    tmpAry.uniq!
    tmpAry.compact!
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          line["W5H"][index] = "blue"
        end 
      end
    end

    # Companies
    puts ""; print "  Companies..."
    tmpHsh = FileIO.fileToHash("usr/data/companies.hsh", ",", 0)
    tmpAry = W5h.hashToArray(tmpHsh)
    tmpAry.each do |e|
      if e =~ /[ ]/
        split = e.split(" ")
        document.each do |line|
          print "."
          line["LEM"].each_with_index do |word,index|
            if word != "" && word == split[0]
              length = split.length
              test = false
              length.times do |i|
                if line["LEM"][index+i] == split[i]
                  test = true 
                else
                  test = false
                end
              end
              if test == true
                length.times do |i|
                  line["W5H"][index+i] = "blue"
                end
              end
            end
          end
        end
      else
        document.each do |line|
          print "."
          line["LEM"].each_with_index do |word,index|
            if word != "" && word == e
              line["W5H"][index] = "blue"
            end
          end
        end      
      end
    end
  end # def W5h.who(document)


  #----------------------------------------------------------------------------#
  def W5h.what(document)
    # WHAT
    # Things
    puts ""; print "  Things..."
    tmpHsh = FileIO.fileToHash("usr/data/things.hsh", ",", 0)
    tmpAry = W5h.hashToArray(tmpHsh)
    tmpAry.each do |e|
      if e =~ /[ ]/
        split = e.split(" ")
        document.each do |line|
          print "."
          line["LEM"].each_with_index do |word,index|
            if word != "" && word == split[0]
              length = split.length
              test = false
              length.times do |i|
                if line["LEM"][index+i] == split[i]
                  test = true 
                else
                  test = false
                end
              end
              if test == true
                length.times do |i|
                  line["W5H"][index+i] = "green"
                end
              end
            end
          end
        end
      else
        document.each do |line|
          print "."
          line["LEM"].each_with_index do |word,index|
            if word != "" && word == e
              line["W5H"][index] = "green"
            end
          end
        end      
      end
    end


  end # def W5h.what(document)
  

  #----------------------------------------------------------------------------#
  def W5h.where(document)
    # WHERE

    # Countries
    puts ""; print "  Countries..."
    tmpHsh = FileIO.fileToHash("usr/data/countries.hsh", ",", 0)
    tmpAry = W5h.hashToArray(tmpHsh)
    abbreviation = []
    tmpHsh.each do |k,v|
      if v[4] =~ /[A-Z]/
        abbreviation << "#{v[2]}"
      end
    end
    tmpAry.each do |e|
      if e =~ /[ ]/
        split = e.split(" ")
        document.each do |line|
          print "."
          line["NOR"].each_with_index do |word,index|
            if word != "" && word == split[0]
              length = split.length
              test = false
              length.times do |i|
                if line["NOR"][index+i] == split[i]
                  test = true 
                else
                  test = false
                end
              end
              if test == true
                length.times do |i|
                  line["W5H"][index+i] = "red"
                end
              end
            end
          end
        end
      else
        document.each do |line|
          print "."
          line["LEM"].each_with_index do |word,index|
            if word != "" 
              if word == e
                line["W5H"][index] = "red"
              end
              if abbreviation.include?(line["RAW"][index]) == true
                line["W5H"][index] = "red"
              end
            end
          end
        end      
      end
    end


    # Cities
    puts ""; print "  Cities..."
    tmpHsh = FileIO.fileToHash("usr/data/cities.hsh", ",", 0)
    # Var.info("tmpHsh", tmpHsh)
    tmpAry = W5h.hashToArray(tmpHsh)
    # Var.info("tmpAry", tmpAry)
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          line["W5H"][index] = "red"
        end 
      end
    end
    puts ""
  end #   


  #----------------------------------------------------------------------------#
  def W5h.when(document)
    # WHEN
    # Days
    print "  Days..."
    tmpAry = FileIO.fileToArray("usr/data/days.lst", "")
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          line["W5H"][index] = "brown"
        end
      end
    end

    # Months
    puts ""; print "  Months..."
    tmpAry = FileIO.fileToArray("usr/data/months.lst", "")
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          if line["RAW"][index][0] =~ /\A[A-Z]/
            line["W5H"][index] = "brown"
          end
        end
      end
    end

    # Numbers
    puts ""; print "  Numbers..."
    document.each do |line|
      print "."
      line["LEM"].each_with_index do |word,index|
        # time numbers -> 9am or 1pm
        if word =~ /\A[1-9]{1}[amp]{1,2}\z/ || word =~ /\A[1]{1}[012]{1}[amp]{1,2}\z/ 
          line["W5H"][index] = "brown"
        end
        # time numbers -> 9 am or 1 pm
        if word =~ /\A[amp]{1,2}\z/
          if word =~ /\A[1-9]{1}\z/ || word =~ /\A[1]{1}[012]{1}\z/ 
            line["W5H"][index] = "brown"
          end
        end
        # time numbers -> 0001 to 2359
        if word =~ /\A[0-9]{4}\z/ 
          if word.to_i >= 0001 && word.to_i <= 2359
            if word =~ /\A[012]{1}[0-9]{1}[012345]{1}[0-9]{1}\z/
              line["W5H"][index] = "brown"
            end
          end
        end
        # day numbers -> 9th or 1st
        if word =~ /\A[0-9]{1,2}[hst]{1,2}\z/ 
          line["W5H"][index] = "brown"
        end
        # day numbers -> 9 th or 1 st
        if word =~ /\A[hst]{1,2}\z/
          if word =~ /\A[0-9]{1,2}\z/ 
            line["W5H"][index] = "brown"
          end
        end
        # year numbers -> 1000 to 2999
        if word =~ /\A[0-9]{4}\z/ 
          if word.to_i >= 1900 && word.to_i <= 2359
            if word =~ /\A[12]{1}[0-9]{3}\z/
              line["W5H"][index] = "brown"
            end
          end
        end
        # daymonthyear numbers -> six digits, lessthan 311299, uk DDMMYY 01 12 03 
        if word =~ /\A[0-9]{6}\z/ 
          if word.to_i <= 311299
            if word =~ /\A[0123]{1}[0-9]{1}[01]{1}[0-9]{1}[0-9]{2}\z/ 
              line["W5H"][index] = "brown"
            end
          end
        end
        # daymonthyear numbers -> eight digits, lessthan 31122999, uk DDMMYYYY 01 12 2003
        if word =~ /\A[0-9]{8}\z/ 
          if word.to_i <= 31122999
            if word =~ /\A[0123]{1}[0-9]{1}[01]{1}[0-9]{1}[12]{1}[0-9]{3}\z/ 
              line["W5H"][index] = "brown"
            end
          end
        end
      end
    end



    puts ""
  end # def W5h.where(document)


  #----------------------------------------------------------------------------#
  def W5h.document(document)
    W5h.who(document)
    W5h.what(document)
    W5h.where(document)
    W5h.when(document)
    return document
  end #

end # module W5h
