# = Treemap
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

flare = {
  :a=> {
    :aa=> {
      :aaa=> 2,
      :aab=> 3,
      :aac=> 4
    },
    :ab=> {
      :aba=> 5,
      :abb=> 6,
      :abc=> 8
    }
  },
  :b => {
    :ba =>2,
    :bb =>10
  }
}

def title(d) 
  d.parent_node ? (title(d.parent_node) + "." + d.node_name) : d.node_name
end


re = ""
color = pv.Colors.category19().by(lambda {|d| d.parent_node.node_name})
nodes = pv.dom(flare).root("flare").nodes

vis = pv.Panel.new()
    .width(860)
    .height(568)

treemap = vis.add(pv.Layout.Treemap)
    .nodes(nodes)
    .round(true);

treemap.leaf.add(pv.Panel)
.fill_style(lambda{|d| color(d).alpha(0.2)})
    .stroke_style("#fff")
    .line_width(1)
    .antialias(false)

treemap.label.add(Rubyvis::Label)
.text_style(lambda {|d| pv.rgb(0, 0, 0, 1)})

vis.render();





vis.render
puts vis.to_svg
