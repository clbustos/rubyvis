# = Grid
# A simple heatmap, using a Bar.fill_style to represent
# data
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

w = 400
h = 400

vis = pv.Panel.new()
  .width(w)
  .height(h)
  .bottom(0)
  .left(0)
  .right(0)
  .top(0)

  arrays=10.times.map {|i| 10.times.map {|j| i/10.0+j/100.0}}

  vis.add(Rubyvis::Layout::Grid).rows(arrays).
    cell.add(Rubyvis::Bar).
    fill_style(Rubyvis.ramp("white", "black")).anchor("center").
    add(Rubyvis::Label).
    text_style(Rubyvis.ramp("black","white"))

vis.render();


puts vis.to_svg
