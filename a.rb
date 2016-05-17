$: << "."
require 'app'
p App::Expr.from(lambda{|a, b| a.funcall(b)}).to_js
