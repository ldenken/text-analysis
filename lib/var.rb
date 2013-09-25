#------------------------------------------------------------------------------#
# A simple module to display variable information 
# require_relative 'lib/var => Var.info("test", test)
module Var
  def Var.info(name, variable)
    column = 10
    puts "variable".ljust(column) + ": #{name}"
    puts "class".ljust(column) + ": #{variable.class}"

    case variable
    when Array
      puts "length".ljust(column) + ": #{variable.length}"
      print "elements".ljust(column) + ": "
      variable.each {|e| print "#{e} "}
      puts ""

    when Hash
      puts "length".ljust(column) + ": #{variable.length}"
      tmpArray = variable.keys
      block = 0
      tmpArray.each do |e| 
        if e.class == Fixnum
          if block < e.to_s.length
            block = e.to_s.length
          end
        else
          if block < e.length.to_i
            block = e.length.to_i
          end          
        end
      end
      
      
      tmpArray.each_with_index do |e,i|
        if i == 0
          print "elements".ljust(column) + ": "
          print "#{e}".ljust(block+1) + "=> #{variable[e]}"; puts ""
        else
          print "".ljust(column+2)
          print "#{e}".ljust(block+1) + "=> #{variable[e]}"; puts ""        
        end
      end

    else
      puts "inspect".ljust(column) + ": #{variable.inspect}"

    end
    puts ""
  end
end