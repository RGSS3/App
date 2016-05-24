require 'applib/js/expr'
require 'applib/js/context'
class App
  class ExprC
     ContextStack = [App::Context.new([])]
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
         a.context.extract a if a.respond_to?(:context)
         a
     end

     attr_reader :id
     attr_accessor :context
     def initialize(a, pure = false)
        @expr = Expr.from a
        @id     = @expr.id
        self.context = ContextStack[-1]
        self.class.put @expr if !pure
     end    
     
      def phi(x, pure)
        self.class.phi x, pure
      end
     
      def self.phi(x, pure)
         extract x
         new Expr.from(x), pure
     end

     def method_missing(sym, *args, &b)
        args = args + [self.class.lambda(&b)] if b
        u = args.map{|x| phi x, true}
        self.class.new phi(self, true).to_expr.send(sym, *u)
     end

     def funcall(*args, &b)
        args = args + [self.class.lambda(&b)] if b
        u = args.map{|x| phi x, true}
        self.class.new phi(self, true).to_expr.funcall(*u)    
     end

     def inner
        @expr
     end

     def to_expr
        @expr
     end

     def to_frag
        to_expr.arr
     end

    def self.ret val
        new Expr.new [:ret, phi(val, true).to_frag]
    end

   def binop(a, b)
      self.class.new self.class.extract(@expr).binop(a, phi(b, true))
   end

   def self.var(*args)
      if args.length == 1
          new Expr.new [:var, args[0]]
      else
         new Expr.new [:var, args[0], phi(args[1], true).to_frag]
      end
      new Expr.new([:object, args[0].to_sym]), true
   end
   def self.gvar(*args)
      if args.length == 1
          new Expr.new [:gvar, args[0]]
      else
         new Expr.new [:gvar, args[0], phi(args[1], true).to_frag]
      end
      new Expr.new([:object, args[0].to_sym]), true
   end

    def self.lambda(name = nil, &block)
       new Expr.new [:func, name, block.parameters.map{|x| x[-1]}, make_block(&block)]
    end

    def self.make_block(name = nil, &block)
       args = block.parameters.map{|x| new x[-1], true}
       r = []
       context r do
         yield *args
      end
       r.map{|x| x.to_frag}
    end

    def self.if(exprc, &block)    
      new Expr.new [:if, phi(exprc, true).to_frag, make_block(&block)]
    end

    def else(&block)
      raise "else without if" if to_frag[0] != :if
      phi self, true
      self.class.new Expr.new to_frag + [self.class.make_block(&block)]
    end

  end
end