require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Stack do
  include Rubyvis::LayoutSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :events, :fill_style, :height, :id, :layers, :left, :line_width, :offset, :order, :orient, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Stack.properties.should==props
  end
  it "Rubyvis.Dot be the same as Rubyvis::Dot" do
    Rubyvis.Layout.Stack.should eql Rubyvis::Layout::Stack
  end
  describe "html examples" do 
    before do
      w = 300
      @h = 300
      
      n = 20 # // number of layers
      m = 75 # // number of samples per layer
      x = pv.Scale.linear(2, m - 1).range(0, w)
      @y = pv.Scale.linear(0, 20).range(0, @h/2.0)
      
      fill=pv.ramp("#ada", "#656").domain(n, 0)
      
      @vis = Rubyvis::Panel.new().
        width(w).
        height(@h)
      
      dat=waves(n,m)
      @stack=@vis.add(Rubyvis::Layout::Stack).
        layers(dat).
        x(lambda {|d| x[self.index]}).
        y(lambda {|d| d})
      
      @stack.layer.add(Rubyvis::Area).
        fill_style(lambda {fill[self.parent.index]}).
        stroke_style("#797")
    end
    
    it "should render 'stack-expand.html' example correctly" do
      @stack.order("inside-out").
      offset("expand")
      @vis.render()
      pv_out=fixture_svg_read("stack_expand.svg")
      @vis.to_svg.should have_same_svg_elements(pv_out)
    end
    it "should render 'stack-silohouette.html' example correctly" do
      y=@y
      @stack.order("reverse").
      offset("silohouette").
      y(lambda {|d| y[d]})
    
      @vis.render()
      pv_out=fixture_svg_read("stack_silohouette.svg")
      @vis.to_svg.should have_same_svg_elements(pv_out)
    end
    it "should render 'stack-wiggle.html' example correctly" do
      y=@y
      @stack.order("reverse").
        offset("wiggle").
      y(lambda {|d| y[d]})
    
      @vis.render()
      pv_out=fixture_svg_read("stack_wiggle.svg")
      @vis.to_svg.should have_same_svg_elements(pv_out)
    end
    
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
        @stack.layers(@data).
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
        @data=[{:first=>1,:second=>2},{:first=>3,:second=>1},{:first=>2,:second=>3}]
        @stack.layers([:first,:second]).
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
