class App
  def html(a, b = nil, &c)
      index HTMLRenderer.new(a, b || c).render
  end

  class HTMLRenderer
     def initialize(code, rewriter)
        @code = code
        @rewriter = rewriter
     end

     def render_stringify(a)
       a.inspect
     end

     def render_attr(attrs = nil)
       attrs ||= {}
       attrs.map{|k, v| "#{k} = #{render_stringify(v)}"}.join(" ")
     end

     def render(code = @code, indent = 0)
        idt = " " * (indent * 4)
        code = @rewriter.call(code)
        return  "#{idt}#{code}" if String === code
        "#{idt}<#{code[0]} #{render_attr code[2]}>\n" << Array(code[1]).map{|x| render x, indent + 1}.join("\n") << "\n#{idt}</#{code[0]}>"
      end


  end
end