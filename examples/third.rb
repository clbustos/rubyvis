$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

vis = pv.Panel.new().width(200).height(150);

bar= vis.add(pv.Panel).data(["a","b"]).add(pv.Bar)
    .data([1,2])
    .width(20)
    .height(60)
    .bottom(0)
    .left(lambda {|d,t| self.parent.index*60+self.index*30})
    
    
 bar.anchor("bottom").add(pv.Label).text(lambda {|d,t| "#{t}-#{d}"})
 bar.anchor("top").add(pv.Label).text(lambda {"#{self.parent.index}-#{index}"})
    
    
vis.render()
#puts vis.children_inspect
puts vis.to_svg
