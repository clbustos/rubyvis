require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Image do

  include Rubyvis::GeneralSpec

  it "Rubyvis.Image be the same as Rubyvis::Image" do
    Rubyvis.Image.should eql Rubyvis::Image
  end
  
  it "should render correctly" do
    w = 400
    h = 400
    
    vis = Rubyvis::Panel.new().
      width(w).
      height(h).
      margin(20).
      stroke_style("#ccc");
    
    vis.add(Rubyvis::Image).url('fixtures/tipsy.gif')
    vis.render()
    
    pv_out=fixture_svg_read("image.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
  end
   
end
