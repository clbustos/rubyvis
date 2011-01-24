require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Grid do
  include Rubyvis::LayoutSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cols, :cursor, :data, :events, :fill_style, :height,  :id, :left, :line_width, :overflow, :reverse, :right, :rows, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Grid.properties.should==props
  end
  it "Rubyvis.Layout.Grid be the same as Rubyvis::Layout::Grid" do
    Rubyvis.Layout.Grid.should eql Rubyvis::Layout::Grid
  end
  it "should render equal to protovis 'layout_grid.html' test" do
   
    vis = pv.Panel.new().
      data(["A"]).
      width(800).
      height(800).
      margin(10).
      fill_style("#eee").
    stroke_style("#ccc");

    vis.add(Rubyvis::Layout::Grid).
      rows(3).
      cols(3).
      cell.add(Rubyvis::Layout::Grid).
      rows(Rubyvis.index).
      cols(Rubyvis.index).
      cell.add(Rubyvis::Bar).
      stroke_style("#fff").
    anchor("center").add(Rubyvis::Label).
      textStyle("rgba(255, 255, 255, .4)").
      font("24px sans");

vis.render();
    
    
    pv_out=fixture_svg_read("layout_grid.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
  end  
  
end