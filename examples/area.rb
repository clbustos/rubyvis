# = Area Charts
# This simple area chart is constructed using an area mark, with an added line for emphasis on the top edge. Next, rules and labels are added for reference values.
# Although this example is basic, it provides a good starting point for adding more complex features. For instance, mouseover interaction can be added to allow precise reading of data values. Or multiple series of data can be added to produce a stacked area chart. 
# Protovis version: http://vis.stanford.edu/protovis/ex/area.html
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

data = pv.range(0, 10, 0.1).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+ rand()})
}


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
    .top(5)

# Y-axis and ticks.
vis.add(pv.Rule)
    .data(y.ticks(5))
    .bottom(y)
    .stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"})
  .anchor("left").add(pv.Label)
  .text(y.tick_format)

# X-axis and ticks.
vis.add(pv.Rule)
    .data(x.ticks())
    .visible(lambda {|d| d!=0})
    .left(x)
    .bottom(-5)
    .height(5)
    .anchor("bottom").add(pv.Label)
  .text(x.tick_format)

#/* The area with top line. */
vis.add(pv.Area)
    .data(data)
    .bottom(1)
    .left(lambda {|d| x.scale(d.x)})
    .height(lambda {|d| y.scale(d.y)})
    .fill_style("rgb(121,173,210)")
  .anchor("top").add(pv.Line)
  .line_width(3)

vis.render();


puts vis.to_svg
