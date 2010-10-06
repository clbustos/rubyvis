$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'
vis = Rubyvis::Panel.new.width(150).height(150);

vis.add(pv.Bar).data([1, 1.2, 1.7, 1.5, 0.7, 0.3]).
  width(20).
  height(lambda {|d| d * 80}).
  bottom(0).
  left(lambda {index * 25})

vis.render()
puts vis.to_svg
