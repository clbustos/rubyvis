$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'
vis = Rubyvis::Panel.new.width(150).height(150);

vis.add(pv.Bar).data([1, 1.2, 1.7, 1.5, 0.7, 0.3]).
  width(20).
  height(lambda {|d| d * 80}).
  bottom(0).
  left(lambda {self.index * 25});


=begin
Should generate this
<svg height="150" width="150" stroke-width="1.5" stroke="none" fill="none" font-family="sans-serif" font-size="10px"><g><rect fill="rgb(31,119,180)" height="80" width="20" y="70"></rect><rect fill="rgb(31,119,180)" height="96" width="20" y="54" x="25"></rect><rect fill="rgb(31,119,180)" height="136" width="20" y="14" x="50"></rect><rect fill="rgb(31,119,180)" height="120" width="20" y="30" x="75"></rect><rect fill="rgb(31,119,180)" height="56" width="20" y="94" x="100"></rect><rect fill="rgb(31,119,180)" height="24" width="20" y="126" x="125"></rect></g></svg>
=end
vis.render()
puts vis.canvas.elements[1]
