# = Circle Packing
# Enclosure diagrams are also space-filling, using containment rather than adjacency to represent the hierarchy. As with adjacency diagrams, the size of any node in the tree is quickly revealed. Although circle packing does not use space as efficiently as a treemap, the “wasted” space effectively reveals the hierarchy. At the same time, node sizes can be rapidly compared using area judgments.
# By flattening the hierarchy, the pack layout can also be used to create "bubble charts":bubble_charts.html.
# This example uses RBP API.


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

format = Rubyvis::Format.number();

vis = Rubyvis::Panel.new do
  width 600
  height 796
  margin 2
  layout_pack do
    nodes Rubyvis.dom(files).root("Rubyvis").nodes
    size(lambda {|d| d.node_value})
    node.dot do 
      fill_style {|d| 
        d.first_child ? "rgba(31, 119, 180, 0.25)" : "#ff7f0e"
      }
      title {|d| 
        d.node_name.to_s + (d.first_child ? "" : ": " + format.format(d.node_value))
      }
      line_width 1
    end
    node_label.label do
      visible {|d| !d.first_child}
      text {|d| d.node_name[0, Math.sqrt(d.node_value) / 10]}
    end
  end
end

vis.render()
puts vis.to_svg

