module WN
  #puts "-> module Var"
  # 
  # 

  #------------------------------------------------------------------------------#
  def WN.over(input, display_raw)
    #Var.Info("display_raw", display_raw)

    output = `wn #{input} -over 2>&1`; result = $?.success?
    #Var.Info("output", output)
    
    hshWNover = {}

    aryOutput = output.split("\n")
    aryOutput.reject! { |e| e.gsub!(/[ ]{2,}/, ""); e.empty? } # remove spaced and empty elements
    #Var.Info("aryOutput", aryOutput)

    if display_raw == 1
      print "-"*80
      puts ""; aryOutput.each {|l| puts "#{l}"}
      print "-"*80; puts ""
    end
  
    #Var.Info("result", result)
    if result == false
      words = []
      word = ""
      types = []
      type = ""
      senses = {}
      related = {}

      aryOutput.each_with_index do |line, index|
        if line =~ /^Overview/
          tmpArray = line.split(" ")
          type = tmpArray[2]
          types << type
          word = tmpArray[3]
          words << word
          tmpArray = aryOutput[index+1].strip.split(" ")
          tmpNum = tmpArray[4].to_i
          if tmpNum.to_i > 0
            tmpArray = []
            synArray = []

            tmpNum.to_i.times do |i| 
              tmpArray << aryOutput[(index+1)+(i+1)]
              tmpString = aryOutput[(index+1)+(i+1)].match(/^[0-9].*--/).to_s
              tmpString.gsub!(/[0-9|\.|\(|\)|\-]/, "").strip!
              tmpSynArray = tmpString.split(", ")
              synArray << tmpSynArray
            end
            synArray.compact!
            related["#{word}:#{type}"] = synArray
            senses["#{word}:#{type}"] = tmpArray
          end
        end
      end
      words.uniq!
      types.uniq!
      relatedKeys = related.keys
      relatedKeys.each do |k|
        related[k].flatten!
        related[k].uniq!
      end

      hshWNover["words"] = words
      if hshWNover["words"].length >= 2 
        hshWNover["clipped"] = hshWNover["words"][1]
      end
      hshWNover["related"] = related
      hshWNover["senses"] = senses

=begin
      puts ""; print "#{input.bold}".ljust(22) + ": "
      words.each_with_index do |v,i| 
        if (i+1) < words.length
          print "#{v}, "
        else
          print "#{v}"    
        end
      end
      puts ""

      related.each do |k,v|
        print "#{k.bold}".ljust(22) + ": "
        v.each_with_index do |v,i| 
          if (i+1) < related[k].length
            print "#{v}, "
          else
            print "#{v}"      
          end
        end
        puts ""
      end

      puts ""
      senses.each do |k,v| 
        puts "#{k.bold} (#{v.length})"
        v.each { |e| puts "#{e.gsub(/\([0-9]{1,}\) /, "").gsub(/\(|\)/, "").gsub("--", "-")}"}
      end
=end

    end # if result == false

    return hshWNover
  end
end