# = First example (Protovis API)
# This is the protovis API version of "Getting Started" example of Protovis introduction.
# On this example we  build a bar chart using panel and bar marks.
# A mark represents a set of graphical elements that share data and visual encodings. Although marks are simple by themselves, you can combine them in interesting ways to make rich, interactive visualizations
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
vis = Rubyvis::Panel.new.width(150).height(150);

vis.add(pv.Bar).data([1, 1.2, 1.7, 1.5, 0.7, 0.3]).
  width(20).
  height(lambda {|d| d * 80}).
  bottom(0).
  left(lambda {index * 25})

vis.render()
puts vis.to_svg
