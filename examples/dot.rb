$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

vis = pv.Panel.new().width(200).height(200);

dot=vis.add(pv.Dot)
    .data([1,2,3,4,5,6])
    .bottom(lambda {|d| return d*30})
    .left(lambda { return 20+self.index*20} )
    .shape_radius(10)
    dot.anchor('top').add(pv.Label).text('a')
    dot.anchor('bottom').add(pv.Label).text('b')
    dot.anchor('left').add(pv.Label).text('l')
    dot.anchor('right').add(pv.Label).text('r')
    

vis.render()
#puts vis.children_inspect
puts vis.to_svg
