# = Crimeam War deaths (Grouped bar)
# Florence Nightingale used a coxcomb diagram to emphasize the number of deaths due to “preventible or mitigable zymotic diseases”. This graph shows data using a stacked bar chart.
$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
require 'ostruct'
load(File.dirname(__FILE__)+"/crimea_data.rb")


w = 545
h = 280
#x = pv.Scale.linear($crimea, lambda {|d| d.date}).range(0, w)

x=pv.Scale.ordinal($crimea, lambda {|d| d.date}).split_banded(0,w,4/5.0)

y = pv.Scale.linear(0, 1500).range(0, h)
k=x.range_band / $causes.size
fill = pv.colors("lightpink", "darkgray", "lightblue")

format = pv.Format.date("%b")



vis = pv.Panel.new()
    .width(w)
    .height(h)
    .margin(19.5)
    .right(40);
    
panel = vis.add(pv.Panel)
    .data($crimea)
    .left(lambda {|d| x.scale(d.date)})
    .width(x.range_band);
    
panel.add(pv.Bar)
    .data($causes)
    .bottom(0)
    .width(k)
    .left(lambda { self.index * k})
    .height(lambda {|t, d| y.scale(d.send(t))})
    .fill_style(lambda {|f| a=fill.scale(self.index); return a})
    .stroke_style(lambda {|d| fill_style ? fill_style.darker : pv.color('black')})
    .line_width(1);

panel.anchor("bottom").add(pv.Label)
.visible(lambda { (self.index % 3)==0})
.text_baseline("top")
    .text_margin(10)
    .text(lambda {|d| format.format(d.date)})
    
  
vis.add(pv.Rule)
    .data(y.ticks())
    .bottom(lambda {|d| y.scale(d)})
    .stroke_style(lambda {|i|  i!=0 ? pv.color("rgba(255, 255, 255, .5)") : pv.color("black")})
  .anchor("right").add(pv.Label)
  .visible(lambda { (self.index & 1)==0})
    .text_margin(6);

vis.render();

puts vis.to_svg
