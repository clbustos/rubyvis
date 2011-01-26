require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Matrix do
  include Rubyvis::LayoutSpec
  
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :directed, :events, :fill_style, :height, :id, :left, :line_width, :links, :nodes, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Matrix.properties.should==props 
  end
  describe "rendered" do
    before do   
      w = 700
      h = 700
      
      color=Rubyvis::Colors.category19()
      @vis = Rubyvis::Panel.new().
        width(w).
        height(h).
        top(50).
        left(50)
      
      mat=@vis.add(Rubyvis::Layout.Matrix).
directed(true).
nodes(net_nodes).links(net_links).
sort(lambda {|a,b| a.group<=>b.group})
      
      mat.link.add(pv.Bar).
      fill_style(lambda {|l| l.link_value!=0 ? 
      ((l.target_node.group==l.source_node.group) ? color[l.sourceNode] : "#555") : "#eee"}).
      antialias(false).
      line_width(1)
      mat.node_label.add(Rubyvis::Label).
      text_style(color)
      @vis.render
      
      html_out=fixture_svg_read("layout_matrix.svg")
      @rv_svg=Nokogiri::XML(@vis.to_svg)
      @pv_svg=Nokogiri::XML(html_out)
    end
    
    it "should render correct number of rects(links)" do
      @rv_svg.xpath("//xmlns:rect").size.should eq @pv_svg.xpath("//rect").size
    end
    it "should render equal intersections (links)" do
      pv_rects=@pv_svg.xpath("//rect")
      @rv_svg.xpath("//xmlns:rect").each_with_index {|rv_rect,i|
        rv_rect.should have_same_position pv_rects[i]
      }
      
    end
    
    
  end
end
