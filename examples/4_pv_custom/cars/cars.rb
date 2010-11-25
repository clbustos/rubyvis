# = Parallel Coordinates
# Parallel coordinates is a popular method of visualizing high-dimensional data using dynamic queries. 
# On static setting, you could choose an attribute and colour each datum which belongs to an attribute differently. On this example, we choose to color :cylinders attribute and highlight the cars with 8 cylinders

$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/cars_data.rb")
attr_to_color=:cylinders
highlighted=lambda {|d|
  d[:cylinders].to_i==8
}

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
car_color = Rubyvis.Colors.category10()
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
    label(:anchor=>'bottom') do
      text {|t|
        y[t].tick_format.call(y[t].domain()[0])
      }
    end
    # Max value
    label(:anchor=>'top') do
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
    # Each car generate a panel
    data($cars)
    line do
      # Inside each car, every dimension generate a point
      data(dims)
      left {|t, d| x.scale(t)}
      bottom {|t, d|  y[t].scale(d[t])}
      line_width {|t,d| 
        highlighted.call(d) ? 4 : 1
      }
      stroke_style {|t,d|
        # Highlighted items will be opaquer
        alpha=highlighted.call(d) ? 0.4 : 0.1
        car_color.scale(d[attr_to_color]).alpha(alpha)
      }
      line_width(1)
    end
  end
end


vis.render()
puts vis.to_svg
