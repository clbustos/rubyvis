# = Antibiotic Effectiveness : Pie chart
# After World War II, antibiotics earned the moniker “wonder drugs” for quickly treating previously-incurable diseases. Data was gathered to determine which drug worked best for each bacterial infection. Comparing drug performance was an enormous aid for practitioners and scientists alike. In the fall of 1951, Will Burtin published this graph showing the effectiveness of three popular antibiotics on 16 different bacteria, measured in terms of minimum inhibitory concentration.
# Recreating this display revealed some minor errors in the original: a missing grid line at 0.01 μg/ml, and an exaggeration of some values for penicillin.
$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/antibiotics_data.rb")

width = 700
height = 700
inner_radius = 90
outer_radius = 300 - 10

drug_color = {
  :penicillin=> "rgb(10, 50, 100)",
  :streptomycin=> "rgb(200, 70, 50)",
  :neomycin=> "black"
}
gram_color = {
  :positive=> "rgba(174, 174, 184, .8)",
  :negative=> "rgba(230, 130, 110, .8)"
}

# Burtin's radius encoding is, as far as I can tell, sqrt(log(mic)).
min = Math.sqrt(Math.log(0.001 * 1e4))
max = Math.sqrt(Math.log(1000 * 1e4))
a = (outer_radius - inner_radius) / (min - max.to_f)
b = inner_radius - a * max

radius = lambda {|mic| a * Math.sqrt(Math.log(mic * 1e4)) + b}

# The pie is split into equal sections for each bacteria, with a blank
# section at the top for the grid labels. Each wedge is further
# subdivided to make room for the three antibiotics, equispaced.

big_angle = 2.0 * Math::PI / ($bacteria.length + 1.0)
small_angle = big_angle / 7.0
#/* The root panel. */
vis = Rubyvis::Panel.new.
  width(width).
  height(height).
  bottom(100);



# Background wedges to indicate gram staining color.
bg = vis.add(Rubyvis::Wedge).
  data($bacteria). # assumes Burtin's order
  left(lambda {|i| width / 2.0}).
  top(height / 2.0).
  inner_radius(inner_radius).
  outer_radius(outer_radius).
  angle(big_angle).
  start_angle(lambda {|d| 
  index * big_angle + big_angle / 2.0 - Math::PI / 2.0
  }).
  fill_style(lambda {|d|
  Rubyvis.color(gram_color[d[:gram].to_sym])
  })

# Antibiotics. 

bg.add(Rubyvis::Wedge).
  angle(small_angle).
  start_angle(lambda {|d| 
    bg.start_angle() + small_angle
  }).
  outer_radius(lambda {|d| 
  radius.call(d[:penicillin])
  }).
  fill_style(drug_color[:penicillin]).
    add(Rubyvis::Wedge).
    start_angle(lambda {|d| 
    proto.start_angle() + 2 * small_angle}).
    outer_radius(lambda {|d| 
      radius.call(d[:streptomycin])
    }).
    fill_style(drug_color[:streptomycin]).
    add(Rubyvis::Wedge).
    outer_radius(lambda {|d|
      radius.call(d[:neomycin])
    }).
    fill_style(drug_color[:neomycin])

# Circular grid lines. 

bg.add(Rubyvis::Dot)
    .data(Rubyvis.range(-3, 4))
    .fill_style(nil)
    .stroke_style("#eee")
    .line_width(1)
    .shape_size(lambda {|i| 
      radius.call(10**i)** 2
    }).
  anchor("top").add(Rubyvis::Label).
    visible(lambda {|i| i < 3}).
    text_baseline("middle").
    text(lambda {|i| 
      i<0 ? (10** i).to_f : (10**i).to_i
    })

# Radial grid lines. 

bg.add(Rubyvis::Wedge)
.data(Rubyvis.range($bacteria.size + 1))
    .inner_radius(inner_radius - 10)
    .outer_radius(outer_radius + 10)
    .fill_style(nil)
    .stroke_style("black")
    .angle(0)

# Labels. 
bg.anchor("outer").add(Rubyvis::Label)
    .text_align("center")
    .text(lambda {|d| d[:name]})

# Antibiotic legend. 
vis.add(Rubyvis::Bar)
    .data(Rubyvis.keys(drug_color))
    .right(width / 2 + 3)
    .top(lambda { height / 2.0 - 28 + self.index * 18})
    .fill_style(lambda {|d| drug_color[d]})
    .width(36)
    .height(12)
  .anchor("right").add(Rubyvis::Label)
    .textMargin(6)
    .textAlign("left");

# Gram-stain legend.
vis.add(Rubyvis::Dot).
  data([:positive, :negative]).
  left(width / 2.0 - 20).
  bottom(lambda { -60 + index * 18}).
  fill_style(lambda {|d| gram_color[d]}).
  stroke_style(nil).
  shape_size(30).
  anchor("right").add(Rubyvis::Label).
    text_margin(6).
    text_align("left").
    text(lambda {|d| "Gram-#{d}"})

vis.render
puts vis.to_svg
