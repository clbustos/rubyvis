# = Scatterplot
# Scatterplots can facilitate visual analysis along multiple dimensions, though care should be taken to avoid interference. In this example, we encode three dimensions: two are encoded using position, while the third is redundantly encoded as both area and color. 
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
data = pv.range(100).map {|x| 
  OpenStruct.new({x: x, y: rand(), z: 10**(2*rand)})
}


w = 400
h = 400

x = pv.Scale.linear(0, 99).range(0, w)
y = pv.Scale.linear(0, 1).range(0, h)

c = pv.Scale.log(1, 100).range("orange", "brown")

# The root panel.
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(20)
    .right(10)
    .top(5);

# Y-axis and ticks. 
vis.add(pv.Rule)
    .data(y.ticks())
    .bottom(y)
    .strokeStyle(lambda {|d| d!=0 ? "#eee" : "#000"})
  .anchor("left").add(pv.Label)
  .visible(lambda {|d|  d > 0 and d < 1})
  .text(y.tick_format)

# X-axis and ticks. 
vis.add(pv.Rule)
    .data(x.ticks())
    .left(x)
    .stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"})
  .anchor("bottom").add(pv.Label)
  .visible(lambda {|d|  d > 0 and d < 100})
  .text(x.tick_format);

#/* The dot plot! */
vis.add(pv.Panel)
    .data(data)
  .add(pv.Dot)
  .left(lambda {|d| x.scale(d.x)})
  .bottom(lambda {|d| y.scale(d.y)})
  .stroke_style(lambda {|d| c.scale(d.z)})
  .fill_style(lambda {|d| c.scale(d.z).alpha(0.2)})
  .shape_size(lambda {|d| d.z})
  .title(lambda {|d| "%0.1f" % d.z})

vis.render()
puts vis.to_svg
