$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

vis = pv.Panel.new().width(400).height(150);

vis.add(pv.Panel).data([1,2]).add(pv.Bar)
    .data([3,4])
    .width(20)
    .height(lambda {|d|  d * 20})
    .bottom(0)
    .left(lambda {|d,t| t*60+self.index*30}).add(pv.Label).text(lambda {|d,t| "#{t}-#{d}"})

    vis.add(pv.Panel).left(200).data([1,2]).add(pv.Bar)
    .data([3,4])
    .width(20)
    .height(lambda {|d|  d * 20})
    .bottom(0)
    .left(lambda {|d,t| t*60+self.index*30}).add(pv.Label).text(lambda {|d,t| "#{t}-#{d}"})
    

vis.render()
#puts vis.children_inspect
puts vis.to_svg
