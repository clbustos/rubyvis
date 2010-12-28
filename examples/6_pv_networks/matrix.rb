# = Arc Diagrams
# An arc diagram uses a one-dimensional layout of nodes, with circular arcs to represent links. Though an arc diagram may not convey the overall structure of the graph as effectively as a two-dimensional layout, with a good ordering of nodes it is easy to identify cliques and bridges. Further, as with the indented tree, multivariate data can easily be displayed alongside nodes.
# This network represents character co-occurrence in the chapters of Victor Hugo's classic novel, Les Misérables. Node colors depict cluster memberships computed by a community-detection algorithm. Source: Knuth, D. E. 1993. The Stanford GraphBase: A Platform for Combinatorial Computing, Addison-Wesley. 

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/miserables_data.rb")
color=Rubyvis::Colors.category10()

$miserables=OpenStruct.new({:nodes=>[
    OpenStruct.new({:node_value=>"A", :group=>1}),
    OpenStruct.new({:node_value=>"B", :group=>1}),
    OpenStruct.new({:node_value=>"C", :group=>1}),
    OpenStruct.new({:node_value=>"D", :group=>1})
    
    ],
    :links=>[
    OpenStruct.new({:source=>1, :target=>0, :value=>1})
   
    ]
    
})

vis = Rubyvis::Panel.new() do 
  width 693
  height 693
  bottom 90
  left 90
  layout_matrix do
    nodes $miserables.nodes
    links $miserables.links
    sort {|a,b| a.group<=>b.group }
    link.bar do
      fill_style {|l| l.link_value!=0 ? ((l.target_node.group == l.source_node.group) ? color[l.source_node] : "#555") : "#eee"}
      antialias(false)
      line_width(1)
    end
    node_label.label do 
      text_style(color)
    end
  end
end
vis.render();
puts vis.to_svg
