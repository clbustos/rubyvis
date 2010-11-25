# = Inheritance and labels
# Second example of Protovis "Getting Started section"
# The rule's label inherits the data and bottom property, causing it to appear on the rule and render the value (datum) as text. The bar’s label uses the bottom anchor to tweak positioning, so that the label is centered at the bottom of the bar. 
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

vis = pv.Panel.new()
.width(150)
.height(200)

vis.add(pv.Rule).
  data(pv.range(0, 2, 0.5)).
  bottom(lambda {|d| d * 80 + 0.5}).
  add(pv.Label).left(0)


vis.add(pv.Bar).
  data([1, 1.2, 1.7, 1.5, 0.7]).
  width(20).height(lambda {|d|  d * 80}).
  bottom(0).
  left(lambda { index * 25 + 25}).
  anchor('bottom').
    add(pv.Label)


vis.render();
puts vis.to_svg

