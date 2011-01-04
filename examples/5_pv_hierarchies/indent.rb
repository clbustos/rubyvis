# = Indented Tree
# Indented trees are widely-used to represent file systems, among other applications. Although indented trees require much vertical space and do not easily facilitate multiscale inference, they do allow efficient interactive exploration of the tree to find a specific node.
# In addition, the indent layout allows rapid scanning of node labels, and multivariate data such as file size can be displayed adjacent to the hierarchy.
#
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


root = Rubyvis.dom(files)
    .root("rubyvis")
    .sort(lambda {|a,b| a.node_name<=>b.node_name})

#/* Recursively compute the package sizes. */
root.visit_after {|n,i| 
  if (n.first_child)
    n.node_value= Rubyvis.sum(n.child_nodes , lambda {|nn|  nn.node_value})
  end
}

def t(d)
  d.parent_node ? (t(d.parent_node) + "." + d.node_name) : d.node_name
end

vis = Rubyvis::Panel.new()
    .width(260)
    .height((root.nodes.size + 1)* 12)
    .margin(5)

layout = vis.add(pv.Layout.Indent)
.nodes(lambda {root.nodes})
    .depth(12)
    .breadth(12)

layout.link.add(pv.Line)

node = layout.node.add(pv.Panel)
.top(lambda {|n| n.y - 6})
    .height(12)
    .right(6)
    .strokeStyle(nil)
    
node.anchor("left").add(pv.Dot)
    .strokeStyle("#1f77b4")
    .fillStyle(lambda {|n| n.first_child ? "#aec7e8" : "#ff7f0e"})
    .title(lambda {|d| t(d)})
  .anchor("right").add(pv.Label)
  .text(lambda {|n| n.node_name})

node.anchor("right").add(pv.Label)
.text(lambda {|n| (n.node_value >> 10).to_s + "KB"})

vis.render()
puts vis.to_svg
