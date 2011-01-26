require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Treemap do
  include Rubyvis::LayoutSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :events, :fill_style, :height, :id, :left, :line_width, :links, :mode, :nodes, :order, :overflow, :padding_bottom, :padding_left, :padding_right, :padding_top, :reverse, :right, :round, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Treemap.properties.should==props 
  end
  describe "rendered" do
    before do
    color=pv.Colors.category19
    w=200
    h=200

    @vis = pv.Panel.new().
      width(w).
      height(h)
    
    treemap = @vis.add(pv.Layout.Treemap).
    nodes(hier_nodes).
    size(lambda {|d| d.node_value})
    
    treemap.leaf.add(pv.Panel).
    fill_style(lambda {|d| color[d.node_value]}).
    stroke_style("black").
    line_width(1).
    antialias(false)
    
    treemap.node_label.add(pv.Label).
    text(lambda {|d| d.node_value})
    
      
      @vis.render

      @pv_out=fixture_svg_read("layout_treemap.svg")
    end
    
    it "should render equal to protovis version " do 
      @vis.to_svg.should have_same_svg_elements(@pv_out)
    end
  end
end
