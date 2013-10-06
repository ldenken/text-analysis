#!/usr/bin/ruby
require 'rubygems'
require 'digest'

require_relative 'lib/colour'
require_relative 'lib/fileio'
require_relative 'lib/var'

=begin

=end

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

hepta = {}
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
        id = Digest::MD5.hexdigest("#{l[index-3]} #{l[index-2]} #{l[index-1]} #{word} #{l[index+1]} #{l[index+2]} #{l[index+3]}")
        if hepta.has_key?(id) == true
          tmpInt = hepta[id][7]
          tmpInt += 1
          hepta[id] = [l[index-3], l[index-2], l[index-1], word, l[index+1], l[index+2], l[index+3], tmpInt]
        else
          hepta[id] = [l[index-3], l[index-2], l[index-1], word, l[index+1], l[index+2], l[index+3], 1]
        end
      end
    end
  end
  puts "#{filename} (#{count})"
end # fileAry.each do |filename|
puts "#{fileAry.length}"


col = 0
count = "#{hepta.length}".length
#puts "#{count}"
hepta.each do |k,v|
  tmpInt = v[0].length + v[1].length + v[2].length + count + 1
  if tmpInt > col
    col = tmpInt
  end
end


block = 0
hepta.each do |k,v|
  puts ""
  print "#{v[7]}".rjust(count)
  space = col - block
  print "#{v[0]} #{v[1]} #{v[2]} ".rjust(space) 
  print "#{v[3].bold}"
  print " #{v[4]} #{v[5]} #{v[6]}"
end
puts ""
puts "#{hepta.length}"
#Var.info("hepta", hepta)

puts ""
hepta.each do |k,v|
  puts "textAry << \"#{v[0]} #{v[1]} #{v[2]} #{v[3].bold} #{v[4]} #{v[5]} #{v[6]}\""
end
puts ""
puts "#{hepta.length}"



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
