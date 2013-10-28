#------------------------------------------------------------------------------#
=begin
"r"  Read-only, starts at beginning of file  (default mode).

"r+" Read-write, starts at beginning of file.

"w"  Write-only, truncates existing file
     to zero length or creates a new file for writing.

"w+" Read-write, truncates existing file to zero length
     or creates a new file for reading and writing.

"a"  Write-only, starts at end of file if file exists,
     otherwise creates a new file for writing.

"a+" Read-write, starts at end of file if file exists,
     otherwise creates a new file for reading and
     writing.
=end

require 'time'

module FileIO

=begin
  #----------------------------------------------------------------------------#
  def FileIO.errorAndExit(error, location)
    #
    column = 10
    puts ""
    puts "Location".ljust(column) + ": #{location}"
    puts "Error".ljust(column) + ": #{error}"
    puts ""
    exit(1)
  end

  #----------------------------------------------------------------------------#
  def FileIO.fileExists(filename, exit)
    #
    filetest = File.exist?(filename)
    if filetest == false
      if exit == 0
        puts "Error".ljust(10) + ": File not found! -> #{filename}"
      else
        error = "File not found!"
        location = "def FileIO.fileExists(#{filename}, #{exit})"
        FileIO.errorAndExit(error, location)
      end
    else
      filetest = true
    end
    return filetest
  end

  #----------------------------------------------------------------------------#
  def FileIO.directoryExists(directory, exit)
    #
    dirtest = File.directory?(directory)
    if dirtest == false
      if exit == 0
        puts "Error".ljust(10) + ": Directory not found! -> #{directory}"
      else
        error = "Directory not found!"
        location = "def FileIO.directoryExists(#{directory}, #{exit})"
        FileIO.errorAndExit(error, location)
      end
    else
      dirtest = true
    end
    return dirtest
  end
=end

  def FileIO.errorAndExit(error, location)
    puts ""
    puts "Location".ljust(@column) + ": #{location}"
    puts "Error".ljust(@column) + ": #{error}"
    puts ""
    exit(1)
  end

  def FileIO.fileExists(filename, exit)
    filetest = File.exist?(filename)
    if filetest == false
      case exit
      when 0
        # do nothing!
      when 1
        puts "Error".ljust(@column) + ": File not found! -> #{filename}"
      when 2
        error = "File not found!"
        location = "def fileExists(#{filename}, #{exit})"
        FileIO.errorAndExit(error, location)
      end
    else
      filetest = true
    end
    return filetest
  end

  def FileIO.directoryExists(directory, exit)
    dirtest = File.directory?(directory)
    if dirtest == false
      case exit
      when 0
        # do nothing!
      when 1
        puts "Error".ljust(@column) + ": Directory not found! -> #{directory}"
      when 2
        error = "Directory not found!"
        location = "def directoryExists(#{directory}, #{exit})"
        FileIO.errorAndExit(error, location)
      end
    else
      dirtest = true
    end
    return dirtest
  end





  #----------------------------------------------------------------------------#
  def FileIO.reduceUTF8String(string)
    #  £
    #
  	newString = ""
  	string.each_codepoint do |c|
      case
      when c >= 32 && c <= 95
        newString << c
      when c >= 97 && c <= 126
        newString << c
      when c == 96       # 96 -> ` -> 39 -> '
        newString << 39
      when c == 169      # 169 -> ©
        newString << c

      when c == 173      # 173 -> ­ -> 45 -> -
        newString << 45
      when c == 8212     # 8212 -> — -> 45 -> -
        newString << 45

      when c == 8217     # 8217 -> ’ -> 39 -> '
        newString << 39
      when c == 8220     # 8220 -> “ -> 34 -> "
        newString << 34
      else
        newString << 32
      end
  	end
  	return newString
  end

  #--------------------------------------------------------------------------#
  def FileIO.string(filename, string, flag)
    flag << ":UTF-8"
    begin
      file = File.open(filename, flag)
      file.write("#{string}\n")
    rescue IOError => error
      error = "#{error}"
      location = "def FileIO.string(#{filename}, #{string}, #{flag})"
      FileIO.errorAndExit(error, location)
    ensure
      file.close unless file == nil
    end
  end

  #--------------------------------------------------------------------------#
  def FileIO.log(filename, message)
    # 
    begin
      ts = Time.now.utc.iso8601
      file = File.open(filename, "a+")
      file.write("#{ts} #{message}\n")
    rescue IOError => error
      error = "#{error}"
      location = "def FileIO.log(#{filename}, #{message})"
      FileIO.errorAndExit(error, location)
    ensure
      file.close unless file == nil
    end
  end

  #----------------------------------------------------------------------------#
  def FileIO.fileToArray(filename, delimiter)
    # READ a file into an array of lines or an array of array lines split by the
    # delimiter that are not commented out by lines in-between lines begining
    # with =begin to =end block comments or lines begining with # line comment.
    if FileIO.fileExists(filename, 1) == true
      begin
        fileArray = []
        import = 1                              # import switch
        File.foreach(filename) do |line|
          line.strip!
          if line =~ /\A=[bdegin]{3,5}\z/
            if line == "=begin"                 # begin a comment block
              import = 2
            end
            if line == "=end"                   # end a comment block
              import = 1
            end
          end
          if line !~ /\A#/ && line !~ /\A=[bdegin]{3,5}\z/
            if import == 1                      # line NOT in a comment block
              line = FileIO.reduceUTF8String(line)
              if delimiter != ""
                lineArray = line.split("#{delimiter} ") # with or without space?
                fileArray << lineArray
              else
                fileArray << line
              end
            end
          end
        end
      rescue IOError => error
        error = "#{error}"
        location = "def FileIO.fileToArray(#{filename})"
        FileIO.errorAndExit(error, location)
      end
      return fileArray
    end
  end

  #--------------------------------------------------------------------------#
  def FileIO.arrayToFile(array, delimiter, outputFilename, flag)
    # WRITE an array to a file of lines or file of array lines split by the
    # delimiter.
    flag << ":UTF-8"
    begin
      file = File.open(outputFilename, flag)
      array.each do |line|
        if delimiter != ""
          lineString = ""
          line.each_with_index do |e,i|
            if i == (line.length - 1)
              lineString << "#{e}"
            else
              lineString << "#{e}#{delimiter} "
            end
          end
          file.write("#{lineString}\n")
        else
          file.write("#{line}\n")
        end
      end
    rescue IOError => error
      error = "#{error}"
      location = "def FileIO.arrayToFile(array, #{delimiter}, #{outputFilename}, #{flag})"
      FileIO.errorAndExit(error, location)
    ensure
      file.close unless file == nil
    end
  end

  #----------------------------------------------------------------------------#
  def FileIO.fileToHash(filename, delimiter, exit)
    # READ a file into an array of lines that are not commented out by
    # lines inbetween lines begining with =begin to =end, block comments
    # or lines begining with #, line comment.
    # Lines are split by = to provide the key/value pairs and value is split
    # by the delimiter to create an array for the value,
    # file format = key = value[0], value[1], value[2], etc...
    if FileIO.fileExists(filename, exit) == true
      begin
        fileHash = {}
        import = 1                            # import switch
        File.foreach(filename) do |line|
          line.strip!
          if line == "=begin"                 # begin a comment block
            import = 2
          end
          if line == "=end"                   # end a comment block
            import = 1
          end

          if line != ""
            if line !~ /\A#/
              if line != "=begin" 
                if line != "=end"
                  if import == 1
                    line = FileIO.reduceUTF8String(line)
                    lineArray = line.split("=")
                    key = lineArray[0].strip
                    if key != ""
                      value = lineArray[1].strip
                      valueArray = value.split("#{delimiter} ")
                      fileHash[key] = valueArray
                    end
                  end
                end
              end
            end
          end

        end
      rescue IOError => error
        error = "#{error}"
        location = "def FileIO.fileToHash(filename)"
        FileIO.errorAndExit(error, location)
      end
      return fileHash
    end
  end



  #--------------------------------------------------------------------------#
  def FileIO.hashToFile(hash, delimiter, outputFilename, flag)
    # WRITE an hash to a file of lines or file of array lines split by the
    # delimiter.
    # file format => key = value[0], value[1], value[2], etc...
    flag << ":UTF-8"
    begin
      file = File.open(outputFilename, flag)
      hash.each do |k,v|
        lineString = "#{k} = "
        v.each_with_index do |e,i|
          if i == (v.length - 1)
            lineString << "#{e}"
          else
            lineString << "#{e}#{delimiter} "
          end
        end
        file.write("#{lineString}\n")
      end
    rescue IOError => error
      error = "#{error}"
      location = "def FileIO.hashToFile(hash, #{delimiter}, #{outputFilename}, #{flag})"
      FileIO.errorAndExit(error, location)
    ensure
      file.close unless file == nil
    end
  end



  #----------------------------------------------------------------------------#
  def FileIO.loadHash(filename, exit)
    # file format = key = value[0], value[1], value[2], etc...
    if FileIO.fileExists(filename, exit) == true
      text = []   # document
      line = {}   # sentence(s)
      token = ""  # word
      info = {}   # text information
      fileArray = []
      begin
        File.foreach(filename) do |string|
          string.strip!
          fileArray << string
        end
      rescue IOError => error
        error = "#{error}"
        location = "def FileIO.loadHash(filename)"
        FileIO.errorAndExit(error, location)
      end

      fileArray.each do |string|
        key = string[/\A[A-Z0-9]{3}/]
        string.slice!(/\A[A-Z0-9]{3} \= /)
        # comma space used to split string to accommodate comma's in string!
        stringArray = string.split(", ")
        if key == "TXT"
          last_key = ""
          stringArray.each do |e|
            tmpAry = e.split(" : ")
            if tmpAry.length >= 2
              key = tmpAry[0].downcase
              info[key] = tmpAry[1]
              last_key = key
            else
              info[last_key] << ", #{tmpAry}"
            end
          end
        end

        if key == "INF" 
          line = {}
          line[key] = stringArray
          if line.length >= 1
            text << line
          end
        else
          line[key] = stringArray
        end
      end

      # Fix empty array length because no text before, after comma on import
      # i.e. RAW = I, cannot & NOR = i, cannot & POS = , & DEP = ,
      text.each do |line|
        line.keys.each do |k|
          if line[k].length < line["RAW"].length
            line[k] << ""
          end
        end
      end
      return info, text
    end
  end




  #----------------------------------------------------------------------------#
  def FileIO.fileComments(filename, delimiter)
    if FileIO.fileExists(filename, 1) == true
      begin
        fileArray = []
        import = 1                              # import switch
        File.foreach(filename) do |line|
          line.strip!
          if line =~ /\A=[bdegin]{3,5}\z/
            if line == "=begin"                 # begin a comment block
              import = 2
            end
            if line == "=end"                   # end a comment block
              import = 1
            end
          end
          if line !~ /\A#/ && line !~ /\A=[bdegin]{3,5}\z/
            if import == 2 && line != ""                      # line IS in a comment block
              #line = FileIO.reduceUTF8String(line)
              if delimiter != ""
                lineArray = line.split("#{delimiter} ") # with or without space?
                fileArray << lineArray
              else
                fileArray << line
              end
            end
          end
        end
      rescue IOError => error
        error = "#{error}"
        location = "def FileIO.fileToArray(#{filename})"
        FileIO.errorAndExit(error, location)
      end
      return fileArray
    end
  end



end # module FileIO

