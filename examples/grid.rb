# = Grid
# This line chart is constructed a Line mark.
# The second line, inside the first one, is created using an anchor.
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

w = 400
h = 400

vis = pv.Panel.new()
  .width(w)
  .height(h)
  .bottom(20)
  .left(20)
  .right(10)
  .top(5)

  arrays=10.times.map {|i| 10.times.map {|j| i/10.0+j/100.0}}

  vis.add(Rubyvis::Layout::Grid).rows(arrays).
    cell.add(Rubyvis::Bar).
    fill_style(Rubyvis.ramp("white", "black")).
    add(Rubyvis::Label)

vis.render();


puts vis.to_svg
