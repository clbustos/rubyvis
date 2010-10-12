$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

data = pv.range(0, 10, 0.2).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + rand() + 1.5})
}


vis = pv.Panel.new().width(200).height(200);


w = 400
h = 200
x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)
  
y = pv.Scale.linear(0, 4).range(0, h);

#/* The root panel. */
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(20)
    .right(10)
    .top(5);

#/* X-axis ticks. */
vis.add(pv.Rule)
    .data(x.ticks())
    .visible(lambda {|d|  d > 0})
    .left(x)
    .strokeStyle("#eee")
  .add(pv.Rule)
    .bottom(-5)
    .height(5)
    .strokeStyle("#000")
  .anchor("bottom").add(pv.Label)
  .text(x.tick_format)

#/* Y-axis ticks. */
vis.add(pv.Rule)
    .data(y.ticks(5))
    .bottom(y)
    .strokeStyle(lambda {|d| d!=0 ? "#eee" : "#000"})
  .anchor("left").add(pv.Label)
  .text(y.tick_format);

#/* The line. */
vis.add(pv.Line)
    .data(data)
    .interpolate("step-after")
    .left(lambda {|d| x.scale(d.x)})
    .bottom(lambda {|d| y.scale(d.y)})
    .lineWidth(3);

vis.render();


    

puts vis.to_svg
