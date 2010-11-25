# = Antibiotic Effectiveness : Scatterplot
# After World War II, antibiotics earned the moniker “wonder drugs” for quickly treating previously-incurable diseases. Data was gathered to determine which drug worked best for each bacterial infection. Comparing drug performance was an enormous aid for practitioners and scientists alike. In the fall of 1951, Will Burtin published this graph showing the effectiveness of three popular antibiotics on 16 different bacteria, measured in terms of minimum inhibitory concentration.
# Recreating this display revealed some minor errors in the original: a missing grid line at 0.01 μg/ml, and an exaggeration of some values for penicillin. 
$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/antibiotics_data.rb")

s = 180
_p = 20
z = pv.Scale.log(0.001, 1000).range(0, s)
color = pv.colors("darkred", "darkblue")
ticks = pv.range(-2, 3).map {|e| (10**e).to_f}

#/* Root panel. */
vis = Rubyvis::Panel.new
    .height(s * $antibiotics.size+ _p * ($antibiotics.size- 1))
    .width(lambda {self.height()})
    .top(14.5)
    .left(14.5)
    .bottom(44)
    .right(14);

#/* Cell for each antibiotic pair. */
cell = vis.add(pv.Panel)
    .data($antibiotics)
    .width(s)
    .left(lambda {(s + _p) * self.index})
  .add(pv.Panel)
    .data($antibiotics)
    .height(s)
    .top(lambda{(s + _p) * self.index})

#/* Label. */
cell.anchor("center").add(pv.Label)
.visible(lambda {|d,y, x| return  x == y})
    .font("bold 14px sans-serif")
    .text(lambda {|d, y, x| x});

#/* Dot plot and frame. */
plot = cell.add(pv.Panel)
    .data(lambda {|y, x| [x]})
    .visible(lambda {|x, y| x != y})
    .stroke_style("#aaa");

#/* Ticks. */
tick = pv.Rule.new()
    .visible(lambda {|d, x, y| x != y})
    .data(ticks)
    .stroke_style("#ddd");

#/* X-axis ticks. */
xtick = plot.add(pv.Rule)
    .mark_extend(tick)
    .left(z);

#/* Bottom and top labels. */
xtick.anchor("bottom").add(pv.Label)
    .visible(lambda {cell.index == $antibiotics.size- 1});
xtick.anchor("top").add(pv.Label)
    .visible(lambda {cell.index == 0});

#/* Y-axis ticks. */
ytick = plot.add(pv.Rule)
    .mark_extend(tick)
    .bottom(z);

#/* Bottom and top labels. */
ytick.anchor("right").add(pv.Label)
    .visible(lambda {cell.parent.index == $antibiotics.size- 1})
    .text_angle(Math::PI / 2.0)
    .text_baseline("bottom")
    .text_align("center");
ytick.anchor("left").add(pv.Label)
    .visible(lambda {cell.parent.index == 0})
    .text_angle(-Math::PI / 2.0)
    .text_baseline("bottom")
    .text_align("center");

#/* Dot plot. */
dot = plot.add(pv.Dot).
  data($bacteria).
  stroke_style(lambda { |d|
    color.scale(d[:gram])
  }).
  fill_style(lambda {|d|
    color.scale(d[:gram]).alpha(0.2)
  }).
  left(lambda {|d, x, y|
    z.scale(d[x.to_sym])
  }).
  bottom(lambda {|d, x, y|
    z.scale(d[y.to_sym])
  }).
  title(lambda {|d| d[:name]})

#/* Legend. */
vis.add(pv.Dot)
    .mark_extend(dot)
    .data([{gram:"positive"}, {gram:"negative"}])
    .bottom(-30)
    .left(lambda { index * 100})
    .title(nil)
  .anchor("right").add(pv.Label)
    .text(lambda {|d| "Gram-" + d[:gram]});

vis.render();
puts vis.to_svg
