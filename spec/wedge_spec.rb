require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Wedge do
  include Rubyvis::GeneralSpec
  it "should have correct properties" do
    props=[:angle, :antialias, :bottom, :cursor, :data, :end_angle, :events, :fill_style,  :id, :inner_radius, :left, :line_width, :outer_radius, :reverse, :right, :start_angle, :stroke_style, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Wedge.properties.should==props
  end
  it "Rubyvis.Wedge be the same as Rubyvis::Wedge" do
    Rubyvis.Wedge.should eql Rubyvis::Wedge
  end
  it "should render equal to protovis 'wedge-anchor.html' test" do
    
    data = Rubyvis.range(5).map {|x| x}
    w = 400
    h = 400
    r = w / 2.0
    t = 30
    a = Rubyvis::Scale.linear(0, Rubyvis.sum(data)).range(0, 2 * Math::PI);

    vis = Rubyvis::Panel.new().
width(w).
height(h)

    anchors=["outer","inner","start","center","end"]
    
    vis.add(Rubyvis::Wedge).
data(data).
outer_radius(r).
angle(a).
anchor(lambda {anchors[self.index]}).add(pv.Label).
text(lambda {anchors[self.index]})

    vis.render();
    pv_out=fixture_svg_read("wedge_anchor.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
    
  end
  it "should render equal to protovis 'wedge-donut.html' test" do
    data = Rubyvis.range(10).map {|x| (Math.sin(x)).abs}
    w = 400
    h = 400
    r = w / 2.0
    t = 30
    a = Rubyvis.Scale.linear(0, Rubyvis.sum(data)).range(0, 2 * Math::PI)
    
    @vis = Rubyvis::Panel.new().
width(w).
height(h)
    
    @vis.add(Rubyvis::Wedge).
data(data).
inner_radius(r - t).
outer_radius(r).
angle(a).
title(lambda {|d| d}).
anchor("outer").add(Rubyvis::Label).
visible(lambda {|d| d>0.05}).
text_margin(t + 5).
text(lambda {|d| "%0.2f" % d})
    @vis.render();

    @pv_out=fixture_svg_read("wedge_donut.svg")
    @vis.to_svg.should have_same_svg_elements(@pv_out)
  end  
  
end