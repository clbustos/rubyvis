# = Becker’s Barley
# The "Trellis display":http://www.jstor.org/stable/1390777 by Becker et al. helped establish small multiples as a “powerful mechanism for understanding interactions in studies of how a response depends on explanatory variables”. Here we reproduce a trellis of Barley yields from the 1930s, complete with main-effects ordering to facilitate comparison. These examples demonstrate Protovis’ support for data transformation via the nest operator.
# Notice anything unusual about one of the sites? This anomaly led Becker et al. to suspect a major error with the data that went undetected for six decades. 

$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/barley_data.rb")
# Nest yields data by site then year. */

# Compute yield medians by site and by variety. */
median=lambda {|data| 
       pv.median(data, lambda {|d| d[:yield]}) 
       }

site = pv.nest($barley).
       key(lambda {|d| d[:site]}).
       rollup(median)

variety = pv.nest($barley).key(lambda {|d| d[:variety]}).rollup(median);


barley = pv.nest($barley)
    .key(lambda {|d| d[:site]})
    .sort_keys(lambda {|a, b| site[b] - site[a]})
    .key(lambda {|d| d[:year]})
    .sort_values(lambda {|a, b| variety[b[:variety]] - variety[a[:variety]]})
    .entries()

# Sizing and scales. */
w = 332
h = 132
x = pv.Scale.linear(10, 90).range(0, w)
c = pv.Colors.category10()

# The root panel. */
vis = Rubyvis::Panel.new
    .width(w)
    .height(h * pv.keys(site).size)
    .top(15.5)
    .left(0.5)
    .right(0.5)
    .bottom(25);

# A panel per site-year. */
cell = vis.add(pv.Panel)
    .data(barley)
    .height(h)
    .left(90)
    .top(lambda { self.index * h})
    .stroke_style(pv.color("#999"));

# Title bar. */
cell.add(pv.Bar)
    .height(14)
    .fill_style("bisque")
  .anchor("center").add(pv.Label)
  .text(lambda{|site| site.key});

# A dot showing the yield. */
dot = cell.add(pv.Panel)
.data(lambda {|site| site.values})
    .top(23)
  .add(pv.Dot)
  .data(lambda {|year| year.values})
  .left(lambda {|d| x.scale(d[:yield])})
    .top(lambda {self.index * 11})
    .shape_size(10)
    .line_width(2)
    .stroke_style(lambda {|d| c.scale(d[:year])})

# A label showing the variety. */
dot.anchor("left").add(pv.Label)
  .visible(lambda { self.parent.index!=0})
  .left(-2)
  .text(lambda {|d| d[:variety]})

# X-ticks. */
vis.add(pv.Rule)
    .data(x.ticks())
    .left(lambda {|d|  90+x.scale(d)})
    .bottom(-5)
    .height(5)
    .stroke_style("#999")
  .anchor("bottom").add(pv.Label);

# A legend showing the year. */
vis.add(pv.Dot)
    .mark_extend(dot)
    .data([{:year=>1931}, {:year=>1932}])
    .left(lambda {|d| 260 + self.index * 40})
    .top(-8)
  .anchor("right").add(pv.Label)
  .text(lambda {|d| d[:year]})

vis.render()

puts vis.to_svg