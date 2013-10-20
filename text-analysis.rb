#!/usr/bin/ruby
require 'rubygems'
require 'digest'

require_relative 'lib/colour'
require_relative 'lib/derivational'
require_relative 'lib/fileio'
require_relative 'lib/inflectional'
require_relative 'lib/normalise'
#require_relative 'lib/summarise'
require_relative 'lib/var'
require_relative 'lib/w5h'
require_relative 'lib/wn'
require_relative 'lib/pos'

@column = 14

=begin

=end

#----------------------------------------------------------------------------#
def textArrays(rawArray)
  #puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
  #puts "0,    1,       2,          3,         4,        5,     6,   7,   8"

  # create HTML and ary files
  i = 0                             # loop iterator 
  l = rawArray.length - 1   # raw text length
  t = rawArray.clone        # clone of the raw text array
  textArrayHTML = []            # for html text
  textArrayPARSE = []           # for parsed text
  parseLineArray = []               # for parsed line
  section = 0                       # text section counter based on h2 tags
  subsection = 0 
  paragraph = 0                     # text paragraph counter
  sentence = 0                      # text sentence counter
  b = 1                             # begining character counter
  e = 0                             # end character counter
  listSwitch = 0                    # html list tag switch, for end tag
  listTag = ""

  while i <= l # loop through the rawArray array
    writeLine = 0
    # h1 title on the first line of the text
    if i == 0 
      h1test = "|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|#{t[i+2].codepoints[0]}|"
      if h1test =~ /\A\|[0-9]{2,3}\|\|\|/               # h1 tag, |text|blank|blank|
        writeLine = 1
        tag = "h1"
        section += 1
        subsection += 1
        e = b + (t[i].length - 1)
        parseLineArray = [i+1, section, subsection, 0, 0, b, e, tag, t[i]]
        textArrayPARSE << parseLineArray
        b = (e + 1)
        textArrayHTML << "<#{tag}>#{t[i]}</#{tag}>" #puts "<#{tag}>#{t[i]}</#{tag}>"
      end
    end

    if t[i].length >= 1 && i >= 3 && i <= (l - 2)     # line not blank and enough lines for test 
      if writeLine == 0
        test = "|#{t[i-2].codepoints[0]}|#{t[i-1].codepoints[0]}|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|#{t[i+2].codepoints[0]}|"
        if test =~ /\|\|\|[0-9]{2,3}\|\|\|/           # h2 tag, |blank|blank|text|blank|blank|
          if t[i][(t[i].length-1)] !~ /[\.|\!|\?\:]/  # NOT ending with .!?:
            writeLine = 1
            tag = "h2"
            section += 1
            subsection += 1
            e = b + (t[i].length - 1)
            parseLineArray = [i+1, section, subsection, 0, 0, b, e, tag, t[i]]
            textArrayPARSE << parseLineArray
            b = (e + 1)
            textArrayHTML << "<#{tag}>#{t[i]}</#{tag}>"   #puts "<#{tag}>#{t[i]}</#{tag}>"
          end
        end
      end

      if writeLine == 0
        test = "|#{t[i-1].codepoints[0]}|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|"
        if test =~ /\|\|[0-9]{2,3}\|\|/               # h3 tag, |blank|text|blank|
          if t[i][(t[i].length-1)] !~ /[\.|\!|\?\:]/ && t[i] !~ /\A\:\~\$/   # NOT ending with .!?:
            writeLine = 1
            tag = "h3"
            subsection += 1
            e = b + (t[i].length - 1)
            parseLineArray = [i+1, section, subsection, 0, 0, b, e, tag, t[i]]
            textArrayPARSE << parseLineArray
            b = (e + 1)
            textArrayHTML << "<#{tag}>#{t[i]}</#{tag}>"   #puts "<#{tag}>#{t[i]}</#{tag}>"
          end
        end
      end

      # ul or ol and p start tag, 
      if writeLine == 0 && listSwitch == 0
        if t[i][(t[i].length-1)] =~ /[\:]/            # line ends with :
          writeLine = 1
          paragraph += 1
          #          sentence += 1
          e = b + (t[i].length - 1)
          listTag = "ul"                              # un-ordered
          if t[i+1][(t[i+1].length-1)] =~ /[\;]/      # next line ends with ;
            listTag = "ol"                            # ordered
          end
          listSwitch = 1

          tag = "p"
          wordsArray = t[i].split(" ")
          sentencesArray = doSentences(wordsArray)
          tmp = "<p>"                                 #puts "<p>"
          temp = ""
          sentencesArray.each do |s|
            if s.length >= 1
              temp = ""
              s.each do |words|
                tmp << "#{words} "
                temp << "#{words} "
              end
              sentence += 1
              e = b + (temp.length - 1)
              parseLineArray = [i+1, section, subsection, paragraph, sentence, b, e, tag, temp.strip]
              textArrayPARSE << parseLineArray
              b = (e + 1)
            end
          end
          textArrayHTML << "#{tmp}<#{listTag}>" #puts "#{tmp}<#{listTag}>"
        end
      end

      # li tag, 
      if writeLine == 0 && listSwitch == 1
        test = "|#{t[i+1].codepoints[0]}|"
        if test =~ /\|[0-9]{2,3}\|/                   # next line is NOT blank
          if t[i][(t[i].length-1)] =~ /[\.|\!|\?\;]/  # line ends with .!?;
            writeLine = 1
            sentence += 1
            e = b + (t[i].length - 1)
            tag = "li"
            parseLineArray = [i+1, section, subsection, paragraph, sentence, b, e, tag, t[i]]
            textArrayPARSE << parseLineArray
            b = (e + 1)
            textArrayHTML << "<#{tag}>#{t[i]}</#{tag}>" #puts "<#{tag}>#{t[i]}</#{tag}>"
          end
        end
      end

      # ul or ol end tag, 
      if writeLine == 0 && listSwitch == 1 #&& t[i] =~ /[\.]|[ ]\z/
        test = "|#{t[i+1].codepoints[0]}|"
        if test =~ /\|\|/                             # next line is blank
          if t[i][(t[i].length-1)] =~ /[\.|\!|\?]/    # line ends with .!?
            writeLine = 1
            sentence += 1
            e = b + (t[i].length - 1)
            tag = "li"
            listSwitch = 0
            parseLineArray = [i+1, section, subsection, paragraph, sentence, b, e, tag, t[i]]
            textArrayPARSE << parseLineArray
            b = (e + 1)
            textArrayHTML << "<#{tag}>#{t[i]}</#{tag}></#{listTag}></p>" #puts "<#{tag}>#{t[i]}</#{tag}></#{listTag}></p>"
          end
        end
      end

      # p tag, 
      if writeLine == 0 && listSwitch == 0
        test = "|#{t[i-1].codepoints[0]}|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|"
        if test =~ /\|\|[0-9]{2,3}\|\|/
          writeLine = 1
          tag = "p"
          wordsArray = t[i].split(" ")
          sentencesArray = doSentences(wordsArray)
          paragraph += 1
          tmp = "<p>"                                 #puts "<p>"
          #          temp = ""
          #puts "sentencesArray.length #{sentencesArray.length}"
          sentencesArray.each do |s|
            if s.length >= 1
              temp = ""
              s.each do |words|
                tmp << "#{words} "
                temp << "#{words} "
              end
              sentence += 1
              e = b + (temp.length - 1)
              #puts "temp |#{temp}|"
              #puts ""
              parseLineArray = [i+1, section, subsection, paragraph, sentence, b, e, tag, temp.strip]
              textArrayPARSE << parseLineArray
              b = (e + 1)
            end
          end
          tmp << "</p>"                               #puts "</p>"
          textArrayHTML << "#{tmp}"               #puts "#{tmp}"
        else
          writeLine = 1
          tag = "p"
          test = "|#{t[i-1].codepoints[0]}|#{t[i].codepoints[0]}|"
          if test =~ /\|\|[0-9]{2,3}\|/
            textArrayHTML << "<#{tag}>"           #puts "<#{tag}>"
          end
          textArrayHTML << "#{t[i]}<br>"          #puts "#{t[i]}"
          sentence += 1
          e = b + (t[i].length - 1)
          parseLineArray = [i+1, section, subsection, paragraph, sentence, b, e, tag, t[i]]
          textArrayPARSE << parseLineArray
          b = (e + 1)
          test = "|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|"
          if test =~ /\|[0-9]{2,3}\|\|/
            textArrayHTML << "</#{tag}>"          #puts "</#{tag}>"
          end
        end
      end # if writeLine == 0 && listSwitch == 0

      # display lines that where NOT parsed...
      if writeLine == 0
        puts "+ #{t[i]} - #{t[i][(t[i].length-1)]}"
      end

    end # if t[i].length >= 1 && i >= 3 && i <= (l - 2)
    i += 1
  end # while i <= l

  return textArrayHTML, textArrayPARSE
end # def textArrays(rawArray)

#----------------------------------------------------------------------------#
def doSentences(wordsArray)
  sentenceArray = []
  sentencesArray = []
  wordsArray.each do |word|
    if word =~ /[a-z0-9\]\)][\.|\!|\?]\z/ && word != "i.e." && word != "e.g." && word != "etc." # word with . or ! or ? or i.e.
      sentenceArray << word
      sentencesArray << sentenceArray
      sentenceArray = []
    else
      sentenceArray << word
    end
  end #
  sentencesArray << sentenceArray
  return sentencesArray
end



#------------------------------------------------------------------------------#
def doProcessFile(filename)
  fileArray = FileIO.fileToArray(filename, "")
  #Var.info("fileArray", fileArray)
  #puts "fileArray..."
  #fileArray.each {|e| puts "#{e}"}

  infoArray = FileIO.fileComments(filename, "")
  #Var.info("infoArray", infoArray)
  #puts "infoArray..."
  #infoArray.each {|e| puts "#{e}"}

  rawArray = Normalise.raw(fileArray)
  #Var.info("rawArray", rawArray)
  #puts "rawArray..."
  #rawArray.each {|e| puts "#{e}"}

  textArrayHTML, textArrayPARSE = textArrays(rawArray)

  # Build text array of line hashes containing arrays of words
  #puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
  #puts "0,    1,       2,          3,         4,        5,     6,   7,   8"
  # text -> line -> word

  puts "Building hashs"
  text = []

  textArrayPARSE.each do |e|
    line = {}

    # line information
    aryInfo = []
    8.times do |n|
      aryInfo << e[n]
    end
    aryInfo << Digest::MD5.hexdigest(e[8])
    tmpArray = filename.split("/")
    aryInfo << tmpArray.last.gsub(/\.[a-z]{3,}\z/,"")
    line["INF"] = aryInfo

    # line text
    tmpArray = []
    tmpArray = e[8].split(" ")
    lineLength = tmpArray.length
    line["RAW"] = tmpArray

    # create INDIVIDUAL OBJECT elements for each word in array
    tmpArray = []; lineLength.times {tmpArray << ""}; line["NOR"] = tmpArray
    tmpArray = []; lineLength.times {tmpArray << ""}; line["LEM"] = tmpArray
    tmpArray = []; lineLength.times {tmpArray << ""}; line["RUL"] = tmpArray
    tmpArray = []; lineLength.times {tmpArray << ""}; line["W5H"] = tmpArray
    tmpArray = []; lineLength.times {tmpArray << ""}; line["POS"] = tmpArray
    tmpArray = []; lineLength.times {tmpArray << ""}; line["DEP"] = tmpArray
    text << line 
  end
  #Var.info("text", text)

  text = Normalise.text(text)
  #Var.info("text", text)

  text = Inflectional.text(text)
  #Var.info("text", text)

  text = Derivational.text(text)
  #Var.info("text", text)

  text = Pos.text(filename, text)
  #Var.info("text", text)

  text = W5h.text(text)
  #Var.info("text", text)

  puts ""
  outputFilename = filename.gsub(".txt", ".html")
  puts "output : #{outputFilename}"
  FileIO.arrayToFile(textArrayHTML, "", outputFilename, "w")

  #outputFilename = filename.gsub(".txt", ".ary")
  #puts "output : #{outputFilename}"
  #FileIO.arrayToFile(textArrayPARSE, ",", outputFilename, "w")
  #Var.info("textArrayPARSE", textArrayPARSE)

  outputFilename = filename.gsub(".txt", ".hsh")
  puts "output : #{outputFilename}"

  infoArray << "summary_text\n"
  tmpHsh = {}
  tmpHsh["TXT"] = infoArray
  FileIO.hashToFile(tmpHsh, ",", outputFilename, "w")
  text.each_with_index do |e,i|
    FileIO.hashToFile(e, ",", outputFilename, "a")
  end
  puts ""

end # doProcessFile(filename)


def doFile(filename)
  puts "-"*80
  $logfile = "#{__FILE__}".gsub(".rb", ".log")
  puts "#{filename}".bold
  doProcessFile(filename)
end # def doFile(filename)


def doDir(directory)
  puts "-"*80
  $logfile = "#{__FILE__}".gsub(".rb", ".log")
  fileArray = []
  Dir.glob(directory + "*.txt") do |file|
    next if file == '.' or file == '..'
    fileArray << file
  end
  puts "#{directory}... #{fileArray.length}"
  fileArray.each_with_index do |filename,index| 
    puts "#{filename} #{index+1}/#{fileArray.length}".bold
    doProcessFile(filename)
  end
end # def doDir(directory)


#------------------------------------------------------------------------------#
invalid ="
Usage    : ruby #{__FILE__} filename.txt | dir/

"
if ARGV.size == 1
  case ARGV[0]
  when /\.txt\z/
    if FileIO.fileExists(ARGV[0], 0) == true
      doFile(ARGV[0])
    end
  when /\/\z/
    if FileIO.directoryExists(ARGV[0], 2) == true
      doDir(ARGV[0])
    end
  else
    puts "\nError".ljust(@column) + ": Not found! -> #{ARGV[0]}"
    puts "#{invalid}"
    exit(1)    
  end
else
  puts "#{invalid}"
  exit(1)
end

puts ""
#------------------------------------------------------------------------------#
__END__

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#puts "Summarise"
#text = Summarise.text(filename, text)

#------------------------------------------------------------------------------#
=begin
outputFilename = filename.gsub(".txt", ".sum")
text.each_with_index do |e,i|
  FileIO.hashToFile(e, ",", outputFilename, "a+")
end
puts "output : #{outputFilename}"
=end




puts ""
#------------------------------------------------------------------------------#
__END__


=begin
outputFilename = filename.gsub(".txt", ".nor")
puts "output : #{outputFilename}"
text.each_with_index do |line,index|
  tmpString = ""
  line["NOR"].each do |word|
    tmpString << "#{word} "
  end
  if index == 0
    FileIO.string(outputFilename, tmpString, "w")
  else
    FileIO.string(outputFilename, tmpString, "a")      
  end
end
=end

