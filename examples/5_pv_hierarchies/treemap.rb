# = Treemap
# Introduced by Ben Shneiderman in 1991, a treemap recursively subdivides area into rectangles. As with adjacency diagrams, the size of any node in the tree is quickly revealed. This example uses color to encode different packages of the rubyvis package, and area to encode file size. “Squarified” treemaps use approximately square rectangles, which offer better readability and size estimation than naive “slice-and-dice” subdivision. 
# Fancier algorithms such as "Voronoi":http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.102.6281&rep=rep1&type=pdf and "jigsaw":http://www.research.ibm.com/visual/papers/158-wattenberg-final3.pdf treemaps also exist but are less common.

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

def get_files(path)
  h={}
  Dir.glob("#{path}/*").each {|e|
    next if File.expand_path(e)=~/pkg|web|vendor|doc|~/
    pa=File.expand_path(e) 
    if File.stat(pa).directory?
      h[File.basename(pa)]=get_files(pa)
    else
      h[File.basename(pa)]=File.stat(pa).size
    end
  }
  h
end

files=get_files(File.expand_path(File.dirname(__FILE__)+"/../../lib/"))

format=Rubyvis::Format.number
color = pv.Colors.category20
nodes = pv.dom(files).root("rubyvis").nodes


vis = pv.Panel.new()
    .width(600)
    .height(1000)

treemap = vis.add(Rubyvis::Layout::Treemap).
  nodes(nodes).mode("squarify").round(true)

treemap.leaf.add(Rubyvis::Panel).
  fill_style(lambda{|d| 
   color.scale(d.parent_node.node_name)}).
  stroke_style("#fff").
  line_width(1).
  antialias(false).
  title(lambda {|d| d.node_name+" "+format.format(d.node_value)})

treemap.node_label.add(Rubyvis::Label).
  text_style(lambda {|d| pv.rgb(0, 0, 0, 1)})

vis.render
puts vis.to_svg
