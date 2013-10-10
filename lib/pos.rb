module Pos
  require 'stanford-core-nlp'
  
  #----------------------------------------------------------------------------#
  def Pos.document(filename, text)
    #
    #
    #
    puts "Parts of Speach"
    pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :parse)

    text.each do |line|
      string = ""
      line["NOR"].each {|e| string << "#{e} "}
      string.strip!
      string = StanfordCoreNLP::Annotation.new(string)
      pipeline.annotate(string)

      tokenAry = []
      posAry = []
      basic_dependencies = "\n"

      string.get(:sentences).each do |token|
        basic_dependencies << token.get(:basic_dependencies).to_s
      end

#      puts ""
#      puts "#{basic_dependencies}"
#      puts ""
      tmpStr = basic_dependencies.dup
      tmpStr.gsub!("->", "")
      tmpStr.gsub!("-", "/")
      tmpStr.gsub!(")", "")
      tmpStr.gsub!("(", "/")
      tmpStr.gsub!(/[ ]/, "")
      #puts "#{tmpStr}"
      tmpAry = tmpStr.split("\n")
      #puts tmpAry.inspect
      tmpHsh = {}
      tmpAry.each do |e|
        a = e.split("/")
        tmpHsh["#{a[0]}"] = ["#{a[1]}", "#{a[2]}"]
      end
      #puts tmpHsh.inspect

      line["NOR"].each_with_index do |e,i|
        if tmpHsh.has_key?(e) == true
          #puts "#{e} #{tmpHsh[e][0]} #{tmpHsh[e][1]}"
          line["POS"][i] = tmpHsh[e][0]
          line["DEP"][i] = tmpHsh[e][1]
        end
      end
      line["DEP"] << basic_dependencies

    end # text.each do |line|

    puts ""
    return text
  end
  


end # module Pos
