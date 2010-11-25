# = Line Interpolation
# This example show the 7 types of interpolation available for lines:
# * linear
# * step-before
# * step-after
# * polar
# * polar-reverse
# * basis
# * cardinal
# 
# See also "Area Interpolation":area_interpolation.html
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = pv.range(0, 10, 1).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+rand()*0.2})
}

p_w=200
p_h=150
#p data
w = 20+p_w*2
h = 20+p_h*4

x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, p_w-30)


y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, p_h-20);

interpolations=["linear","step-before","step-after","polar","polar-reverse", "basis", "cardinal"]

#/* The root panel. */
vis = pv.Panel.new()
  .width(w)
  .height(h)
  .bottom(20)
  .left(20)
  .right(10)
  .top(5)

interpolations.each_with_index do |inter,i|
  n=i%2
  m=(i/2).floor
  panel=vis.add(Rubyvis::Panel).
  left(n*(p_w+10)).
  top(m*(p_h+10)).
  width(p_w).
  height(p_h)
  panel.anchor('top').add(Rubyvis::Label).text(inter)
  panel.add(Rubyvis::Line).data(data).
  line_width(2).
  left(lambda {|d| x.scale(d.x)}).
  bottom(lambda {|d| y.scale(d.y)}).
  interpolate(inter)
  
end
  
  
     

vis.render();


puts vis.to_svg
