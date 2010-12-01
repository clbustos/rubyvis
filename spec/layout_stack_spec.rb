require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Stack do
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :events, :fill_style, :height, :id, :layers, :left, :line_width, :offset, :order, :orient, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Stack.properties.should==props
  end
  describe "rendered" do
    before do
      @h=200
      @w=200
      
      @x=Rubyvis::Scale.linear(0,3).range(0,@w)
      @y=Rubyvis::Scale.linear(0,10).range(0,@h)
      
      @vis = Rubyvis.Panel.new.width(@w).height(@h)
      @stack=@vis.add(Rubyvis::Layout::Stack)
    end
    describe "only with layers()" do
      before do
        x=@x
        y=@y
        @data=[[1,3,2],[2,1,3]]
        @stack.
        layers(@data).
        x(lambda {|d| x.scale(index)}).
        y(lambda {|d| y.scale(d)}).layer.add(Rubyvis::Area)
        @vis.render
        doc=Nokogiri::XML(@vis.to_svg)
        @paths=doc.xpath("//xmlns:path")
        # <svg font-size="10px" font-family="sans-serif" fill="none" stroke="none" stroke-width="1.5" width="200" height="200"><g><g><g><path d="M0,180L66.66666666666666,140L133.33333333333331,160L133.33333333333331,200L66.66666666666666,200L0,200Z" fill="rgb(31,119,180)"/></g><g><path d="M0,140L66.66666666666666,120L133.33333333333331,100L133.33333333333331,160L66.66666666666666,140L0,180Z" fill="rgb(174,199,232)"/></g></g></g></svg>        
      end
      it "should return correct number of areas" do
        @paths.size.should eq 2
      end
      it "should return correct path 1" do
        @paths[0].should have_path_data_close_to "M0 180L66.66666666666666 140L133.33333333333331 160L133.33333333333331 200L66.66666666666666 200L0 200Z"
      end
      it "should return correct path 2" do
        @paths[1].should have_path_data_close_to "M0 140L66.66666666666666 120L133.33333333333331 100L133.33333333333331 160L66.66666666666666 140L0 180Z"
      end
    end
    describe "using layers() and values()" do
      before do
        x=@x
        y=@y
        @data=[{:aa=>1,:bb=>2},{:aa=>3,:bb=>1},{:aa=>2,:bb=>3}]
        @stack.
        layers([:aa,:bb]).
        values(@data).
        x(lambda {|d| x.scale(index)}).
        y(lambda {|d,dd| y.scale(d[dd])}).layer.add(Rubyvis::Area)
        @vis.render
        doc=Nokogiri::XML(@vis.to_svg)
        @paths=doc.xpath("//xmlns:path")
        # <svg font-size="10px" font-family="sans-serif" fill="none" stroke="none" stroke-width="1.5" width="200" height="200"><g><g><g><path d="M0,180L66.66666666666666,140L133.33333333333331,160L133.33333333333331,200L66.66666666666666,200L0,200Z" fill="rgb(31,119,180)"/></g><g><path d="M0,140L66.66666666666666,120L133.33333333333331,100L133.33333333333331,160L66.66666666666666,140L0,180Z" fill="rgb(174,199,232)"/></g></g></g></svg>       
      end
      it "should return correct number of areas" do
        @paths.size.should eq 2
      end
      it "should return correct path 1" do
        @paths[0].should have_path_data_close_to "M0 180L66.66666666666666 140L133.33333333333331 160L133.33333333333331 200L66.66666666666666 200L0 200Z"
      end
      it "should return correct path 2" do
        @paths[1].should have_path_data_close_to "M0 140L66.66666666666666 120L133.33333333333331 100L133.33333333333331 160L66.66666666666666 140L0 180Z"
      end
      
    end
    
  end
end