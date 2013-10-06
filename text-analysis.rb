#!/usr/bin/ruby
require 'rubygems'
require 'digest'

require_relative 'lib/colour'
require_relative 'lib/derivational'
require_relative 'lib/fileio'
require_relative 'lib/inflectional'
require_relative 'lib/normalise'
require_relative 'lib/summarise'
require_relative 'lib/var'
require_relative 'lib/w5h'
require_relative 'lib/wn'

=begin

=end


#------------------------------------------------------------------------------#
if ARGV.size != 1
  puts "Usage: ruby #{__FILE__} [dir/file]"
  puts ""
  exit(1)
end
filename = ARGV[0]

fileArray = FileIO.fileToArray(filename, "")
#Var.info("fileArray", fileArray)
$logfile = "#{__FILE__}".gsub(".rb", ".log")
#Var.info("$logfile", $logfile)


#------------------------------------------------------------------------------#
rawArray = Normalise.raw(fileArray)
#Var.info("rawArray", rawArray)


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

#----------------------------------------------------------------------------#
def documentArrays(rawArray)
  #puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
  #puts "0,    1,       2,          3,         4,        5,     6,   7,   8"

  # create HTML and ary files
  i = 0                             # loop iterator 
  l = rawArray.length - 1   # raw document length
  t = rawArray.clone        # clone of the raw text array
  documentArrayHTML = []            # for html text
  documentArrayPARSE = []           # for parsed text
  parseLineArray = []               # for parsed line
  section = 0                       # document section counter based on h2 tags
  subsection = 0 
  paragraph = 0                     # document paragraph counter
  sentence = 0                      # document sentence counter
  b = 1                             # begining character counter
  e = 0                             # end character counter
  listSwitch = 0                    # html list tag switch, for end tag
  listTag = ""

  while i <= l # loop through the rawArray array
    writeLine = 0
    # h1 title on the first line of the document
    if i == 0 
      h1test = "|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|#{t[i+2].codepoints[0]}|"
      if h1test =~ /\A\|[0-9]{2,3}\|\|\|/               # h1 tag, |text|blank|blank|
        writeLine = 1
        tag = "h1"
        section += 1
        subsection += 1
        e = b + (t[i].length - 1)
        parseLineArray = [i+1, section, subsection, 0, 0, b, e, tag, t[i]]
        documentArrayPARSE << parseLineArray
        b = (e + 1)
        documentArrayHTML << "<#{tag}>#{t[i]}</#{tag}>" #puts "<#{tag}>#{t[i]}</#{tag}>"
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
            documentArrayPARSE << parseLineArray
            b = (e + 1)
            documentArrayHTML << "<#{tag}>#{t[i]}</#{tag}>"   #puts "<#{tag}>#{t[i]}</#{tag}>"
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
            documentArrayPARSE << parseLineArray
            b = (e + 1)
            documentArrayHTML << "<#{tag}>#{t[i]}</#{tag}>"   #puts "<#{tag}>#{t[i]}</#{tag}>"
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
              documentArrayPARSE << parseLineArray
              b = (e + 1)
            end
          end
          documentArrayHTML << "#{tmp}<#{listTag}>" #puts "#{tmp}<#{listTag}>"
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
            documentArrayPARSE << parseLineArray
            b = (e + 1)
            documentArrayHTML << "<#{tag}>#{t[i]}</#{tag}>" #puts "<#{tag}>#{t[i]}</#{tag}>"
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
            documentArrayPARSE << parseLineArray
            b = (e + 1)
            documentArrayHTML << "<#{tag}>#{t[i]}</#{tag}></#{listTag}></p>" #puts "<#{tag}>#{t[i]}</#{tag}></#{listTag}></p>"
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
              documentArrayPARSE << parseLineArray
              b = (e + 1)
            end
          end
          tmp << "</p>"                               #puts "</p>"
          documentArrayHTML << "#{tmp}"               #puts "#{tmp}"
        else
          writeLine = 1
          tag = "p"
          test = "|#{t[i-1].codepoints[0]}|#{t[i].codepoints[0]}|"
          if test =~ /\|\|[0-9]{2,3}\|/
            documentArrayHTML << "<#{tag}>"           #puts "<#{tag}>"
          end
          documentArrayHTML << "#{t[i]}<br>"          #puts "#{t[i]}"
          sentence += 1
          e = b + (t[i].length - 1)
          parseLineArray = [i+1, section, subsection, paragraph, sentence, b, e, tag, t[i]]
          documentArrayPARSE << parseLineArray
          b = (e + 1)
          test = "|#{t[i].codepoints[0]}|#{t[i+1].codepoints[0]}|"
          if test =~ /\|[0-9]{2,3}\|\|/
            documentArrayHTML << "</#{tag}>"          #puts "</#{tag}>"
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

  return documentArrayHTML, documentArrayPARSE
end # def documentArrays(rawArray)


documentArrayHTML, documentArrayPARSE = documentArrays(rawArray)

outputFilename = filename.gsub(".txt", ".html")
puts "\noutput : #{outputFilename}"
FileIO.arrayToFile(documentArrayHTML, "", outputFilename, "w")

outputFilename = filename.gsub(".txt", ".ary")
puts "output : #{outputFilename}"
FileIO.arrayToFile(documentArrayPARSE, ",", outputFilename, "w")
#Var.info("documentArrayPARSE", documentArrayPARSE)





#------------------------------------------------------------------------------#
# Build document array of line hashes containing arrays of words
#puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
#puts "0,    1,       2,          3,         4,        5,     6,   7,   8"
# document -> line -> word

puts "Document"
document = []
documentArrayPARSE.each do |e|
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
  tmpArray = []; lineLength.times {tmpArray << ""}; line["POS"] = tmpArray
  tmpArray = []; lineLength.times {tmpArray << ""}; line["DEP"] = tmpArray
  tmpArray = []; lineLength.times {tmpArray << ""}; line["W5H"] = tmpArray
  
  document << line 
end
#Var.info("document", document)


puts "-"*80
document.each do |line|
  line.keys.each do |k|
    print "#{k}=#{line[k].length} "
  end
  puts ""
end
puts ""

#------------------------------------------------------------------------------#
puts "Normalise"
document = Normalise.document(document)
#Var.info("document", document)

outputFilename = filename.gsub(".txt", ".nor")
puts "output : #{outputFilename}"
document.each_with_index do |line,index|
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


#------------------------------------------------------------------------------#
puts "Inflectional"
document = Inflectional.document(document)
#Var.info("document", document)

#------------------------------------------------------------------------------#
puts "Derivational"
document = Derivational.document(document)
#Var.info("document", document)

#------------------------------------------------------------------------------#
puts "W5H"
document = W5h.document(document)
#Var.info("document", document)

#------------------------------------------------------------------------------#
puts "Summarise"
document = Summarise.document(filename, document)

#------------------------------------------------------------------------------#
=begin
outputFilename = filename.gsub(".txt", ".sum")
document.each_with_index do |e,i|
  FileIO.hashToFile(e, ",", outputFilename, "a+")
end
puts "output : #{outputFilename}"
=end

outputFilename = filename.gsub(".txt", ".hsh")
puts "output : #{outputFilename}"
document.each_with_index do |e,i|
  if i == 0
    FileIO.hashToFile(e, ",", outputFilename, "w")
  else
    FileIO.hashToFile(e, ",", outputFilename, "a")
  end
end



puts ""
#------------------------------------------------------------------------------#
__END__



