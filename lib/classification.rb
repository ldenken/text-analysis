#!/usr/bin/ruby
require 'rubygems'
require 'digest'

require_relative 'colour'
require_relative 'fileio'
require_relative 'var'

class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end

txt_1 = { "RAW" => ["Chinese", "Beijing", "Chinese"], "CLS" => "c" }
txt_2 = { "RAW" => ["Chinese", "Chinese", "Shanghai"], "CLS" => "c" }
txt_3 = { "RAW" => ["Chinese", "Macao"], "CLS" => "c" }
txt_4 = { "RAW" => ["Tokyo", "Japan", "Chinese"], "CLS" => "j" }
txt_5 = { "RAW" => ["Chinese", "Chinese", "Chinese", "Tokyo", "Japan"], "CLS" => "?" }

text = []
text << txt_1
text << txt_2
text << txt_3
text << txt_4
text << txt_5
#Var.info("text", text)

class_c_text = []
class_c_text.concat( txt_1["RAW"] )
class_c_text.concat( txt_2["RAW"] )
class_c_text.concat( txt_3["RAW"] )
Var.info("class_c_text", class_c_text)

class_j_text = []
class_j_text.concat( txt_4["RAW"] )
Var.info("class_j_text", class_j_text)

train_text = []
train_text.concat( txt_1["RAW"] )
train_text.concat( txt_2["RAW"] )
train_text.concat( txt_3["RAW"] )
train_text.concat( txt_4["RAW"] )
Var.info("train_text", train_text)

test_text = []
test_text.concat( txt_5["RAW"] )
Var.info("test_text", test_text)

train_vocabulary = []
train_vocabulary.concat( class_c_text )
train_vocabulary.concat( class_j_text )
train_vocabulary.uniq!
train_vocabulary.sort!
Var.info("train_vocabulary", train_vocabulary)

test_vocabulary = []
test_vocabulary.concat( test_text )
test_vocabulary.uniq!
test_vocabulary.sort!
Var.info("test_vocabulary", test_vocabulary)


classes = []
classes << txt_1["CLS"]
classes << txt_2["CLS"]
classes << txt_3["CLS"]
classes << txt_4["CLS"]
classes.uniq!
classes.sort!
Var.info("classes", classes)


class_c_count = 0
class_j_count = 0
class_x_count = 0
text.each_with_index do |line,index|
  case line["CLS"]
  when "c"
    class_c_count += 1
  when "j"
    class_j_count += 1
  else
    class_x_count += 1
  end
end
puts "prior probability of classes "
prior_class_c = class_c_count/(class_c_count+class_j_count).to_f 
puts "P(c)= #{prior_class_c}"
prior_class_j = class_j_count/(class_c_count+class_j_count).to_f 
puts "P(j)= #{prior_class_j}"
puts ""



puts "Condional Probabilies: class c"
probabilies = {}
test_text.each_with_index do |token,index|
  token_count = 0
  vocabulary_add = 1
  class_c_text_count = class_c_text.length
  train_vocabulary_count = train_vocabulary.length
  class_c_text.each do |t| 
    if t == token
      token_count += 1
    end
  end
  s = (token_count+vocabulary_add)/(class_c_text_count+train_vocabulary_count).to_f
  print "P(#{token}|c)".ljust(12)
  print " = (#{token_count}+#{vocabulary_add})/(#{class_c_text_count}+#{train_vocabulary_count})".ljust(16)
  print " = #{s}" 
  puts ""
  key = "#{index}_#{token}_c"
  probabilies[key] = s
end
puts ""
#Var.info("probabilies", probabilies)
prior_class_c = class_c_count/(class_c_count+class_j_count).to_f 
puts "P(c|txt_5) ∝ 3/4 * (3/7)3 * 1/14 * 1/14"
pp = 0 # proportional probability
pp = prior_class_c
probabilies.each {|k,v| pp  = pp  * v  }
p pp.round(6)
puts ""








puts "Condional Probabilies: class j"
probabilies = {}
test_text.each_with_index do |token,index|
  token_count = 0
  vocabulary_add = 1
  class_j_text_count = class_j_text.length
  train_vocabulary_count = train_vocabulary.length
  class_j_text.each do |t| 
    if t == token
      token_count += 1
    end
  end
  s = (token_count+vocabulary_add)/(class_j_text_count+train_vocabulary_count).to_f
  print "P(#{token}|j)".ljust(12)
  print " = (#{token_count}+#{vocabulary_add})/(#{class_j_text_count}+#{train_vocabulary_count})".ljust(16)
  print " = #{s}" 
  puts ""
  key = "#{index}_#{token}_j"
  probabilies[key] = s
end
puts ""
#Var.info("probabilies", probabilies)
prior_class_j = class_j_count/(class_j_count+class_j_count).to_f 
puts "P(j|txt_5) ∝ 1/4 * (2/9)3 * 2/9 * 2/9"
pp = 0 # proportional probability
pp = prior_class_j
probabilies.each {|k,v| pp  = pp  * v  }
p pp.round(6)
puts ""




puts ""
#------------------------------------------------------------------------------#
__END__

p 6/14.to_f
p ((token_count+vocabulary_add)).percent_of((class_c_text_count+train_vocabulary_count))



puts "#{3/4*100.to_i}"
puts "c = #{class_c_count}"
p class_j_count
p class_x_count



puts ""
p (3).percent_of(4)    # => 10.0  (%)
p (class_c_count).percent_of((class_c_count+class_j_count))    # => 10.0  (%)

puts ""
# Note: the brackets () around number are optional
p (1).percent_of(10)    # => 10.0  (%)
p (200).percent_of(100) # => 200.0 (%)
p (0.5).percent_of(20)  # => 2.5   (%)

pizza_slices = 5
eaten = 3
p eaten.percent_of(pizza_slices) # => 60.0 (%)



#classes[txt_1["class"]] = "xx"
#classes[txt_4["class"]] = "xx"
#Var.info("classes", classes)


Pˆ ( c ) = N c N


Priors: 3 P(c)= 4 1
P(j)= 4



Var.info("txt_1", txt_1)
Var.info("txt_1[\"text\"]", txt_1["text"])
Var.info("txt_1[\"class\"]", txt_1["class"])


Doc Words Class
Training
1 Chinese Beijing Chinese c
2 Chinese Chinese Shanghai c
3 Chinese Macao c
4 Tokyo Japan Chinese j
Test
5 Chinese Chinese Chinese Tokyo Japan ?
