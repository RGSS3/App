class App  
  class Context
     def initialize(arr)
       @arr = arr
       @index = Hash[@arr.each_with_index{|x, i| [x.hash, i]}]
     end   

     def result
       @arr
     end

     def put(obj)
       @arr.push obj
       @index[@arr[-1].hash] = @arr.length - 1
       obj
     end       

     def extract(obj)
       if @index.include?(obj.hash)
         @arr.delete_at @index[obj.hash]
         @index.delete obj.hash
       end
       obj
     end
  end
end 