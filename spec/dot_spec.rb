require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
  describe Rubyvis::Dot do
    include Rubyvis::GeneralSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :fill_style,  :id, :left, :line_width, :reverse, :right, :shape, :shape_angle, :shape_radius, :shape_size, :stroke_style, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    
    Rubyvis::Dot.properties.should==props
  end
  it "Rubyvis.Dot be the same as Rubyvis::Dot" do
    Rubyvis.Dot.should eql Rubyvis::Dot
  end
  
  it "should render correctly 'dot-anchor' example" do
    w = 400
    h = 400
    
    vis = Rubyvis::Panel.new().
      width(w).
      height(h).
      margin(20).
      stroke_style("#ccc");
    
    dot = vis.add(Rubyvis::Dot).
      top(w / 2.0).
      left(w / 2.0).
      shape_radius(w >> 2)
    
    dot.anchor("top").add(Rubyvis::Label).text("top");
    dot.anchor("left").add(Rubyvis::Label).text("left");
    dot.anchor("right").add(Rubyvis::Label).text("right");
    dot.anchor("bottom").add(Rubyvis::Label).text("bottom");
    dot.anchor("center").add(Rubyvis::Label).text("center");
    
    vis.render()
    
    pv_out=fixture_svg_read("dot_anchor.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
  end
  
  
end