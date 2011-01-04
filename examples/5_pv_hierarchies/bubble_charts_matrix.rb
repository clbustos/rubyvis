# = Bubble charts matrix
# 
# Why have one boring bubble chart when 
# you can have 20 multicolor charts?
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

panes=20
cols=2


p_w=200
p_h=150
#p data
w = 20+p_w*cols
h = (panes/cols)*10+p_h*(panes/cols)

colors20=Rubyvis::Colors.category20()
c20=Rubyvis::Colors.category20().by(lambda {|n| n.parent_node}) 
vis = pv.Panel.new()
  .width(w)
  .height(h)
  .bottom(5)
  .left(5)
  .right(5)
  .top(5)



(0..panes).each do |i|
  n=i%cols
  m=(i/cols.to_f).floor
  panel=vis.add(Rubyvis::Panel).
  left(n*(p_w+10)).
  top(m*(p_h+10)).
  width(p_w).
  height(p_h)

  d=Rubyvis.nodes((i+1).times.map {|ii| rand(5)+1})
  
  
  panel.anchor('top').add(Rubyvis::Label).text("n#{i+1}") 
  
  pack=panel.add(pv.Layout.Pack).
    nodes(d).
    size(lambda {|n| n.node_value})
  
  pack.node.add(Rubyvis::Dot).
    visible( lambda {|n| n.parent_node}).
    fill_style(lambda {|n|
      colors20.scale(n.parent_node).
        brighter((n.node_value) / 5.0)
    }).
    stroke_style(c20)
  
  pack.node_label.add(Rubyvis::Label).
    visible( lambda {|n| n.parent_node}).
    text(lambda {index})
  
end

vis.render();
puts vis.to_svg

