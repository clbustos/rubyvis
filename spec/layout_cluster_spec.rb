require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Cluster do
  include Rubyvis::LayoutSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :events, :fill_style,:group,  :height, :id, :inner_radius, :left, :line_width, :links,  :nodes,   :orient, :outer_radius, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Cluster.properties.should==props 
  end
  it "should be called using Rubyvis.Layout.Cluster" do
    Rubyvis.Layout.Cluster.should eql Rubyvis::Layout::Cluster
  end
  describe "html tests" do
    
    before  do
      color=Rubyvis.Colors.category19
      w=400
      h=400
      
      @vis = Rubyvis.Panel.new().
        width(w).
        height(h).
        top(20).
        bottom(10).
        left(10)
      
      @cluster = @vis.add(Rubyvis::Layout::Cluster).
      nodes(hier_nodes_big).
      orient("top")
      
      @cluster.node.add(Rubyvis::Dot).
      fill_style(lambda {|d| color[d.node_value]}).
      stroke_style("black").
      line_width(1).
      antialias(false)
      
      @cluster.link.add(Rubyvis::Line)
      
      @cluster.node_label.add(Rubyvis::Label).
        text(lambda {|d| d.node_name})
    end
    it "should render correctly 'cluster.html' custom test" do
      @vis.render
      @pv_out=fixture_svg_read("layout_cluster.svg")
      File.open("test.svg","w") {|fp| fp.write(@vis.to_svg)}
      @vis.to_svg.should have_same_svg_elements(@pv_out)
    end
    it "should render correctly 'cluster_left_group_2.html' custom test" do
      @cluster.orient("left").group(2)
      @vis.render
      @pv_out=fixture_svg_read("layout_cluster_left_group_2.svg")
      @vis.to_svg.should have_same_svg_elements(@pv_out)
    end
  end
end
