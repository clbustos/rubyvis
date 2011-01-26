require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Partition do
  include Rubyvis::LayoutSpec
  it "subclass Fill should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :events, :fill_style, :height, :id, :inner_radius, :left, :line_width, :links,  :nodes,  :order, :orient, :outer_radius, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Partition::Fill.properties.should==props 
  end
  it "should be called using Rubyvis.Layout.Partition" do
    Rubyvis.Layout.Partition.should eql Rubyvis::Layout::Partition
  end  
  it "should render correctly 'partition_fill' custom test" do
    color=pv.Colors.category19
    w=400
    h=400
    
    @vis = pv.Panel.new().
width(w).
height(h).
top(20).
bottom(10).
left(10)
    
    pack = @vis.add(Rubyvis::Layout::Partition::Fill).
    nodes(hier_nodes_big).
    orient("left").
    size(lambda {|d|
        d.node_value
    })
    
    pack.node.add(pv.Bar).
    fill_style(lambda {|d| color[d.node_value]}).
    stroke_style("black").
    line_width(1).
    antialias(false)
    
    pack.node_label.add(pv.Label).
      text(lambda {|d| d.node_name})
    
    
    @vis.render
    @pv_out=fixture_svg_read("layout_partition_fill.svg")
    @vis.to_svg.should have_same_svg_elements(@pv_out)
    end
  
end
