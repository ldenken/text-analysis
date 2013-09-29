module Parse
  #puts "-> module Parse"
  #
  #

  require 'rubygems'
  require 'digest'

  #----------------------------------------------------------------------------#
  # Run a system command, return the output or exit if command fails
  def Parse.doSystemCommand(command)
    output = `#{command}`; result = $?.success?
    #puts "command  : #{command}"
    #puts "output   : #{output}"
    #puts "result   : #{result}"
    if result == true
      return output
    else
      puts ""
      puts "Error!"
      puts "def Parse.doSystemCommand(command)"
      puts "command  : #{command}"
      puts "output   : #{output}"
      puts "result   : #{result}"
      puts ""
    end
  end


  #----------------------------------------------------------------------------#
  def Parse.doPDFfile(filename)
    puts "-> Parse.doPDFfile(#{filename})"

    inputFile = filename
    #puts "inputFile : #{inputFile}"
    hash = Digest::MD5.file(filename).hexdigest
    #puts "hash      : #{hash}"
    tmpArray = []
    tmpArray = inputFile.split("/")
    dirName = ""
    imgDir = ""
    tmpDir = ""
    if tmpArray.length >= 1
      (tmpArray.length-1).times do |i|
        dirName << "#{tmpArray[i]}/"
      end
      #puts "dirName   : #{dirName}"
      imgDir = "#{dirName}img"
      tmpDir = "#{dirName}tmp"
    else
      imgDir = "img"
      tmpDir = "tmp"
    end
    #puts "imgDir    : #{imgDir}"
    #puts "tmpDir    : #{tmpDir}"
    pdfFile = inputFile.gsub(/[a-z0-9]{1,255}\.pdf/, "") + "#{hash}.pdf" 
    puts "pdfFile   : #{pdfFile}"
    txtFile = inputFile.gsub(/[a-z0-9]{1,255}\.pdf/, "") + "#{hash}.txt" 
    puts "txtFile   : #{txtFile}"

    command = "mv -f #{inputFile} #{pdfFile} 2>&1"
    output = Parse.doSystemCommand(command)

    command = "pdftotext -eol unix -nopgbrk #{pdfFile}"
    output = Parse.doSystemCommand(command)

    # exiftool
    command = "echo ' ' >> #{txtFile}"
    output = Parse.doSystemCommand(command)
    command = "echo '=begin' >> #{txtFile}"
    output = Parse.doSystemCommand(command)
    command = "exiftool #{pdfFile} >> #{txtFile}"
    output = Parse.doSystemCommand(command)

    # pdfimages
    command = "pdfimages -j #{pdfFile} #{tmpDir}/img"
    output = Parse.doSystemCommand(command)
    command = "for f in #{tmpDir}/*.ppm; do convert $f $f.png; rm -f $f; done"
    output = Parse.doSystemCommand(command)
    command = "for f in #{tmpDir}/*.png; do h=$(md5 $f|cut -d' ' -f4); mv $f #{tmpDir}/$h.png 2>&1; done"
    output = Parse.doSystemCommand(command)

    command = "echo 'Images :' >> #{txtFile}"
    output = Parse.doSystemCommand(command)
    command = "ls #{tmpDir}/*.png"
    output = Parse.doSystemCommand(command)
    tmp = output.gsub!("#{tmpDir}", "img")
    command = "echo '#{tmp}' >> #{txtFile}"
    output = Parse.doSystemCommand(command)

    command = "echo '=end' >> #{txtFile}"
    output = Parse.doSystemCommand(command)
    command = "echo ' ' >> #{txtFile}"
    output = Parse.doSystemCommand(command)
    command = "echo ' ' >> #{txtFile}"
    output = Parse.doSystemCommand(command)

    command = "mv -f #{tmpDir}/*.png #{imgDir}/"
    output = Parse.doSystemCommand(command)

    # force utf-8 encoding
    command = "iconv -t UTF-8 -c -s #{txtFile} > #{txtFile}.utf8"
    output = Parse.doSystemCommand(command)
    command = "mv -f #{txtFile}.utf8 #{txtFile}"
    output = Parse.doSystemCommand(command)

=begin
    # UTF8 RAW file, REPLACING the original file!
    document = []
    File.foreach(txtFile) do |line| 
      line.strip!
      line.force_encoding("utf-8")
      line = FileIO.utf8String(line)
      document << line
    end
    FileIO.doArrayToFile(document, txtFile)

    # apply the normalise RAW rules, REPLACING the original file!
    aryNormaliseRAWrules = FileIO.fileToArrayOfArrays("lib/data/NormaliseRAWrules.ary")
    aryHyphenatedRules = FileIO.fileToArray("lib/data/hyphenatedrules.ary")
    document = []
    File.foreach(txtFile) do |line| 
      line.strip!
      line = Normalise.string(aryNormaliseRAWrules, aryHyphenatedRules, line)
      document << line
    end
    FileIO.doArrayToFile(document, txtFile)

    # mate
    command = "mate #{txtFile}"
    output = Parse.doSystemCommand(command)

    # Preview
    command = "open -g -a Preview #{txtFile}"
    output = Parse.doSystemCommand(command)
=end

  end # def Parse.doPDFfile(filename)
end # module Parse


#------------------------------------------------------------------------------#
if ARGV.size != 1
  puts "Usage: ruby #{__FILE__} [dir/file]"
  puts ""
  exit(1)
end
filename = ARGV[0]

Parse.doPDFfile(filename)

#-----------------------------------------------------------------------------#
__END__



















