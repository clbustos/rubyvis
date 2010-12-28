# = Arc Diagrams
# An arc diagram uses a one-dimensional layout of nodes, with circular arcs to represent links. Though an arc diagram may not convey the overall structure of the graph as effectively as a two-dimensional layout, with a good ordering of nodes it is easy to identify cliques and bridges. Further, as with the indented tree, multivariate data can easily be displayed alongside nodes.
# This network represents character co-occurrence in the chapters of Victor Hugo's classic novel, Les Misérables. Node colors depict cluster memberships computed by a community-detection algorithm. Source: Knuth, D. E. 1993. The Stanford GraphBase: A Platform for Combinatorial Computing, Addison-Wesley. 

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/miserables_data.rb")
color=Rubyvis::Colors.category19()


vis = Rubyvis::Panel.new() do 
  width 693
  height 693
  top 90
  left 90
  layout_matrix do
    nodes $miserables.nodes
    links $miserables.links
    sort {|a,b| b.group<=>a.group }
    directed (false)
    link.bar do
      fill_style {|l| l.link_value!=0 ? ((l.target_node.group == l.source_node.group) ? color[l.source_node.group] : "#555") : "#eee"}
      antialias(false)
      line_width(1)
    end
    node_label.label do 
      text_style {|l| color[l.group]}
    end
  end
end
vis.render();
puts vis.to_svg
