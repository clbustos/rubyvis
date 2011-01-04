# = Node-Link Trees
# The tree layout implements the Reingold-Tilford algorithm for efficient, tidy arrangement of layered nodes. This node-link diagram is similar to the dendrogram, except the depth of nodes is computed by distance from the root, leading to a ragged appearance. Cartesian orientations are also supported. 

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



files=get_files(File.expand_path(File.dirname(__FILE__)+"/../../"))
#files={:b=>{:c=>1,:d=>2}}


vis = Rubyvis::Panel.new()
    .width(800)
    .height(800)
    .left(0)
    .right(0)
    .top(0)
    .bottom(0)

tree = vis.add(Rubyvis::Layout::Tree).
  nodes(Rubyvis.dom(files).root("rubyvis").nodes()).
  orient('radial').
  depth(85).
  breadth(12)

tree.link.add(Rubyvis::Line)

tree.node.add(Rubyvis::Dot).
fill_style(lambda {|n| n.first_child ? "#aec7e8" : "#ff7f0e"}).
title(lambda {|n| n.node_name})

tree.node_label.add(Rubyvis::Label).
visible(lambda {|n| n.first_child})


vis.render
puts vis.to_svg
