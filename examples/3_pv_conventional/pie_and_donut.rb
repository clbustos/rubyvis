$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

# Sizing and scales. */

data = pv.range(10).map {rand()}


w = 400
h = 400

r = w / 2.0

a = pv.Scale.linear(0, pv.sum(data)).range(0, 2 * Math::PI)

#/* The root panel. */
vis = pv.Panel.new()
    .width(w)
    .height(h);
#/* The wedge, with centered label. */

vis.add(pv.Wedge)
    .data(data.sort(&pv.reverse_order))
    .bottom(w / 2.0)
    .left(w / 2.0)
    .innerRadius(r - 40)
    .outerRadius(r)
    .angle(a)
    .event("mouseover", lambda {self.inner_radius(0)})
    .event("mouseout", lambda{ self.inner_radius(r - 40)})
  .anchor("center").add(pv.Label)
  .visible(lambda {|d|  d > 0.15})
    .textAngle(0)
    .text(lambda {|d| "%0.2f" %  d});

vis.render();

puts vis.to_svg
