# = Arc Diagrams
# An arc diagram uses a one-dimensional layout of nodes, with circular arcs to represent links. Though an arc diagram may not convey the overall structure of the graph as effectively as a two-dimensional layout, with a good ordering of nodes it is easy to identify cliques and bridges. Further, as with the indented tree, multivariate data can easily be displayed alongside nodes.
# This network represents character co-occurrence in the chapters of Victor Hugo's classic novel, Les Misérables. Node colors depict cluster memberships computed by a community-detection algorithm. Source: Knuth, D. E. 1993. The Stanford GraphBase: A Platform for Combinatorial Computing, Addison-Wesley. 

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/miserables_data.rb")
c=Rubyvis::Colors.category19()

vis = Rubyvis::Panel.new() do 
  width 880
  height 310
  bottom 90
  layout_arc do
    nodes $miserables.nodes
    links $miserables.links
    sort {|a,b| 
    a.group==b.group ? b.link_degree<=>a.link_degree : b.group <=>a.group}

    link.line
    
    node.dot do
      shape_size {|d| d.link_degree + 4}
      fill_style {|d| c[d.group]}
      stroke_style {|d| c[d.group].darker()}
    end
    
    node_label.label
  end
end
vis.render();
puts vis.to_svg
