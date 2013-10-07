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

if ARGV.size == 2 && ARGV[0] =~ /[\-f|\-d]/ 
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
    puts ""
    print "#{__FILE__} "
    ARGV.each {|e| print "#{e} "}
    puts "\n\n"    
    puts "Usage: ruby #{__FILE__} -f|-d [file]|[dir]"
    puts ""
    exit(1)    
  end
else
  puts ""
  print "#{__FILE__} "
  ARGV.each {|e| print "#{e} "}
  puts "\n\n"
  puts "Usage: ruby #{__FILE__} -f|-d [file]|[dir]"
  puts ""
  exit(1)
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

  lastLineNumber = 0
  text.each do |line|

    # Run sentences into a paragraph and separate paragraphs from one another
    if lastLineNumber != line["INF"][0]
      puts "\n\n"
      lastLineNumber = line["INF"][0]
    end

    line["RAW"].each_with_index do |token,index|
      if line["W5H"][index] != ""
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
        end
      else
        print "#{token} "
      end
    end # line["RAW"].each_with_index do |token,index|

  end # text.each do |line|
  puts "\n\n"
  puts "".ljust(18) + "WHO".blue + " -> " + "WHAT".green + " -> " + "WHERE".red + " -> " + "WHEN".brown + " -> " + "HOW".cyan + " -> " + "WHY".magenta
  puts ""
end # fileAry.each do |file|




puts ""
#------------------------------------------------------------------------------#
__END__



    #puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
    #puts "0,    1,       2,          3,         4,        5,     6,   7,   8"
    

# ADD NEWLINES FOR TITLES AND PARAGRAPS, RUN TOGETHER PARAGRAPHS








penta = {}
fileAry.each do |filename|
  count = 0
  fileArray = FileIO.fileToArray(filename, "")
  lineArray = []
  fileArray.each do |line|
    lineArray << line.split(" ")
  end
  lineArray.each_with_index do |l,i|
    l.each_with_index do |word,index|
      if word == w
        count += 1
        id = Digest::MD5.hexdigest("#{l[index-2]} #{l[index-1]} #{word} #{l[index+1]} #{l[index+2]}")
        if penta.has_key?(id) == true
          tmpInt = penta[id][5]
          tmpInt += 1
          penta[id] = [l[index-2], l[index-1], word, l[index+1], l[index+2], tmpInt]
        else
          penta[id] = [l[index-2], l[index-1], word, l[index+1], l[index+2], 1]
        end
      end
    end
  end
  puts "#{filename} (#{count})"
end # fileAry.each do |filename|
puts "#{fileAry.length}"


col = 0
count = "#{penta.length}".length
#puts "#{count}"
penta.each do |k,v|
  tmpInt = v[0].length + v[1].length + count + 1
  if tmpInt > col
    col = tmpInt
  end
end


block = 0
penta.each do |k,v|
  puts ""
  print "#{v[5]}".rjust(count)
  space = col - block
  print "#{v[0]} #{v[1]} ".rjust(space) 
  print "#{v[2].bold}"
  print " #{v[3]} #{v[4]}"
end
puts ""
puts "#{penta.length}"
#Var.info("penta", penta)

=begin
puts ""
penta.each do |k,v|
  puts "#{v[0]} #{v[1]} #{v[2].bold} #{v[3]} #{v[4]}"
end
puts ""
puts "#{penta.length}"
=end



puts ""
#------------------------------------------------------------------------------#
__END__


=begin
puts ""
lineArray.each do |line|
  line.each_with_index do |word,index|
    print "#{word} "
  end
  puts ""
end
=end







Dir.foreach('.') do |item|
  next if item == '.' or item == '..'
  puts "#{item}"
  # do work on real items
end
puts ""

Dir.glob('*.rb') do |rb_file|
  # do work on files ending in .rb in the desired directory
  puts "#{rb_file}"
end
puts ""

Dir.glob('/Users/alexis/pdfs/identity_theft/*.nor') do |file|
  next if file == '.' or file == '..'
  puts "#{file}"
  # do work on real items
end
puts ""






puts ""
#------------------------------------------------------------------------------#
__END__



fileArray.each do |line|
  tmpString = "#{line[8]}"
  if line.length > 9
    x = line.length - 9
    x.times do |i|
      tmpString << "#{line[(x+8)]} "
    end
  end
  puts "#{tmpString}"
end
