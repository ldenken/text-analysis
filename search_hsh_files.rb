#!/usr/bin/ruby
require 'rubygems'
require 'digest'

require_relative 'lib/colour'
require_relative 'lib/fileio'
require_relative 'lib/var'

=begin

TODO
file or directory
word or consecutive words
don't colour punctuation 


=end


#------------------------------------------------------------------------------#
column = 14
fileAry = []
puts "-"*80

invalid ="
Usage: ruby #{__FILE__} -f|-d [file|dir] key [word |word]

"

if ARGV.size >= 2 && ARGV[0] =~ /[\-f|\-d]/ 
  case ARGV[0]
  when "-f"
    if FileIO.fileExists(ARGV[1], 1) == true
      fileAry << ARGV[1]
    end
  when "-d"
    if FileIO.directoryExists(ARGV[1], 1) == true
      Dir.glob(ARGV[1] + "*.hsh") do |file|
        next if file == '.' or file == '..'
        fileAry << file
      end
    end
  else
    puts "#{invalid}"
    exit(1)    
  end
else
  puts "#{invalid}"
  exit(1)    
end

w5hString = ""
w5hString << "\n\n"
w5hString << "".ljust(18) + "WHO".blue + " -> " + "WHAT".green + " -> " + "WHERE".red + " -> " + "WHEN".brown + " -> " + "HOW".cyan + " -> " + "WHY".magenta
w5hString << "\n\n"

def printLine(line, key)
  line[key].each_with_index do |token,index|
    case line["W5H"][index]
    when "blue"
      print "#{token} ".blue
    when "green"
      print "#{token} ".green
    when "red"
      print "#{token} ".red
    when "brown"
      print "#{token} ".brown
    when "cyan"
      print "#{token} ".cyan
    when "magenta"
      print "#{token} ".magenta
    else
      print "#{token} "
    end
  end # line["RAW"].each_with_index do |token,index|      
end









fileAry.each do |file|
  puts "#{file.bold}"
  puts ""
  text = FileIO.loadHash(file, 1)

  #text[#]["INF"] = line, section, subsection, paragraph, sentence, begin, end, tag, text
  #text[#]["INF"] = 0,    1,       2,          3,         4,        5,     6,   7,   8
  puts "line(s)".ljust(column) + text.last["INF"][0]
  puts "section(s)".ljust(column) + text.last["INF"][1]
  puts "subsection(s)".ljust(column) + text.last["INF"][2]
  puts "paragraph(s)".ljust(column) + text.last["INF"][3]
  puts "sentence(s)".ljust(column) + text.last["INF"][4]
  words = 0
  text.each do |line|
    words += line["RAW"].length
  end
  puts "word(s)".ljust(column) + words.to_s


  if ARGV[2] =~ /[A-Z0-9]{3}/ && ARGV[3] =~ /[a-zA-Z0-9 ]/
    # keys
    key = ARGV[2]
    keys = text.last.keys
    tmpStr = ""
    keys.each do |e| 
      if e == key
        tmpStr << "(#{e}) "
      else
        tmpStr << "#{e} "        
      end
    end
    puts "key(s)".ljust(column) + "#{tmpStr}"
    # search 
    search = ARGV[3]
    if ARGV[4]
      search = "#{ARGV[3]} #{ARGV[4]}"
    end
    puts "search".ljust(column) + search

    if search =~ /[ ]/
      text.each do |line|
        line[key].each_with_index do |token,index|
          if token == ARGV[3] && line[key][index+1] == ARGV[4]
            printLine(line, key)
            puts ""
          end
        end
      end
    else
      text.each do |line|
        if line[key].include?(search) == true
          printLine(line, key)
          puts ""
        end
      end
    end
  else
    w5hCounts = {}
    lastLineNumber = 0
    text.each do |line|
      # Run sentences into a paragraph and separate paragraphs from one another
      if lastLineNumber != line["INF"][0]
        puts "\n\n"
        lastLineNumber = line["INF"][0]
      end
      printLine(line, "RAW")
    end

  end # if ARGV[2] =~ /[A-Z0-9]{3}/ && ARGV[3] =~ /[a-zA-Z0-9 ]/

  puts "#{w5hString}"

end # fileAry.each do |file|



#------------------------------------------------------------------------------#
w5hBlueCounts = {}
w5hGreenCounts = {}
w5hRedCounts = {}
w5hBrownCounts = {}
w5hCyanCounts = {}
w5hMagentaCounts = {}
@lastToken = ""

def w5hCounts(line, hash, i, colour)
  tokens = ""
  5.times do |n|
    if line["W5H"][i+n] == colour 
      if line["RAW"][i+n] =~ /[\,]\z/
        tokens << " #{line["NOR"][i+n]}"
        break
      else
        tokens << " #{line["NOR"][i+n]}"          
      end
    else
      break
    end
  end
  tokens.strip!

  tmpAry = tokens.split(" ")
  if @lastToken != tmpAry.last
    if hash.has_key?(tokens) == true
      wordCount = hash[tokens]
      wordCount += 1
      hash[tokens] = wordCount
    else
      if tokens != ""
        hash[tokens] = 1
      end
    end    
  end
  @lastToken = tmpAry.last
  return hash
end


def printCountsHash(hash, num)
  if num == 0
    amount = hash.length
  else
    amount = (hash.length / num)    
  end

  count = 0
  width = 0
  hash.sort_by {|k,v| v}.reverse.each do |k,v|
    width += (k.length + 5)
    if width > 75
      puts ""
      width = k.length
    end 
    print "#{k}(#{v}) "
    count += 1
    if count >= amount
      break
    end
  end
  puts ""
end

fileAry.each do |file|
  text = FileIO.loadHash(file, 1)
  text.each do |line|
    (line["W5H"].length).times do |i|
      if line["W5H"][i] =~ /[a-z]/
        case line["W5H"][i]
        when "blue"
          w5hCounts(line, w5hBlueCounts, i, "blue")
        when "green"
          w5hCounts(line, w5hGreenCounts, i, "green")
        when "red"
          w5hCounts(line, w5hRedCounts, i, "red")
        when "brown"
          w5hCounts(line, w5hBrownCounts, i, "brown")
        when "cyan"
          w5hCounts(line, w5hCyanCounts, i, "cyan")
        when "magenta"
          w5hCounts(line, w5hMagentaCounts, i, "magenta")
        end
      end
    end
  end
end

puts "WHO".blue
printCountsHash(w5hBlueCounts, 0)
puts "WHAT".green
printCountsHash(w5hGreenCounts, 0)
puts "WHERE".red
printCountsHash(w5hRedCounts, 0)
puts "WHEN".brown
printCountsHash(w5hBrownCounts, 0)
puts "HOW".cyan
printCountsHash(w5hCyanCounts, 0)
puts "WHY".magenta
printCountsHash(w5hMagentaCounts, 0)


#------------------------------------------------------------------------------#
tmpAry = FileIO.fileToArray("usr/data/bow_excludes.lst", "")
nounsBoW = {}
fileAry.each do |file|
  text = FileIO.loadHash(file, 1)
  text.each do |line|
    (line["POS"].length).times do |i|
      if line["POS"][i] =~ /\ANN/
        if tmpAry.include?(line["NOR"][i]) == false 
          token = line["NOR"][i]
          if nounsBoW.has_key?(token) == true
            wordCount = nounsBoW[token]
            wordCount += 1
            nounsBoW[token] = wordCount
          else
            if token != ""
              nounsBoW[token] = 1
            end
          end    
        end
      end
    end
  end
end
divide = 10
puts "Nouns BoW...#{nounsBoW.length}/#{divide}=#{(nounsBoW.length/divide)}"
printCountsHash(nounsBoW, divide)


#------------------------------------------------------------------------------#
pharseBoW = {}
bow_excludes = FileIO.fileToArray("usr/data/bow_excludes.lst", "")
def bowHash(bow_excludes, hash, token)
  if bow_excludes.include?(token) == false 
    if hash.has_key?(token) == true
      wordCount = hash[token]
      wordCount += 1
      hash[token] = wordCount
    else
      if token != ""
        hash[token] = 1
      end
    end    
  end
  return hash
end

fileAry.each do |file|
  text = FileIO.loadHash(file, 1)
  text.each do |line|

    (line["NOR"].length).times do |i|
      if line["DEP"][i] =~ /root/
        #print "#{line["NOR"][i]} ".bold
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /subj/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /obj/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /nn/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /attr/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /amod|advmod/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /conj/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
      if line["DEP"][i] =~ /comp/
        #print "#{line["NOR"][i]} "
        pharseBoW = bowHash(bow_excludes, pharseBoW, line["NOR"][i])
      end
    end
  end
end
puts ""
divide = 10
puts "Pharse BoW...#{pharseBoW.length}/#{divide}=#{(pharseBoW.length/divide)}"
printCountsHash(pharseBoW, divide)


#------------------------------------------------------------------------------#
allBoW = {}
bow_excludes = FileIO.fileToArray("usr/data/bow_excludes.lst", "")
def allBoWHash(allBoW, bow_excludes, hash)
  hash.each do |key,value|
    if bow_excludes.include?(key) == false 
      if allBoW.has_key?(key) == true
        wordCount = allBoW[key]
        wordCount += value
        allBoW[key] = wordCount
      else
        allBoW[key] = value
      end
    end    
  end
end


allBoWHash(allBoW, bow_excludes, w5hBlueCounts)
allBoWHash(allBoW, bow_excludes, w5hGreenCounts)
allBoWHash(allBoW, bow_excludes, w5hRedCounts)
allBoWHash(allBoW, bow_excludes, w5hBrownCounts)
allBoWHash(allBoW, bow_excludes, w5hCyanCounts)
allBoWHash(allBoW, bow_excludes, w5hMagentaCounts)

allBoWHash(allBoW, bow_excludes, nounsBoW)
allBoWHash(allBoW, bow_excludes, pharseBoW)

puts ""
divide = 10
puts "All BoW...#{allBoW.length}/#{divide}=#{(allBoW.length/divide)}"
printCountsHash(allBoW, divide)






puts ""
#------------------------------------------------------------------------------#
__END__


