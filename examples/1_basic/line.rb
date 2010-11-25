# = Line Chart
# This line chart is constructed a Line mark.
# The second line, inside the first one, is created using an anchor.
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = pv.range(0, 10, 0.1).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+rand()})
}

#p data
w = 400
h = 200
x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)


y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, h);

#/* The root panel. */
vis = pv.Panel.new()
  .width(w)
  .height(h)
  .bottom(20)
  .left(20)
  .right(10)
  .top(5)

vis.add(pv.Line).
  data(data).
  line_width(5).
  left(lambda {|d| x.scale(d.x)}).
  bottom(lambda {|d| y.scale(d.y)}).
  anchor("bottom").add(pv.Line).
    stroke_style('red').
    line_width(1)
     

vis.render();


puts vis.to_svg
