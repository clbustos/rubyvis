# = Bar & Column Charts
# This simple bar chart is constructed using a bar mark. A linear scale is used to compute the width of the bar, while an ordinal scale sets the top position and height for the categorical dimension. Next, rules and labels are added for reference values.
# Bars can be used in a variety of ways. For instance, they can be stacked or grouped to show multiple data series, or arranged as vertical columns rather than bars. 

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = pv.range(10).map {|d| rand + 0.1 }



#/* Sizing and scales. *
w = 400
h = 250
x = pv.Scale.linear(0, 1.1).range(0, w)
y = pv.Scale.ordinal(pv.range(10)).split_banded(0, h, 4/5.0)

#/* The root panel. */
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(20)
    .right(10)
    .top(5);

#/* The bars. */
bar = vis.add(pv.Bar)
    .data(data)
    .top(lambda { y.scale(self.index)})
    .height(y.range_band)
    .left(0)
    .width(x)

#/* The value label. */
bar.anchor("right").add(pv.Label)
    .text_style("white")
    .text(lambda {|d| "%0.1f" % d})

#/* The variable label. */
bar.anchor("left").add(pv.Label)
    .text_margin(5)
    .text_align("right")
    .text(lambda { "ABCDEFGHIJK"[self.index,1]});
 
#/* X-axis ticks. */
vis.add(pv.Rule)
    .data(x.ticks(5))
    .left(x)
    .stroke_style(lambda {|d|  d!=0 ? "rgba(255,255,255,.3)" : "#000"})
  .add(pv.Rule)
    .bottom(0)
    .height(5)
    .stroke_style("#000")
  .anchor("bottom").add(pv.Label)
  .text(x.tick_format);

vis.render();
puts vis.to_svg
