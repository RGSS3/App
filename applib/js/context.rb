class App  
  class Context
     attr_accessor :arr
     def initialize(arr)
       @arr = arr
     end   

     def result
       @arr
     end

     def put(obj)
       @arr.push obj
       obj
     end       

     def extract(obj)
       if obj.respond_to?(:id) && (r = @arr.index{|x| x.id == obj.id})
         @arr.delete_at r
       end
       obj
     end
     
  end
end 