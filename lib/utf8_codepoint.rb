
i = 0
while i <= 1024
  if (i >= 32 && i <= 96) || (i >= 97 && i <= 126) #|| (i >= 161 && i <= 256)
	  puts "#{i} -> #{i.chr('UTF-8')}" #=> "国"
  end
	i += 1
end
puts ""


#ium’s I

puts "#{"’".codepoints[0]}"

puts "#{"_".codepoints[0]}"
# “

puts "“ -> #{"“".codepoints[0]}"
puts "@ -> #{"@".codepoints[0]}"
puts "— -> #{"—".codepoints[0]}"
puts "’ -> #{"’".codepoints[0]}"
puts "© -> #{"©".codepoints[0]}"
puts "Â -> #{"Â".codepoints[0]}"

puts "­ -> #{"­".codepoints[0]}"
puts "- -> #{"-".codepoints[0]}"
 
 



#------------------------------------------------------------------------------#
def utf8String(string)
	newString = ""
	string.each_codepoint do |c|
    case 
    when c >= 32 && c <= 95
      newString << c
    when c >= 97 && c <= 126
      newString << c
    when c == 96       # 96 -> ` -> 39 -> '
      newString << 39
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



text = "RT@NIST.GOV OR VIA REGULAR MAIL AT or the nation’s measurement"
puts "\n#{text}"
text = utf8String(text)
puts "#{text}"


puts ""
# END
#-----------------------------------------------------------------------------#
__END__



