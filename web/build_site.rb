#!/usr/bin/ruby
# * Create the index
# * Create an html page for each example
$:.unshift("../lib")
require 'coderay'
require 'haml'
require 'ostruct'
require 'rubyvis'
require 'RedCloth'

# First, create the examples

haml_template=Haml::Engine.new(File.read("examples.haml"))
buffer=[]

def get_base(f)
  f.sub(File.dirname(__FILE__)+"/../examples/","").gsub("/","_").gsub(".rb","")
end

# Store prev and next element
pages={}
prev_page=nil
next_page=nil

files=Dir.glob(File.dirname(__FILE__)+"/../examples/**/*.rb").sort{|a,b| puts "#{a}, #{b}"; a<=>b}
files.each do |f|
  
  next if f.include? "_data.rb"
  fn=get_base(f)
  unless prev_page.nil?
    pages[prev_page].next_ex = fn
  end
     
  pages[fn]=OpenStruct.new({:prev_ex=>prev_page, :next_ex=>next_page, :name=>fn})
  
  prev_page=fn
  
  base=fn
  
  page=pages[fn]
  mtime=File.mtime(f)
  next if f.include? "_data.rb"
  # First, get name and text
  fp=File.open(f,"r")
  comment=false
  title=File.basename(f)
  text=[]
  source_a=[]
  previous_example=""
  next_example=""
  title_obtained=false
  fp.each do |line|
    if line=~/\s*#\s*encoding:/
      next
    elsif line=~/\s*#\s*(.+)/ and !comment
      t=$1
      if t=~ /^=\s*(.+)$/ and !title_obtained
        title=$1
        title_obtained=true
      else
        text << t
      end
    else
      comment=true
      source_a << line unless line.include? "$:.unshift"
    end
  end
  text.map! {|t| t.chomp}
  # Create an html file with svg included inside
  page.source=CodeRay.scan(source_a.join(), :ruby).div
  page.title=title
  page.text=RedCloth.new(text.join("\n")).to_html
  page.svg_file=base+".svg"
  # Read svg size
  width=350
  height=200
  if File.exists? "examples/#{page.svg_file}"
    File.open("examples/#{page.svg_file}","r") {|fp|
      header=fp.gets(">")
      if header=~/\sheight='([^']+)'/ 
        height=$1
      end
      if header=~/\swidth='([^']+)'/
        width=$1
      end
    }
  end
  page.svg_width=width.to_f.ceil
  page.svg_height=height.to_f.ceil

end

pages.each do |name, page|
  html_file="examples/#{page.name}.html"
  File.open(html_file,"w") {|fp|
    fp.write(haml_template.render(page, :pages=>pages))
  }
  
end



# Create index

index_template=Haml::Engine.new(File.read("index.haml"))
File.open("index.html","w") {|fp|
  fp.write(index_template.render(self,:examples=>pages))
}
