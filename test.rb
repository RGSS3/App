begin 
  gem "Y"
rescue LoadError
  $: << "."
end

require 'app'
class BaseRewriter
  def call(y, indent)
     if Array === y && Array === y[1] && y[1][0] == :repeat
       return [y[0], y[1][2].map{|x| [y[1][1], *x]}, y[2]]
    end
    if Array === y && y[0] == :css
       return [:style, App::CSSRenderer.new(y[1], nil).render(y[1], indent) ]
   end
   y
  end
end 

def jsString(a)
  [:string, a]
end

def native(a)
  [:object, a]
end

def jsCall(*a)
	[:expr, [:vcall, *a]]
end
def jsArray(a)
	[:array, a]
end
def jsNumber(a)
	[:number, a]
end

def jsProp(*a)
	[:expr, [:propget, *a]]
end


id = 0
gen_id = lambda{
 id += 1
 "__#{id}"
}



x = App.new "test"

x.config.window = {}
x.config.window[:height] = 900
x.config.window[:width] = 900
x.config.window[:title] = "My Player"
x.config.window[:toolbar] = true

button = lambda{|value, code|
 name = gen_id.()
 [:@frag,[
  [:script, x.js([:block, "function __#{id}", "", [[:expr, code.to_node]]])],
  [:button, value,  onclick: x.js([:expr, [:fcall, native("__#{id}")]])]
 ]]
}

window = x.expr.window
doc = x.expr.from :document
x.html [:@frag,
 [[:@frag, "<!doctype html>" ],
  [:html, [
   [:head, [
      [:title, "My Player"],
      [:@frag, "<meta charset='UTF-8'>"],
     x.incjs("http://cdn.bootcss.com/jquery/3.0.0-beta1/jquery.min.js"),
     [:script, "function fn(){ $('#show').attr('src', 'http://www.soku.com/search_video/q_'+$('#keyword').val()) }"]
   ]], 
   [:body, [
     [:css, ["#keyword", border: "1px solid blue", "font" => "18px monaco"]],
     [:css, ["#search", border: "1px solid blue", height: "30px", "font" => "14px \"Times New Roman\"", "border-radius" => "2px"]],
     [:input, "", id: "keyword"],
     [:button, "Search", id: "search", onclick: "fn()"],
     [:iframe, "", id: "show", width: "900px", height: "840px", border: "none"]
   ]],
]]]
], BaseRewriter.new

x.run
