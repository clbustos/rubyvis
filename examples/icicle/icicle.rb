# = Treemap
# Introduced by Ben Shneiderman in 1991, a treemap recursively subdivides area into rectangles. As with adjacency diagrams, the size of any node in the tree is quickly revealed. This example uses color to encode different packages of the Flare visualization toolkit, and area to encode file size. “Squarified” treemaps use approximately square rectangles, which offer better readability and size estimation than naive “slice-and-dice” subdivision. Fancier algorithms such as Voronoi and jigsaw treemaps also exist but are less common.

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/icicle_data.rb")

colors=Rubyvis::Colors.category19
vis = Rubyvis::Panel.new.
  width(900).
  height(300).
  bottom(30)
#$flare={:a=>{:b=>1,:c=>2}}

layout = vis.add(Rubyvis::Layout::Partition::Fill).
  nodes(Rubyvis.dom($flare).root("flare").nodes)
layout.order("descending")
layout.orient("top")
layout.size(lambda {|d| d.node_value})

layout.node.add(pv.Bar).
  fill_style(lambda {|d| colors.scale(d.parent_node)}).
  stroke_style("rgba(255,255,255,.5)").
  line_width(1).
  antialias(false)

layout.node_label.add(pv.Label)
    .text_angle(-Math::PI / 2.0)
    .visible(lambda {|d| d.dx>6 })
vis.render()

puts vis.to_svg
