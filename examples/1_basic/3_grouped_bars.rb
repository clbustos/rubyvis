# = Using parent
# This example shows how to group bars on groups and use the parent property to identify and color them
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

vis = pv.Panel.new().width(200).height(150);

bar= vis.add(pv.Panel).data(["a","b","c","d"]).add(pv.Bar)
    .data([1,2])
    .width(20)
    .height(lambda {60+parent.index*20+index*5})
    .bottom(0)
    .left(lambda {|d,t| parent.index*60+index*25})
    
 bar.anchor("bottom").add(pv.Label).
   text(lambda {|d,t| "#{t}-#{d}"})
 bar.anchor("top").add(pv.Label).
   text(lambda {"#{parent.index}-#{index}"})
    
    
vis.render()
#puts vis.children_inspect
puts vis.to_svg
