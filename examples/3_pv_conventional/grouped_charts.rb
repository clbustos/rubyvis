# = Grouped charts
# In this multi-series bar chart, we group bars together rather than stack them. A grouped chart allows accurate comparison of individual values thanks to an aligned baseline: a position, rather than length, judgment is used.
# An ordinal scale positions the groups vertically; the bars are then replicated inside a panel, a technique that is also used for small multiples. 
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

n = 3
m = 4
data = pv.range(n).map {
    pv.range(m).map {
        rand() + 0.1;
      }
}


w = 400
h = 250
x = pv.Scale.linear(0, 1.1).range(0, w)
y = pv.Scale.ordinal(pv.range(n)).split_banded(0, h, 4/5.0);

#/* The root panel. */
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(20)
    .right(10)
    .top(5);

#/* The bars. */

colors=pv.Colors.category20()

bar = vis.add(pv.Panel)
    .data(data)
    .top(lambda {y.scale(self.index)})
    .height(y.range_band)
  .add(pv.Bar)
    .data(lambda {|d| d})
    .top(lambda {self.index * y.range_band / m.to_f})
    .height(y.range_band / m.to_f)
    .left(0)
    .width(x)
    .fillStyle(lambda { colors.scale(self.index)})

#/* The value label. */
bar.anchor("right").add(pv.Label)
    .textStyle("white")
    .text(lambda {|d| "%0.1f" % d});

#/* The variable label. */
bar.parent.anchor("left").add(pv.Label)
    .textAlign("right")
    .textMargin(5)
    .text(lambda {"ABCDEFGHIJK"[self.parent.index,1]});

#/* X-axis ticks. */
vis.add(pv.Rule)
    .data(x.ticks(5))
    .left(x)
    .strokeStyle(lambda {|d| d!=0 ? "rgba(255,255,255,.3)" : "#000"})
  .add(pv.Rule)
    .bottom(0)
    .height(5)
    .strokeStyle("#000")
  .anchor("bottom").add(pv.Label)
    .text(x.tick_format);

vis.render();
puts vis.to_svg
