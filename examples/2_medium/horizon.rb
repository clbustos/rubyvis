# = Horizon
# Horizon graphs increase data density while preserving resolution. 
# While horizon graphs may require learning, they have been found to be more effective than standard line and area plots when chart sizes are small. For more, see "Sizing the Horizon: The Effects of Chart Size and Layering on the Graphical Perception of Time Series Visualizations" by Heer et al., CHI 2009.
# This example shows +offset+ and +mirror+ modes for the quadratic equation x^2-10
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = Rubyvis.range(-5, 5, 0.1).map {|x|
  OpenStruct.new({:x=> x, :y=>  x**2-10})
}



#p data
w = 400
h = 100
x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)
y = pv.Scale.linear(data, lambda {|d| d.y}).range(-50, h*2);

#/* The root panel. */
vis = pv.Panel.new()
  .width(w)
  .height(h*2+20)
  .bottom(20)
  .left(20)
  .right(10)
  .top(5)

types=["offset","mirror"]


pan=vis.add(Rubyvis::Panel).
data(types).
height(80).
top(lambda { index*110+30})
pan.add(Rubyvis::Rule).
  data(x.ticks).
  left(x).
  anchor("bottom").
  add(Rubyvis::Label).
  text(x.tick_format)
  
  
pan.add(Rubyvis::Layout::Horizon)
         .bands(3)
         .mode(lambda {|d| d})         
       .band.add(Rubyvis::Area)
         .data(data)
         .left(lambda {|d| x[d.x]})
         .height(lambda {|d| y[d.y]})
     
pan.anchor("top").add(Rubyvis::Label)
.top(-15)

vis.render();


puts vis.to_svg
