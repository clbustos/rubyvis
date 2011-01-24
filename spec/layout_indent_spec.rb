require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Indent do
  include Rubyvis::LayoutSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :breadth, :canvas, :cursor, :data, :depth, :events, :fill_style, :height, :id, :left, :line_width, :links,  :nodes,  :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Indent.properties.should==props 
  end
  it "should be called using Rubyvis.Layout.Indent" do
    Rubyvis.Layout.Indent.should eql Rubyvis::Layout::Indent
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
    
    indent = @vis.add(pv.Layout.Indent).
    nodes(hier_nodes_big).
    breadth(10)
    
    indent.node.add(pv.Dot).
    fill_style(lambda {|d| color[d.node_value]}).
    stroke_style("black").
    line_width(1).
    antialias(false)
    indent.link.add(Rubyvis::Line) 
    indent.node_label.add(pv.Label).
    text(lambda {|d| d.node_value})
    
    
    @vis.render
    
    html_out=fixture_svg_read("layout_indent.svg")
    @rv_svg=Nokogiri::XML(@vis.to_svg)
    @pv_svg=Nokogiri::XML(html_out)
    end
    
    it "should render equal nodes (circles)" do
      pv_rects=@pv_svg.xpath("//circle")
      @rv_svg.xpath("//xmlns:circle").each_with_index {|rv_rect,i|
        rv_rect.should have_same_position pv_rects[i]
      }
      
    end
  end
end
