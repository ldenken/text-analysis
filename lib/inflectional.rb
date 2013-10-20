=begin
singular nouns (e.g. children child) with different plural forms
  1)	I have three (child, children).
  7)	I saw a (mouse, mice) running by.
  2)	There are five (man, men) and one (woman, women).
  3)	(Baby, Babies) play with bottles as toys.
  4)	I put two big (potato, potatoes) in the lunch box.
  5)	A few men wear (watch, watches).
  6)	I put a (memo, memos) on the desk.
  8)	There are few (bus, buses) on the road today.

verbs infinitive (e.g. understood understand) with different word forms
  understood - understand
  begin [13]	He began to talk.
  choose [8]	I chose to help.
  forget [13]	I forgot to lock the door when I left.
  swear	She swore to tell the truth.

positive adjectives with different word forms
  (e.g. best good)

nominative pronoun (e.g. whom who)
  I, you, he, she, it, they, and we
  I - Me
  He - Him
  She - Her
  They - Them
  We - Us
  Who - Whom

=end


module Inflectional 

  #----------------------------------------------------------------------------#
  def Inflectional.text(text)
    # 
    # 
    puts "Inflectional"
    

    filename = "usr/rules/singular_nouns.rules"
    singularNounsHash = FileIO.fileToHash(filename, ",", 1)
    singularNounFlag = 0
#    Var.info("singularNounsHash", singularNounsHash)

    filename = "usr/rules/infinitive_verbs.rules"
    infinitiveVerbsHash = FileIO.fileToHash(filename, ",", 1)
    infinitiveVerbFlag = 0
#    Var.info("infinitiveVerbsHash", infinitiveVerbsHash)

    filename = "usr/rules/positive_adjectives.rules"
    positiveAdjectivesHash = FileIO.fileToHash(filename, ",", 1)
    positiveAdjectiveFlag = 0
#    Var.info("positiveAdjectivesHash", positiveAdjectivesHash)

    filename = "usr/rules/nominative_pronoun.rules"
    nominativePronounHash = FileIO.fileToHash(filename, ",", 1)
    nominativePronounFlag = 0
#    Var.info("nominativePronounHash", nominativePronounHash)


    text.each do |line|
      line["NOR"].each_with_index do |w,index|
        word = w.dup

        if singularNounsHash.has_key?(word)
          line["LEM"][index] = singularNounsHash[word][0]
          line["RUL"][index] << "sn|"
          tmpNum = singularNounsHash[word][1].to_i
          singularNounsHash[word][1] = tmpNum += 1
          singularNounFlag += 1
        end

        if infinitiveVerbsHash.has_key?(word)
          line["LEM"][index] = infinitiveVerbsHash[word][0]
          line["RUL"][index] << "iv|"
          tmpNum = infinitiveVerbsHash[word][1].to_i
          infinitiveVerbsHash[word][1] = tmpNum += 1
          infinitiveVerbFlag += 1
        end

        if positiveAdjectivesHash.has_key?(word)
          line["LEM"][index] = positiveAdjectivesHash[word][0]
          line["RUL"][index] << "pa|"
          tmpNum = positiveAdjectivesHash[word][1].to_i
          positiveAdjectivesHash[word][1] = tmpNum += 1
          positiveAdjectiveFlag += 1
        end

        if nominativePronounHash.has_key?(word)
          line["LEM"][index] = nominativePronounHash[word][0]
          line["RUL"][index] << "np|"
          tmpNum = nominativePronounHash[word][1].to_i
          nominativePronounHash[word][1] = tmpNum += 1
          nominativePronounFlag += 1
        end

#        if line["LEM"][index] == ""
#          line["LEM"][index] = word
#        end

      end
    end # text.each do |line|

    if singularNounFlag > 0
      filename = "usr/rules/singular_nouns.rules"
      FileIO.hashToFile(singularNounsHash, ",", filename, "w")
    end
    if infinitiveVerbFlag > 0
      filename = "usr/rules/infinitive_verbs.rules"
      FileIO.hashToFile(infinitiveVerbsHash, ",", filename, "w")
    end
    if positiveAdjectiveFlag > 0
      filename = "usr/rules/positive_adjectives.rules"
      FileIO.hashToFile(positiveAdjectivesHash, ",", filename, "w")
    end
    if nominativePronounFlag > 0
      filename = "usr/rules/nominative_pronoun.rules"
      FileIO.hashToFile(nominativePronounHash, ",", filename, "w")
    end

    return text
  end

end # module Inflectional
















