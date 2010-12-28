# = Matrix Diagrams
# A graph can be represented by an adjacency matrix, where each value in row i and column j corresponds to the link from node i to node j. Given this representation, an obvious visualization then is: show the matrix! Using color or saturation instead of text allows patterns to be perceived rapidly. The seriation problem applies just as much to the matrix view as to the arc diagram, so the order of rows and columns is important: here we use a community-detection algorithm to order and color the display.
# While path following is harder in a matrix view than in a node-link diagram, matrices have a number of compensating advantages. As networks get large and highly connected, node-link diagrams often devolve into giant hairballs of line crossings. In matrix views, however, line crossings are impossible, and with an effective sorting one quickly can spot clusters and bridges. Allowing interactive grouping and reordering of the matrix facilitates deeper exploration of network structure.
# This network represents character co-occurrence in the chapters of Victor Hugo's classic novel, Les Misérables. Node colors depict cluster memberships computed by a community-detection algorithm. Source: Knuth, D. E. 1993. The Stanford GraphBase: A Platform for Combinatorial Computing, Addison-Wesley. 

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/miserables_data.rb")
color=Rubyvis::Colors.category19


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
      fill_style {|l| l.link_value!=0 ?
       ((l.target_node.group == l.source_node.group) ? color[l.source_node.group] : "#555") : "#eee"}
      antialias(false)
      line_width(1)
    end
    node_label.label do 
      text_style {|l| color[l.group]}
    end
  end
end
vis.render()
puts vis.to_svg
