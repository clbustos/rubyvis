require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Arc do
  include Rubyvis::LayoutSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :directed, :events, :fill_style, :height, :id, :left, :line_width, :links, :nodes, :orient, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Arc.properties.should==props 
  end
  it "should be called using Rubyvis.Layout.Arc" do
    Rubyvis.Layout.Arc.should eql Rubyvis::Layout::Arc
  end  
  describe "rendered" do
    before do
      
      
      
      
      w = 300
      h = 100
      
      color=Rubyvis::Colors.category19
      
      @vis = Rubyvis::Panel.new().
        width(w).
        height(h).
        bottom(50).
        left(0)
      
      mat=@vis.add(Rubyvis::Layout::Arc).
        nodes(net_nodes).links(net_links).
        sort(lambda {|a,b| a.group<=>b.group})
      
      mat.link.add(Rubyvis::Line).
      antialias(false).
      line_width(1)
      
      mat.node.add(Rubyvis::Dot).
      shape_size(10).
      fill_style(lambda {|l| color[l.group]})
      
      mat.node_label.add(Rubyvis::Label).
      text_style(lambda {|l| color[l.group]})
      
      @vis.render

      svg_out=fixture_svg_read("layout_arc.svg")
      @rv_svg=Nokogiri::XML(@vis.to_svg)
      @pv_svg=Nokogiri::XML(svg_out)
    end
    
    it "should render correct number of clipaths" do
      
      @rv_svg.xpath("//xmlns:path").size.should eq @pv_svg.xpath("//path").size
    end
    it "should render equal paths (links)" do
      pv_paths=@pv_svg.xpath("//path")
      @rv_svg.xpath("//xmlns:path").each_with_index {|rv_path,i|
        rv_path.should have_path_data_close_to pv_paths[i]['d']
      }
    end
    it "should render equal dots (nodes)" do
      pv_circles=@pv_svg.xpath("//circle")
      @rv_svg.xpath("//xmlns:circle").each_with_index {|rv_circle,i|
        rv_circle.should have_same_position pv_circles[i]
      }
      
    end
  end
end
