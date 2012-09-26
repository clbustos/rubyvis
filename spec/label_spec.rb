require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
  describe Rubyvis::Label do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :font, :font_family, :font_style, :font_variant, :font_weight, :font_size, :id, :left, :reverse, :right, :text, :text_align, :text_angle, :text_baseline, :text_decoration, :text_margin, :text_shadow, :text_style, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    
    Rubyvis::Label.properties.should==props
  end
  it "should return correct defaults" do
    props=Rubyvis::Bar.defaults._properties
    props.size.should==2
    props[0].name.should==:line_width
    props[0].value.should==1.5
    props[1].name.should==:fill_style
    props[1].value.should be_instance_of Proc
    Rubyvis::Bar.defaults.proto.should be_instance_of Rubyvis::Mark
    
  end
  context "on a Panel" do 
    before do
      #Rubyvis.clear_document
      @h=100
      @w=200
      @vis = Rubyvis.Panel.new.width(@w).height(@h)
      @bar=@vis.add(pv.Bar).data([1,2]).width(20).height(lambda {|d| d * 80}).bottom(0).left(lambda {self.index * 25})
      @label=@bar.add(pv.Label)
    end
    it "should bould properly with font_size" do
      @label.font_size('20px')
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      #p doc.at_xpath("//xmlns:text")
      doc.at_xpath("//xmlns:text").attributes['style'].value.should=='font-size:20px'
    end
    
    it "should bould basic stuff properly " do
      @vis.render
      s=@vis.to_svg
      #p s
      #File.open("test.svg","w") {|f| f.puts s}

      doc=Nokogiri::XML(s)
      #p doc.at_xpath("//xmlns:text")
      
      attribs=doc.xpath("//xmlns:text").map {|v|
      [v.attributes['y'].value, v.attributes['transform'].value, v.text] }
      attribs.should==[["-3","translate(0,100)","1"],["-3","translate(25,100)","2"]]
    end
    
  end  
  
  
end
