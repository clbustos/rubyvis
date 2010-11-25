# = Area Interpolation
# This example show the 5 types of interpolation available for areas:
# * linear
# * step-before
# * step-after
# * basis
# * cardinal
# 
# See also "Line Interpolation":line_interpolation.html
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = Rubyvis.range(0, 10, 0.5).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+rand()*0.3})
}

p_w=200
p_h=150
#p data
w = 20+p_w*2
h = 20+p_h*3

x = Rubyvis.Scale.linear(data, lambda {|d| d.x}).range(0, p_w-30)
y = Rubyvis.Scale.linear(data, lambda {|d| d.y}).range(0, p_h-20);
interpolations=["linear","step-before","step-after", "basis", "cardinal"]

vis = Rubyvis::Panel.new do |pan|
  pan.width w 
  pan.height h 
  pan.bottom 20 
  pan.left 20 
  pan.right 10 
  pan.top 5 

  interpolations.each_with_index do |inter,i|
    n=i%2
    m=(i/2).floor
    pan.panel do
      left(n*(p_w+10))
      top(m*(p_h+10))
      width p_w
      height p_h
      label(:anchor=>'top') do
        text(inter)
      end
      # uses 'a' as reference inside block
      # to use data method with data variable
      area do |a| 
        a.data data
        a.left {|d| x.scale(d.x)}
        a.height {|d| y.scale(d.y)}
        a.bottom 1
        a.interpolate inter
      end
    end
  end
end  
     

vis.render();


puts vis.to_svg
