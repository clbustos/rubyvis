# = Treemap
# Introduced by Ben Shneiderman in 1991, a treemap recursively subdivides area into rectangles. As with adjacency diagrams, the size of any node in the tree is quickly revealed. This example uses color to encode different packages of the Flare visualization toolkit, and area to encode file size. “Squarified” treemaps use approximately square rectangles, which offer better readability and size estimation than naive “slice-and-dice” subdivision. Fancier algorithms such as Voronoi and jigsaw treemaps also exist but are less common.

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/treemap_data.rb")
color = pv.Colors.category19()
nodes = pv.dom($flare).root("flare").nodes


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
  antialias(false)

treemap.node_label.add(Rubyvis::Label).
  text_style(lambda {|d| pv.rgb(0, 0, 0, 1)})

vis.render
puts vis.to_svg
