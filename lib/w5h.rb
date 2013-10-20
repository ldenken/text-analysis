module W5h
  #
  # 
  # WHO.blue -> WHAT.green -> WHERE.red -> WHEN.brown -> HOW.cyan -> WHY.magenta


  #----------------------------------------------------------------------------#
  def W5h.hashToArray(tmpHsh)
    acronyms = []
    strings = []
    tmpHsh.each do |k,v|
      if k =~ /\A[A-Z]{1,}\z/
        acronyms << k
      end
      strings << "#{v[0]}".downcase.gsub("'s", "")
      strings << "#{v[1]}".downcase.gsub("'s", "")
    end
    acronyms.uniq!
    acronyms.compact!
    strings.uniq!
    strings.compact!
    return acronyms, strings
  end


  #----------------------------------------------------------------------------#
  def W5h.findString(text, strings, colour)
    strings.each do |e|
      if e =~ /[ ]/ # multiple words in string
        split = e.split(" ")
#Var.info("split", split)

        text.each do |line|
          line["NOR"].each_with_index do |word,index|
            if word == split[0]
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
                  line["W5H"][index+i] = "#{colour}"
                end
              end
            end
          end
        end

      else

        text.each do |line|
          line["NOR"].each_with_index do |word,index|
            if line["W5H"][index] == ""
              if word == e
                line["W5H"][index] = "#{colour}"
              end
            end
          end
        end      
      end
    end
    return text
  end


  #----------------------------------------------------------------------------#
  def W5h.who(text)
    # WHO -> blue

    # Firstnames
    puts "  Firstnames..."
    tmpAry = FileIO.fileToArray("usr/data/firstname.lst", "")
    text.each do |line|
      line["NOR"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          if line["RAW"][index][0] =~ /\A[A-Z]/
            line["W5H"][index] = "blue"
          end
        end 
      end
    end

    titles = []
    titles << "Mr"
    titles << "Ms"
    titles << "Miss"
    titles << "Mrs"
    
    # Lastname
    puts "  Lastname..."
    tmpAry = FileIO.fileToArray("usr/data/lastname.lst", "")
    text.each do |line|
      line["NOR"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          if line["RAW"][index][0] =~ /\A[A-Z]/
            line["W5H"][index] = "blue"
          end
          if tmpAry.include?(line["RAW"][index-1]) == true
            line["RAW"][index-1] = "blue"
          end
        end 
      end
    end
    
    # Peoples
    puts "  Peoples..."
    tmpHsh = FileIO.fileToHash("usr/data/countries.hsh", ",", 0)
    tmpAry = []
    tmpHsh.each do |k,v|
      if v[3] =~ /[a-zA-Z]/
        tmpAry << "#{v[3]}".downcase
      end
    end

    tmpAry << "adults"
    tmpAry << "agencies"
    tmpAry << "banks"
    tmpAry << "businesses"
    tmpAry << "citizen"
    tmpAry << "citizens"
    tmpAry << "clients"
    tmpAry << "community"
    tmpAry << "companies"
    tmpAry << "company"
    tmpAry << "consumers"
    tmpAry << "hackers"
    tmpAry << "individuals"
    tmpAry << "institutions"
    tmpAry << "insurers"
    tmpAry << "investigators"
    tmpAry << "offices"
    tmpAry << "people"
    tmpAry << "personnel"
#    tmpAry << "spokesman"
#    tmpAry << "spokeswoman"
    tmpAry << "victims"
    tmpAry << "muslim"
    tmpAry << "lawmakers"


    
    tmpAry.uniq!
    tmpAry.compact!
    text.each do |line|
      line["NOR"].each_with_index do |word,index|
        if line["W5H"][index] == ""  
          if tmpAry.include?(word) == true
            line["W5H"][index] = "blue"
          end
        end 
      end
    end

    # Companies
    puts "  Companies..."
    tmpHsh = FileIO.fileToHash("usr/data/companies.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "blue")

    acronyms.each do |e|
      text.each do |line|
        line["RAW"].each_with_index do |word,index|
          if word != ""
            regExp = Regexp.new("#{e}.*")
            if word =~ regExp
              line["W5H"][index] = "blue"
            end
          end
        end
      end      
    end # acronyms.each do |e|

  end # def W5h.who(text)


  #----------------------------------------------------------------------------#
  def W5h.what(text)
    # WHAT -> green

    # Acronyms
    puts "  Acronyms..."
    tmpHsh = FileIO.fileToHash("usr/data/acronyms.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "green")
    acronyms.each do |e|
      text.each do |line|
        line["RAW"].each_with_index do |word,index|
          if word != ""
            regExp = Regexp.new("#{e}.*")
            if word =~ regExp
              line["W5H"][index] = "green"
            end
          end
        end
      end      
    end # acronyms.each do |e|

    # What Logical
    puts "  What Logical..."
    tmpHsh = FileIO.fileToHash("usr/data/what_logical.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "green")
    acronyms.each do |e|
      text.each do |line|
        line["RAW"].each_with_index do |word,index|
          if word != ""
            regExp = Regexp.new("#{e}.*")
            if word =~ regExp
              line["W5H"][index] = "green"
            end
          end
        end
      end      
    end #




    # Currency 
    puts "  Currency..."
    text.each do |line|
      line["RAW"].each_with_index do |word,index|
        # $ or £ and one to six digits with or without . or ,  
        if word =~ /\A[$|£][0-9\.\,]{1,6}\z/ 
          line["W5H"][index] = "green"
        end

        # daymonthyear numbers -> eight digits, lessthan 31122999, uk DDMMYYYY 01 12 2003
#        if word =~ /\A[0-9]{8}\z/ 
#          line["W5H"][index] = "green"
#        end
      end
    end


  end # def W5h.what(text)
  

  #----------------------------------------------------------------------------#
  def W5h.where(text)
    # WHERE -> red

    # Countries
    puts "  Countries..."
    tmpHsh = FileIO.fileToHash("usr/data/countries.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "red")

    acronyms.each do |e|
      text.each do |line|
        #print "."
        line["RAW"].each_with_index do |word,index|
          if line["W5H"][index] == ""
            regExp = Regexp.new("#{e}.*")
            if word =~ regExp
              line["W5H"][index] = "red"
            end
          end
        end
      end      
    end # acronyms.each do |e|

    # Regions
    puts "  Regions..."
    tmpHsh = FileIO.fileToHash("usr/data/regions.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "red")

    # Cities
    puts "  Cities..."
    tmpHsh = FileIO.fileToHash("usr/data/cities.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "red")

  end #   











  #----------------------------------------------------------------------------#
  def W5h.when(text)
    # WHEN -> brown

    # Days
    puts "  Days..."
    tmpAry = FileIO.fileToArray("usr/data/days.lst", "")
    text.each do |line|
      line["NOR"].each_with_index do |word,index|
        if word != "" && tmpAry.include?(word) == true
          line["W5H"][index] = "brown"
        end
      end
    end

    # Oct. 1 

    # Months
    puts "  Months..."

    tmpAry = FileIO.fileToArray("usr/data/months.lst", "")
    text.each do |line|
      line["NOR"].each_with_index do |token,index|
        if tmpAry.include?(token) == true
          if line["RAW"][index][0] =~ /\A[A-Z]/
            line["W5H"][index] = "brown"

            if line["NOR"][index-1] == "early" || line["RAW"][index-1] == "late"
              line["W5H"][index-1] = "brown"
            end

            # October 8, 2013 at 6:44 AM
            if line["NOR"][index+1] =~ /\A[0-9]{1,2}\z/ 
              if line["NOR"][index+2] =~ /\A[0-9]{4}\z/ 
                if line["NOR"][index+3] =~ /\Aat\z/ 
                  if line["NOR"][index+4] =~ /\A[0-9]{1,2}:[0-9]{1,2}\z/ 
                    if line["NOR"][index+5] =~ /\A[am|pm]\z/ 
                      line["W5H"][index+1] = "brown"
                      line["W5H"][index+2] = "brown"
                      line["W5H"][index+3] = "brown"
                      line["W5H"][index+4] = "brown"
                      line["W5H"][index+5] = "brown"
                    end
                  end
                end
              end
            end

            if line["NOR"][index-1] =~ /\A[0-9]{1,4}\z/ 
              line["W5H"][index-1] = "brown"
            end
            if line["NOR"][index+1] =~ /\A[0-9]{1,4}\z/ 
              line["W5H"][index+1] = "brown"
            end
          end
        end
      end
    end # text.each do |line|

    # Time
    puts "  Time..."
    text.each do |line|
      line["NOR"].each_with_index do |word,index|
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
        # year numbers -> 1900 to 2999
        if word =~ /\A[0-9]{4}\z/ 
          if word.to_i >= 1900 && word.to_i <= 2999
            if word =~ /\A[12]{1}[0-9]{3}\z/
              line["W5H"][index] = "brown"
            end
          end
        end
      end
    end

    text.each do |line|
      line["RAW"].each_with_index do |word,index|
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



    puts "  Date/Time Stamps..."
    text.each do |line|
      line["RAW"].each_with_index do |token,index|
        
        # 2013-10-10 07:06:25 UTC
        if token =~ /\A[0-9]{4}(-[0-9]{2}){2}\z/
          if line["RAW"][index+1] =~ /\A[0-9]{1,2}(:[0-9]{2}){2}\z/
            if line["RAW"][index+2] =~ /\AUTC\z/
              line["W5H"][index] = "brown"
              line["W5H"][index+1] = "brown"
              line["W5H"][index+2] = "brown"
            end
          end
        end

      end # line["RAW"].each_with_index do |token,index|
    end # text.each do |line|

    whenWords = []
    whenWords << "century"
    whenWords << "day"
    whenWords << "hour"
    whenWords << "night"
    whenWords << "year"
    whenWords << "years"
    whenWords << "this year"
    whenWords << "earlier this year"
    whenWords << "yesterday"
    whenWords << "month"
    whenWords << "this month"
    whenWords << "earlier this month"
    whenWords << "daily"
    whenWords << "weekly"

    accompanying = []
    accompanying << "every"
    accompanying << "few"
    accompanying << "last"
    accompanying << "mid"
    accompanying << "several"
    accompanying << "since"
    accompanying << "twice"
    accompanying << "earlier"
    accompanying << "one"
    accompanying << "two"
    accompanying << "three"
    accompanying << "four"
    accompanying << "five"
    accompanying << "six"
    accompanying << "seven"
    accompanying << "eight"
    accompanying << "nine"
    accompanying << "ten"

    # whenWords
    puts "  When Words..."
    text = W5h.findString(text, whenWords, "brown")

    text.each do |line|
      line["NOR"].each_with_index do |word,index|
        if line["W5H"][index] == "brown"
          if line["NOR"][index-1] =~ /\A[0-9]{1,2}\z/ 
            line["W5H"][index-1] = "brown"
          end
          accompanying.each do |e|
            if line["NOR"][index+1] == "#{e}" 
              line["W5H"][index+1] = "brown"
            end
            if line["NOR"][index-1] == "#{e}" 
              line["W5H"][index-1] = "brown"
            end
          end
        end
      end
    end

  end # def W5h.where(text)

  #----------------------------------------------------------------------------#
  def W5h.how(text)
    # HOW -> cyan

    # how Logical
    puts "  How Logical..."
    tmpHsh = FileIO.fileToHash("usr/data/how_logical.hsh", ",", 0)
    acronyms, strings = W5h.hashToArray(tmpHsh)
    text = W5h.findString(text, strings, "cyan")

=begin
    acronyms.each do |e|
      text.each do |line|
        print "."
        line["RAW"].each_with_index do |word,index|
          if word != ""
            regExp = Regexp.new("#{e}.*")
            if word =~ regExp
              line["W5H"][index] = "cyan"
            end
          end
        end
      end      
    end # acronyms.each do |e|
=end

  end # def W5h.how(text)


  #----------------------------------------------------------------------------#
  def W5h.text(text)
    W5h.who(text)
    W5h.what(text)
    W5h.where(text)
    W5h.when(text)
    W5h.how(text)
#    W5h.why(text)

    return text
  end #

end # module W5h
