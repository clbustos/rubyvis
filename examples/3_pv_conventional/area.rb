# = Area Charts
# This simple area chart is constructed using an area mark, with an added line for emphasis on the top edge. Next, rules and labels are added for reference values.
# Although this example is basic, it provides a good starting point for adding more complex features. For instance, multiple series of data can be added to produce a stacked area chart. 
# * "Protovis version":http://vis.stanford.edu/protovis/ex/area.html
# * Syntax: RBP
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'

data = pv.range(0, 10, 0.1).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+ rand()})
}


w = 400
h = 200
x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)


y = pv.Scale.linear(0, 4).range(0, h);

#The root panel
vis = pv.Panel.new() do
  width w
  height h
  bottom 20
  left 20
  right 10
  top 5

# Y-axis and ticks
  rule do
    data y.ticks(5)
    bottom(y)
    stroke_style {|d| d!=0 ? "#eee" : "#000"}
    label(:anchor=>"left") {
      text y.tick_format
    }
  end
  
# X-axis and ticks.
  rule do
    data x.ticks()
    visible {|d| d!=0}
    left(x)
    bottom(-5)
    height(5)
    label(:anchor=>'bottom') {
      text(x.tick_format)
    }
  end

#/* The area with top line. */
  area do |a|
    a.data data
    a.bottom(1)
    a.left {|d| x.scale(d.x)}
    a.height {|d| y.scale(d.y)}
    a.fill_style("rgb(121,173,210)")
    a.line(:anchor=>'top') {
      line_width(3)
    }
  end
end
vis.render();


puts vis.to_svg
