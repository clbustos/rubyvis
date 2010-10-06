$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

vis = pv.Panel.new()
.width(150)
.height(200)

vis.add(pv.Rule).data(pv.range(0, 2, 0.5)).bottom(lambda {|d| d * 80 + 0.5}).add(pv.Label).left(0)


vis.add(pv.Bar).data([1, 1.2, 1.7, 1.5, 0.7]).width(20).height(lambda {|d|  d * 80}).bottom(0).left(lambda { self.index * 25 + 25}).anchor('bottom').add(pv.Label)


vis.render();
puts vis.to_svg

