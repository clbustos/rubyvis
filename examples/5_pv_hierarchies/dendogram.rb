# = Dendogram
# A dendrogram (or cluster layout) is a node-link diagram that places leaf nodes of the tree at the same depth. In this example, the classes (orange leaf nodes) are aligned on the right edge, with the packages (blue internal nodes) to the left. As with other tree layouts, dendrograms can also be oriented radially. 
# Uses Protovis API
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


vis = Rubyvis::Panel.new do
  width 200
  height 1500 
  left 40 
  right 160 
  top 10 
  bottom 10 
  layout_cluster do
    nodes pv.dom(files).root("rubyvis").sort(lambda {|a,b| a.node_name<=>b.node_name}).nodes
    group 0.2
    orient "left"

    link.line  do
      stroke_style "#ccc"
      line_width 1
      antialias false
    end

    node.dot do 
      fill_style {|n| n.first_child ? "#aec7e8" : "#ff7f0e"}
    end
    
    node_label.label
  end
end

vis.render
puts vis.to_svg
