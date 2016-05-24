class App
  class Expr
     attr_accessor :arr
     def self.from(a)
        case a
        when Numeric then new [:number, a]
        when String    then new [:string, a]
        when Regexp  then new  [:regexp, a]
        when Array     then new  [:array, a.map{|x| extract(self.from(x))}]
        when Hash     then new  [:hash, Hash[a.map{|k, v| [extract(self.from(k)), extract(self.from(v))]}]]
        when Symbol  then new [:object, a]
        when Proc     then new [:function, "", a]
        when Expr then a
	else 
		if a.respond_to? :to_expr
			a.to_expr
		else
			nil
		end
        end
    end

    def self.window
       from :window
    end

    attr_accessor :id
    ID = [0]
    def initialize(arr) 
	self.id = ID[0] += 1
       @arr = arr
    end

    def extract(x)
       self.class.extract x
    end
    
    def self.extract(x)
          case x
	  when Expr  then x.arr
	  when Array then x.map{|a| extract(a) }
	  when Hash  then Hash[x.map{|k, v| [extract(k), extract(v)]}]
	  else
		  if x.respond_to? :inner
			  x.inner
		  else
			  x
		  end
	  end
    end
  
    def to_node
       x = extract @arr
       x = [:expr, x] if !(Array === x && x[0] == :expr)
       x
    end
    
   def binop(a, b)
       self.class.new [:binop, a, @arr, extract(Expr.from(b))]
   end

    [:+, :-, :*, :/, :>=, :<=, "==", "!=", ">", "<", "&", "|", ">>", "<<"].each{|x|
       define_method x do |r|
           binop x, r
       end 
    }

    def to_js(b = nil, &c)
       JSRenderer.new(to_node, b || c).render
    end

    def [](a)
       self.class.new [:propget, @arr, extract(Expr.from(a))]
    end 

    def []=(a, b)
       self.class.new [:propset, @arr, extract(Expr.from(a)), extract(Expr.from(b))]
    end 

    def funcall(*a)
       self.class.new [:fcall, @arr, *a.map{|x| extract(Expr.from(x))}]
    end
    
    def to_frag
	@arr
    end
    
    def method_missing(sym, *args)
	if !sym.to_s["="]
	   self[sym].funcall(*args)	
	else
       self.[]= sym.to_s.chomp("="), *args
    end 
    end
          
  end
end 