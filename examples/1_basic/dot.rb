# = Dot and anchors
# This example shows how looks differents positions of anchors on dots
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

vis = pv.Panel.new().width(200).height(200);

dot=vis.add(pv.Dot)
    .data([1,2,3,4,5,6])
    .bottom(lambda {|d| d*30})
    .left(lambda { 20+index*40} )
    .shape_radius(10)
    %w{top bottom left right center}.each do |dir|
      dot.anchor(dir).add(pv.Label).text(dir[0,1])
    end
vis.render()
#puts vis.children_inspect
puts vis.to_svg
