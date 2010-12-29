require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Horizon do
  include Rubyvis::LayoutSpec
  
  it "should have correct properties" do
    props=[:antialias, :background_style, :bands,  :bottom, :canvas, :cursor, :data, :events, :fill_style, :height, :id, :left, :line_width, :mode, :negative_style, :overflow, :positive_style, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Horizon.properties.should==props 
  end
  it "should be called using Rubyvis.Layout.Horizon" do
    Rubyvis.Layout.Horizon.should eql Rubyvis::Layout::Horizon
  end
  describe "rendered" do
    before do
      @data = Rubyvis.range(-5, 5, 0.1).map {|d|
        OpenStruct.new({:x=> d ,  :y=> d**2-10});
      }
      
      
      
      w = 400
      h = 100
      x = Rubyvis::Scale.linear(@data, lambda {|d| d.x}).range(0, w)
      y = Rubyvis::Scale.linear(@data, lambda {|d| d.y}).range(-50, h*2);
      
      #/* The root panel. */
      @vis = pv.Panel.new().width(w).height(h*2+20).bottom(20).left(20).right(10).top(5)

      
      
      @pan = @vis.add(Rubyvis::Panel).
      height(80).
      top(30)  
      
      @pan.add(Rubyvis::Layout::Horizon).
      bands(3).
      band.add(Rubyvis::Area).
      data(@data).
      left(lambda {|d| x[d.x]}).
      height(lambda {|d| y[d.y]})
      @vis.render
      
      html_out=fixture_svg_read("layout_horizon.svg")
      @rv_svg=Nokogiri::XML(@vis.to_svg)
      @pv_svg=Nokogiri::XML(html_out)
    end
    
    it "should render correct number of clipaths" do
      
      @rv_svg.xpath("//xmlns:clipPath[@id]").size.should eq @pv_svg.xpath("//clippath[@id]").size
    end
    it "should render equal paths" do
      pv_paths=@pv_svg.xpath("//path")
      @rv_svg.xpath("//xmlns:path").each_with_index {|rv_path,i|
        rv_path.should have_path_data_close_to pv_paths[i]['d']
        rv_path['fill'].should eq pv_paths[i]['fill']
      }
    end
  end
end
