# = Stacked Area
# This example uses the Stack layout to stack areas one over another.
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = pv.range(4).map {|i|
  pv.range(0, 10, 0.1).map {|x|
    OpenStruct.new({:x=> x, :y=> Math.sin(x) + rand() * 0.5 + 2})
  }
}

w = 400
h = 200

x = pv.Scale.linear(0, 9.9).range(0, w)
y = pv.Scale.linear(0, 14).range(0, h)

#/* The root panel. */
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(20)
    .right(10)
    .top(5)
#/* X-axis and ticks. */
vis.add(pv.Rule)
    .data(x.ticks())
    .visible(lambda {|d| d!=0})
    .left(x)
    .bottom(-5)
    .height(5)
  .anchor("bottom").add(pv.Label)
  .text(x.tick_format)
#/* Y-axis and ticks. */
vis.add(pv.Rule)
    .data(y.ticks(3))
    .bottom(y)
    .strokeStyle(lambda {|d|  d!=0 ? "rgba(128,128,128,.2)" : "#000"})
  .anchor("left").add(pv.Label)
  .text(y.tick_format)
#/* The stack layout. */
vis.add(pv.Layout.Stack)
    .layers(data)
    .x(lambda {|d| x.scale(d.x)})
    .y(lambda {|d| y.scale(d.y)})
  .layer.add(pv.Area)

vis.render();
puts vis.to_svg
