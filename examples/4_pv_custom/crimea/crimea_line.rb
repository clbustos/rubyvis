# = Crimeam War deaths (Grouped bar)
# Florence Nightingale used a coxcomb diagram to emphasize the number of deaths due to “preventible or mitigable zymotic diseases”. This graph shows data using a line chart.

$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
require 'ostruct'
load(File.dirname(__FILE__)+"/crimea_data.rb")


w = 545
h = 280
#x = pv.Scale.linear($crimea, lambda {|d| d.date}).range(0, w)
x=pv.Scale.linear(Time.utc(1854,4), Time.utc(1856,3)).range(0, w)
y = pv.Scale.linear(0, 1500).range(0, h)
fill = pv.colors("lightpink", "darkgray", "lightblue")
format = pv.Format.date("%b")


vis = pv.Panel.new()
    .width(w)
    .height(h)
    .margin(19.5)
    .right(40);
vis.add(pv.Panel)
    .data($causes)
  .add(pv.Line)
    .data($crimea)
    .left(lambda {|d|  x.scale(d.date)})
    .bottom(lambda {|d,t|   y.scale(d.send(t))})
    .stroke_style(fill.by(pv.parent))
    .line_width(3)

vis.add(pv.Label)
    .data(x.ticks())
    .left(lambda {|d| x.scale(d)})
    .bottom(0)
    .text_baseline("top")
    .text_margin(5)
    .text(pv.Format.date("%b").format_lambda);

vis.add(pv.Rule)
    .data(y.ticks())
    .bottom(lambda {|d| y.scale(d)})
    .stroke_style(lambda {|i|  i!=0 ? pv.color("#ccc") : pv.color("black")})
  .anchor("right").add(pv.Label)
  .visible(lambda { (self.index & 1)==0})
    .text_margin(6);
    vis.render();

puts vis.to_svg
