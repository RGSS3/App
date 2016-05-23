require 'applib/js/expr'
require 'applib/js/context'
class App
  class ExprC
     ContextStack = []
     def self.context arr = []
        ContextStack.push App::Context.new arr
        yield
     ensure
        ContextStack.pop
     end

     def self.put(a)
        ContextStack[-1].put a
     end

     def self.extract(a)
        ContextStack[-1].extract a
     end

     attr_reader :id
     def initialize(a)
        @expr = Expr.from a
        @id     = @expr.id
        self.class.put @expr
     end    
     
     def method_missing(sym, *args)
        u = args.map{|x| Expr.from self.class.extract Expr.extract x}
        self.class.new self.class.extract(@expr).send(sym, *u)
     end

     def inner
        @expr
     end

     def to_expr
        @expr
     end

    def self.lambda(name = nil, &block)
       args = block.parameters.map{|x| new x[-1]}
       r = []
       context r do
          yield *args
       end
       new Expr.new [:func, name, block.parameters.map{|x| x[-1]}, r.map(&:to_js)]
    end


  end
end