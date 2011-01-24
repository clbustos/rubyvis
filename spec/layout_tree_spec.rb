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
        height(h).
        top(20).
        bottom(10).
        left(10)
      
      @tree= @vis.add(pv.Layout.Tree).
      nodes(hier_nodes).breadth(40)
      
      @tree.node.add(pv.Dot).
      fill_style(lambda {|d| color[d.node_value]}).
      stroke_style("black").
      line_width(1).
      antialias(false)
      
      @tree.link.add(Rubyvis::Line)
      
      @tree.node_label.add(Rubyvis::Label).text(lambda {|d| d.node_name})
      
    end
    it "should render equal to protovis with orient 'top'" do
      @tree.orient("top")
      @vis.render
      pv_out=fixture_svg_read("layout_tree_orient_top.svg")
      @vis.to_svg.should have_same_svg_elements(pv_out)
    end
    
    it  "should render correctly orient('left')" do
      @tree.orient("left")
      @vis.render
      pv_out=fixture_svg_read("layout_tree_orient_left.svg")
      @vis.to_svg.should have_same_svg_elements(pv_out)
    end
    
    it "should render equal to pv with orient('radial') and breadth(20)" do
        @tree.nodes(hier_nodes_big).orient("radial").breadth(20)
        @vis.render
        pv_out=fixture_svg_read("layout_tree_orient_radial_breadth_20.svg")
        @vis.to_svg.should have_same_svg_elements(pv_out)
    end
  end
end
