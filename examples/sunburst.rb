# = Sunbursts
# A sunburst is an adjacency diagram: a space-filling variant of the node-link diagram. Rather than drawing a link between parent and child in the hierarchy, nodes are drawn as solid areas (either wedges or bars), and their placement relative to adjacent nodes reveals their position in the hierarchy. Because the nodes are now space-filling, we can use an angle encoding for the size of software files. This reveals an additional dimension that would be difficult to show in a node-link diagram. 

$:.unshift(File.dirname(__FILE__)+"/../lib")
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

files=get_files(File.dirname(__FILE__)+"/../")

vis = Rubyvis::Panel.new.
  width(900).
  height(900).
  bottom(-80)

colors=Rubyvis::Colors.category19()

partition = vis.add(Rubyvis::Layout::Partition::Fill)
.nodes(Rubyvis.dom(files).root("rubyvis").nodes)
    .size(lambda {|d| d.node_value})
    .order("descending")
    .orient("radial")

partition.node.add(Rubyvis::Wedge)
.fill_style(lambda {|d| colors.scale(d.parent_node)})
    .stroke_style("#fff")
    .line_width(0.5)

    partition.node_label.add(Rubyvis::Label).
  visible(lambda {|d| d.angle * d.outer_radius >= 6})

vis.render


puts vis.to_svg
