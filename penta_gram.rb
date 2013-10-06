#!/usr/bin/ruby
require 'rubygems'
require 'digest'

require_relative 'lib/colour'
require_relative 'lib/fileio'
require_relative 'lib/var'

=begin

=end

#puts "line, section, subsection, paragraph, sentence, begin, end, tag, text"
#puts "0,    1,       2,          3,         4,        5,     6,   7,   8"


#------------------------------------------------------------------------------#
if ARGV.size != 2
  puts "Usage: ruby #{__FILE__} [dir] [word]"
  puts ""
  exit(1)
end
directory = ARGV[0]
w = ARGV[1]

#Var.info("directory", directory)

fileAry = []
Dir.glob(directory + "*.nor") do |file|
  next if file == '.' or file == '..'
  fileAry << file
end
#Var.info("fileAry", fileAry)




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
