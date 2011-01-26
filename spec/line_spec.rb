require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Line do
  include Rubyvis::GeneralSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :eccentricity, :events, :fill_style, :id, :interpolate, :left, :line_join, :line_width, :reverse, :right, :segmented, :stroke_style, :tension, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Line.properties.should==props
  end
  it "should render correctly 'line_interpolation.html' example" do
    data = pv.range(0, 10, 0.2).map {|x|
    OpenStruct.new({:x=>x, :y=>Math.sin(x) + 2})}
      
      p_w=200
      p_h=150
      w = 20+p_w*2
      h = 20+p_h*4
      
      p_w=200
      p_h=150
      #p data
      w = 20+p_w*2
      h = 20+p_h*4
      
      x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, p_w-30)
      
      
      y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, p_h-20);
      
      interpolations=["linear","step-before","step-after","polar","polar-reverse", "basis", "cardinal"]
      
      #/* The root panel. */
      vis = pv.Panel.new().
width(w).
height(h).
bottom(20).
left(20).
right(10).
top(5)
      
      interpolations.each_with_index do |inter,i|
      n=i%2
      m=(i/2).floor
      panel=vis.add(Rubyvis::Panel).
      left(n*(p_w+10)).
      top(m*(p_h+10)).
      width(p_w).
      height(p_h)
      panel.anchor('top').add(Rubyvis::Label).text(inter)
      panel.add(Rubyvis::Line).data(data).
      line_width(2).
      left(lambda {|d| x.scale(d.x)}).
      bottom(lambda {|d| y.scale(d.y)}).
      interpolate(inter)
  
    end
    vis.render()
    pv_out=fixture_svg_read("line_interpolation.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
  end
  it "should render correctly 'line_interpolation_segmented.html' example" do
    data = pv.range(0, 10, 0.2).map {|x|
    OpenStruct.new({:x=>x, :y=>Math.sin(x) + 2})}
      
      p_w=200
      p_h=150
      w = 20+p_w*2
      h = 20+p_h*4
      
      p_w=200
      p_h=150
      #p data
      w = 20+p_w*2
      h = 20+p_h*4
      
      x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, p_w-30)
      
      
      y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, p_h-20);
      
      interpolations=["linear","step-before","step-after","polar","polar-reverse", "basis", "cardinal","monotone"]
      #/* The root panel. */
      vis = pv.Panel.new().
width(w).
height(h).
bottom(20).
left(20).
right(10).
top(5)
      
      interpolations.each_with_index do |inter,i|
      n=i%2
      m=(i/2).floor
      panel=vis.add(Rubyvis::Panel).
      left(n*(p_w+10)).
      top(m*(p_h+10)).
      width(p_w).
      height(p_h)
    
      panel.anchor('top').add(Rubyvis::Label).text(inter)
      
      panel.add(Rubyvis::Line).data(data).
      segmented(true).
      line_width(lambda {|d|d.y*2.0+self.index*0.5}).
      left(lambda {|d| x.scale(d.x)}).
      bottom(lambda {|d| y.scale(d.y)}).
      interpolate(inter)
    end
    vis.render()
    pv_out=fixture_svg_read("line_interpolation_segmented.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
  end
  it "SvgScene.path_join should return correct value" do
    s0=OpenStruct.new({:left=>1,:top=>2,:visible=>true, :line_width=>2.5})
    s1=OpenStruct.new({:left=>3,:top=>4,:visible=>true, :line_width=>2.5})
    s2=OpenStruct.new({:left=>5,:top=>6,:visible=>true, :line_width=>2.5})
    s3=OpenStruct.new({:left=>7,:top=>8,:visible=>true, :line_width=>2.5})
    Rubyvis::SvgScene.path_join(s0,s1,s2,s3).should=="M2.1161165235168156,4.883883476483184L4.116116523516816,6.883883476483184 5.883883476483184,5.116116523516816 3.8838834764831844,3.1161165235168156"
    s0=OpenStruct.new({:left=>1.5,:top=>2,:visible=>true, :line_width=>3})
    s1=OpenStruct.new({:left=>3.5,:top=>4,:visible=>true, :line_width=>3.5})
    s2=OpenStruct.new({:left=>5.5,:top=>6,:visible=>true, :line_width=>4.0})
    s3=OpenStruct.new({:left=>7.5,:top=>8,:visible=>true, :line_width=>4.5})
    
  Rubyvis::SvgScene.path_join(s0,s1,s2,s3).should=="M2.2625631329235425,5.2374368670764575L4.2625631329235425,7.2374368670764575 6.7374368670764575,4.7625631329235425 4.7374368670764575,2.7625631329235425"
  
  end
  context "rendered" do
    before do
      @h=200
      @w=200
      @vis = Rubyvis.Panel.new.width(@w).height(@h)
      @area=@vis.add(pv.Line).
        data([1,2,1,4,1,5]).
        bottom(lambda {|d| d*20}).
        left(lambda {index*20})
    end
    it "should return correct default (linear) path" do
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to  "M0 180L20 160L40 180L60 120L80 180L100 100L100 200L80 200L60 200L40 200L20 200L0 200Z"
    end
    it "should return correct path for interpolate=step-before" do
      @area.interpolate('step-before')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0,180V160H20V180H40V120H60V180H80V100H100"
    end
    it "should return correct path for interpolate=step-after" do
      @area.interpolate('step-after')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0,180H20V160H40V180H60V120H80V180H100V100"
    end
    
    it "should return correct path for interpolate=polar" do
      @area.interpolate('polar')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0,180A14.142135623730951,14.142135623730951 0 0,1 20,160A14.142135623730951,14.142135623730951 0 0,1 40,180A31.622776601683793,31.622776601683793 0 0,1 60,120A31.622776601683793,31.622776601683793 0 0,1 80,180A41.23105625617661,41.23105625617661 0 0,1 100,100"
    end
    
    
    it "should return correct path for interpolate=polar-reverse" do
     
      @area.interpolate('polar-reverse')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0,180A14.142135623730951,14.142135623730951 0 0,0 20,160A14.142135623730951,14.142135623730951 0 0,0 40,180A31.622776601683793,31.622776601683793 0 0,0 60,120A31.622776601683793,31.622776601683793 0 0,0 80,180A41.23105625617661,41.23105625617661 0 0,0 100,100"
    end
    it "should return correct path for interpolate=basis" do
      @area.interpolate('basis')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0 180C0 180 0 180 3.333333333333333 176.66666666666666C6.666666666666666 173.33333333333331 13.333333333333332 166.66666666666666 20 166.66666666666666C26.666666666666664 166.66666666666666 33.33333333333333 173.33333333333331 40 166.66666666666666C46.666666666666664 160 53.33333333333333 140 60 140C66.66666666666666 140 73.33333333333333 160 80 156.66666666666666C86.66666666666666 153.33333333333331 93.33333333333331 126.66666666666666 96.66666666666666 113.33333333333331C99.99999999999999 99.99999999999999 99.99999999999999 99.99999999999999 99.99999999999997 99.99999999999997"
    end   
    it "should return correct path for interpolate=cardinal" do 
      @area.interpolate('cardinal')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0 180Q16 160 20 160C26 160 34 186 40 180S54 120 60 120S74 183 80 180Q84 178 100 100"
    end
  end
end