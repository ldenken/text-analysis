module Summarise


  #------------------------------------------------------------------------------#
  def Summarise.document(filename, document)
    #puts ""; print "-"*80; puts ""
    #puts "Summarise.document(document)"

    selectedRAWText = {}
    selectedLEMText = {}                # array for all RAW text
    selectedW5HText = {}                # array for all RAW text

    selectedRAWTitles = {}                 # array for titles RAW text
    selectedLEMTitles = {}                 # array for titles RAW text
    selectedW5HTitles = {}                 # array for titles RAW text

    aListTextRAW = []               # array for list sentences RAW text

    summaryMatrix = {}
    summaryMatrixCounts = {}
    summaryTextCounts = {}
    summaryBoW = {}            # hash of summary, normailsed (Bag of Words) 


    selectedBoW = {}                # hash of all text, normailsed (Bag of Words)

    selectedLineCount = 0
    selectedWordCount = 0
    selectedText = ""

    summaryLineCount = 0
    summaryWordCount = 0
    summaryText = ""
summaryTextBlob = ""
summaryTextLineScore = {}

#puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
#puts "0,    1,       2,          3,         4,        5,     6,   7,   8"

    # create SELECTED text arrays
    document.each_with_index do |line,index|
      selectedRAWText[index+1] = line["RAW"]
      selectedLEMText[index+1] = line["LEM"]
      selectedW5HText[index+1] = line["W5H"]      

      if line["INF"][7] == "h1" || line["INF"][7] == "h2" || line["INF"][7] == "h3"
        selectedRAWTitles[index+1] = line["RAW"]
        selectedLEMTitles[index+1] = line["LEM"]
        selectedW5HTitles[index+1] = line["W5H"]
      end
    end
    selectedLineCount = selectedLEMText.length

    # create Bag of Words SELECTED hash
    selectedLEMText.each do |k,v|
      v.each do |word|
        wordCount = 0
        if selectedBoW.has_key?(word) == true
          wordCount = selectedBoW[word]
          wordCount += 1
          selectedBoW[word] = wordCount
        else
          selectedBoW[word] = 1
        end
      end
      selectedWordCount = selectedWordCount + v.length
    end


    # Repetition Matrix
    # y axis ^ top to bottom, step through the sentences hash once as the sentence being analysed  
    # x axis > left to right, step through the sentences hash once for each time of the y axis
    yArray = []
    xArray = []
    y = selectedLEMText.keys[0]
    while y < (selectedLEMText.length + 1)
      yArray = selectedLEMText[y]
      x = selectedLEMText.keys[0]
      total = 0
      arrayCountsAndTotals = []
      while x < (selectedLEMText.length + 1)
        if x != y
          includeCount = 0
          xArray = selectedLEMText[x]
          xArray.each do |word|
            if word.length > 4    # length as a HACK to remove unwanted words *****
              if yArray.include?(word) 
                includeCount += 1 
              end
            end
          end
          arrayCountsAndTotals << includeCount
          total = total + includeCount
        else
          arrayCountsAndTotals << ""
        end
        x += 1
      end
      arrayCountsAndTotals << total
      summaryMatrix[y] = arrayCountsAndTotals
      y += 1
    end
    summaryMatrix.each do |k,v|
      summaryMatrixCounts[k] = v[(selectedLEMText.length)]
    end

    matrixText = ""
    spaces = 0
    block = selectedLEMText.length.to_s.length + 1
    matrixText << " ".ljust(block)
    (selectedLEMText.length).times do |e|
      matrixText << "#{e+1}".ljust(block)
    end
    matrixText << "\n"
    summaryMatrix.each do |k,v| 
      spaces = block - k.to_s.length
      matrixText << "#{k}".ljust(block)
      v.each do |e| 
        matrixText << "#{e}".ljust(block)
      end
      matrixText << "\n"
    end


    # create summary text
    wordCount = 0
    summaryMatrixCounts.sort_by {|k,v| v}.reverse.each do |k,v|
      if wordCount < selectedWordCount/3 # divide by 3 HACK 
        tmpArray = selectedLEMText[k-1]
        if tmpArray && tmpArray.length >= 1
          summaryTextLineScore[k] = v
          wordCount = wordCount + tmpArray.length
          summaryTextCounts[k] = tmpArray.length
        end
        #if selectedLEMTitles.include?(selectedLEMText[k-1]) == false # exclude titles from summirisation text
        #  if aListTextRAW.include?(selectedLEMText[k-1]) == false # exclude ordered/unordered list text
        #  end
        #end
      end
    end
    summaryLineCount = summaryTextCounts.length

    summaryTextCounts.sort_by {|k,v| k}.each do |k,v|
      tmpArray = []
      tmpArray = selectedLEMText[k]
      tmpArray.each do |word|
#        if word.length > 4    # length as a HACK to remove unwanted words ******
          wordCount = 0
          if summaryBoW.has_key?(word) == true
            wordCount = summaryBoW[word]
            wordCount += 1
            summaryBoW[word] = wordCount
          else
            summaryBoW[word] = 1
          end
#        end
      end
      summaryWordCount = summaryWordCount + tmpArray.length
    end

    # Create SELECTED text for output
    selectedRAWText.each do |k,v|
      selectedText << "[#{k}/#{summaryMatrixCounts[k]}]"
      v.each {|e| selectedText << " #{e}"}
      selectedText << "\n"
    end

    # Create SUMMARY text for output
    summaryTextLineScore.sort_by {|k,v| k}.each do |k,v|
      summaryText << "[#{k}/#{v}]"
      selectedRAWText[k].each {|w| summaryText << " #{w}"}
      summaryText << "\n"      
      selectedRAWText[k].each {|w| summaryTextBlob << "#{w} "}
    end

    tmpStr = ""
    tmpStr << "Summary Blob:\n"
    tmpStr << "#{summaryTextBlob}\n\n"
    tmpStr << "\n\n"

    tmpStr << "Selected Text:\n"
    tmpStr << "#{selectedText}\n"
    tmpStr << "lines: #{selectedLineCount} words: #{selectedWordCount}\n\n"
    tmpStr << "Selected BoW: #{selectedBoW.length}\n"
    selectedBoW.sort_by {|k,v| v}.reverse.each {|k,v| tmpStr << "#{k}(#{v}) "}
    tmpStr << "\n\n"
    tmpStr << "Matrix:\n"
    tmpStr << "#{matrixText}\n"
    tmpStr << "lines: #{summaryLineCount} words: #{summaryWordCount}\n"
    tmpStr << "line/scores: "; summaryTextLineScore.sort_by {|k,v| k}.each {|k,v| tmpStr << "#{k}/#{v} "}
    tmpStr << "\n\n"
    tmpStr << "Summary Text:\n"
    tmpStr << "#{summaryText}\n\n"
    tmpStr << "Summary BoW: #{summaryBoW.length}\n"
    summaryBoW.sort_by {|k,v| v}.reverse.each {|k,v| tmpStr << "#{k}(#{v}) "}
    tmpStr << "\n\n"
    outputFilename = filename.gsub(".txt", ".sum")
#    puts "output : #{outputFilename}"
    FileIO.string(outputFilename, tmpStr, "w")
    
    #puts "#{tmpStr}"

    puts "\nSummary Blob:\n"
    summaryTextLineScore.sort_by {|k,v| k}.each do |k,v|
      selectedRAWText[k].each_with_index do |w,i| 
        if selectedW5HText[k][i] != "" 
          case selectedW5HText[k][i]
          when "blue"
            print "#{w}".blue
          when "green"
            print "#{w}".green
          when "red"
            print "#{w}".red
          when "brown"
            print "#{w}".brown
          when "cyan"
            print "#{w}".cyan
          when "magenta"
            print "#{w}".magenta
          end
        else
          print "#{w}"
        end
        print " "
      end
    end
    puts "\n\n"
    puts "                 WHO".blue + " -> " + "WHAT".green + " -> " + "WHERE".red + " -> " + "WHEN".brown + " -> " + "HOW".cyan + " -> " + "WHY".magenta
    puts ""

  	return document
  end # 
  
  
end # module Summarise
