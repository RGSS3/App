class App
  def html(a, b = nil, &c)
      index HTMLRenderer.new(a, b || c).render
  end
  
   class BaseRenderer
     def initialize(code, rewriter)
        @code = code
        @rewriter = rewriter
     end

     def render_stringify(a)
       a.inspect
     end
  end

  class HTMLRenderer < BaseRenderer
     def render_attr(attrs = nil)
       attrs ||= {}
       attrs.map{|k, v| "#{k} = #{render_stringify(v)}"}.join(" ")
     end

     def render(code = @code, indent = 0)
        idt = " " * (indent * 4)
        code = @rewriter.call(code, indent)  if @rewriter
        return  "#{idt}#{code}" if String === code
	case code[0]
		when :@frag then Array(code[1]).map{|x| render x, indent}.join("\n")
	       else
                 "#{idt}<#{code[0]} #{render_attr code[2]}>\n" << Array(code[1]).map{|x| render x, indent + 1}.join("\n") << "\n#{idt}</#{code[0]}>"
	end
      end
  end
  
  def js(a, b = nil, &c)
      JSRenderer.new(a, b || c).render
  end
  
  def includejs(url)
      [:script, "", src: url, type: "text/javascript"]
  end
  
  require 'net/http'  
  require 'digest/md5'
  def incjs(url)
	a = Net::HTTP.get URI(url)
	@asset ||= 0
	@asset += 1
	name = "asset/js/#{Digest::MD5.hexdigest(a)}"
	asset name, a
	[:script, "", src: name, type: "text/javascript"]
  end
  
  require 'applib/js/expr'
  
  def expr(a = nil, &b)
    if a 
	Expr.new *a, &b
    else
	Expr
    end
  end
  
  class JSRenderer < BaseRenderer
     def render_expr(code, indent = 0)
	case code.first
		when :@frag then code[1].to_s
		when :undefined, :null, :true, :false then code[0].to_s
		when :string then render_stringify(code[1])
		when :number then code[1].to_s
		when :object, :method then code[1].to_s
		when :vcall then render_expr([:fcall, [:object, render_expr(code[1]) + "." + render_expr(code[2])], *code[3..-1]])
		when :propget then render_expr([:object, render_expr(code[1]) + "." + render_expr(code[2])])
		when :propset then render_expr([:object, render_expr(code[1]) + "." + render_expr(code[2])]) + "=" + render_expr(code[3])
		when :fcall then "#{render_expr code[1]}(#{code[2..-1].map{|x| render_expr x}.join(", ")})"
		when :array then "[#{code[1].map{|x| render_expr x}.join(", ")}]"
		when :hash then "{#{code[1].map{|k, v| render_expr(k) + ": " + render_expr(v)}.join(", ")}}"
		when :new then "new " + render_expr([:fcall, *code[1..-1]])
		when :expr then render_expr code[1]
		when :binop then "(" + render_expr(code[2]) + ")" + code[1].to_s + "(" + render_expr(code[3]) + ")"
		when :function then
           x = code[2].call(*code[2].parameters.map{|x| Expr.from(x[-1])})
		  "(function #{code[1]}(#{code[2].parameters.map{|x| x[-1]}.join(",")}){" + render(Expr.extract(x)) + "})"
		 when :func then
		  "(function #{code[1]}(#{code[2].join(",")}){" + code[3].join("\n") + ";})"
	end
     end
     
     def render(code = @code, indent = 0)
	idt = " " * (indent * 4)
	code = @rewriter.call(code, indent) if @rewriter
	case code.first
	  when :block
	    "#{idt}#{code[1]}(#{code[2]}){\n" + code[3].map{|x| render(x, indent+1) }.join("\n") + "\n#{idt}}"
	  when :if
	   "#{idt}#{code[1]}(#{code[2]}){\n" + code[3].map{|x| render(x, indent+1) }.join("\n") + "\n#{idt}}else{\n" + code[4].map{|x| render(x, indent+1) }.join("\n") + "\n#{idt}}"
	  else
	   "#{idt}#{render_expr code, indent};"
	end
     end
  end
  
  def css(a, b = nil, &c)
      CSSRenderer.new(a, b || c).render
  end
  
  class CSSRenderer < BaseRenderer
     def render(code = @code, indent = 0)
	idt = " " * indent
	code = @rewriter.call(code, indent) if @rewriter
	"#{idt}#{code[0]}{\n" + code[1].map{|k, v| "#{idt}#{idt}#{k}: #{v};\n"}.join + "#{idt}}\n"
     end
  end
end