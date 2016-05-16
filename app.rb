require 'json'
require 'ostruct'
require 'applib/render'

class App
  Default = {
    name: 'App',
    main: 'index.html',
    title: 'App',
  }

  def initialize(dir = "app")
    @dir = dir
    Dir.mkdir dir rescue 1
    @config = OpenStruct.new({}.update Default)
  end 

  def open(file, *a, &b)
     super File.join(@dir, file), *a, &b
  end

  def run
    open("package.json", "w") do |f|
       f.write JSON.dump @config.to_h
    end
    system "nw #@dir"
  end

  def index(a)
     open("index.html", "w") do |f| f.write a end
  end



  def config
    @config
  end
  
end

