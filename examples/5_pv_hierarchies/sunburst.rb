# = Sunbursts
# A sunburst is an adjacency diagram: a space-filling variant of the node-link diagram. Rather than drawing a link between parent and child in the hierarchy, nodes are drawn as solid areas (either wedges or bars), and their placement relative to adjacent nodes reveals their position in the hierarchy. Because the nodes are now space-filling, we can use an angle encoding for the size of software files. This reveals an additional dimension that would be difficult to show in a node-link diagram.
# This example show files and directory inside rubyvis lib directory and uses RBP API

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

files=get_files(File.expand_path(File.dirname(__FILE__)+"/../../lib/rubyvis/"))

#load(File.dirname(__FILE__)+"/treemap/treemap_data.rb")

colors=Rubyvis::Colors.category19()

vis = Rubyvis::Panel.new do
  width 900
  height 900
  layout_partition_fill do    
    nodes Rubyvis.dom(files).root("rubyvis").nodes
    size {|d| d.node_value}
    order "descending"
    orient "radial"
    
    node.wedge do 
      fill_style {|d| colors.scale(d.parent_node)}
      stroke_style("#fff")
      line_width(0.5)
    end
    
    node_label.label do 
      visible {|d| d.angle * d.outer_radius >= 10}
    end
    
  end
end
vis.render


puts vis.to_svg
