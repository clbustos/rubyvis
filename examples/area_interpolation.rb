# = Area Interpolation
# This example show the 5 types of interpolation available for areas.
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

data = pv.range(0, 10, 0.5).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+rand()*0.3})
}

p_w=200
p_h=150
#p data
w = 20+p_w*2
h = 20+p_h*3

x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, p_w-30)


y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, p_h-20);

interpolations=["linear","step-before","step-after", "basis", "cardinal"]

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
  panel.add(Rubyvis::Area).data(data).
  left(lambda {|d| x.scale(d.x)}).
  height(lambda {|d| y.scale(d.y)}).
  bottom(1).
  interpolate(inter)
  
end
  
  
     

vis.render();


puts vis.to_svg
