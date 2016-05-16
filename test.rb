begin 
  gem "Y"
rescue LoadError
  $: << "."
end

require 'app'
x = App.new "test"

x.config.window = {}
x.config.window[:height] = 768
x.config.window[:width] = 1024
x.config.window[:title] = "Hello world"

class Repeater
  def call(y)
     if Array === y && Array === y[1] && y[1][0] == :repeat
        [y[0], y[1][2].map{|x| [y[1][1], *x]}, y[2]]
     else
       y
    end
  end
end 

x.html [:html, [
   [:head, [
      [:title, "Hello world"],
   ]], 
   [:body, [
     [:p, [:repeat, :span, ["1", "2", "3"]], style: "color: #F00;"],
   ]],
]], Repeater.new

x.run
