# = Parallel Coordinates
# Parallel coordinates is a popular method of visualizing high-dimensional data using dynamic queries. 

$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/cars_data.rb")

dims = [
  :cylinders,
  :displacement,
  :weight,
  :horsepower,
  :acceleration,
  :mpg,
  :year,
  :origin
];

# Sizing and scales. */
w = 840
h = 420
color = Rubyvis.Colors.category10()
x = Rubyvis.Scale.ordinal(dims).split_flush(0, w)
y = Rubyvis.dict(dims, lambda {|t|
    Rubyvis.Scale.linear().
      domain($cars.find_all {|d| !d[t].nil?} ,
        lambda {|d| d[t]}).range(0, h)
    })

#/* The root panel. */
vis=Rubyvis::Panel.new do 
  width w 
  height h 
  margin 20 
  bottom 40 
  # Rule and labels per dimension
  rule do 
    data(dims)
    left(x)
    stroke_style(lambda {|d| color.scale(index)})
    line_width(2)
    # Min value
    label(:anchor=>'top') do
      text {|t|
        y[t].tick_format.call(y[t].domain()[0])
      }
    end
    # Max value
    label(:anchor=>'bottom') do
      text {
        |t| y[t].tick_format.call(y[t].domain()[1])
      }
    end
    # Dim name
    label(:anchor=>'bottom') do
      text_style {color.scale(index).darker}
      text_margin 14
    end
  end
  # Parallel coordinates.
  panel do
    # Each cars generate a panel
    data($cars)
    line do
      # Inside each car, every dims generate a
      # point
      data(dims)
      left {|t,d| x.scale(t)}
      bottom {|t,d|  y[t].scale(d[t])}
      stroke_style("rgba(0, 0, 0, 0.2)")
      line_width(1)
    end
  end
end


vis.render()
puts vis.to_svg
