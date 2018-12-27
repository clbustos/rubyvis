require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
  describe Rubyvis::Label do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :font, :font_family, :font_style, :font_variant, :font_weight, :font_size, :id, :left, :reverse, :right, :text, :text_align, :text_angle, :text_baseline, :text_decoration, :text_margin, :text_shadow, :text_style, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    
    expect(Rubyvis::Label.properties).to eq(props)
  end
  it "should return correct defaults" do
    props=Rubyvis::Bar.defaults._properties
    expect(props.size).to eq(2)
    expect(props[0].name).to eq(:line_width)
    expect(props[0].value).to eq(1.5)
    expect(props[1].name).to eq(:fill_style)
    expect(props[1].value).to be_instance_of Proc
    expect(Rubyvis::Bar.defaults.proto).to be_instance_of Rubyvis::Mark
    
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
      expect(doc.at_xpath("//xmlns:text").attributes['style'].value).to eq('font-size:20px')
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
      expect(attribs).to eq([["-3","translate(0,100)","1"],["-3","translate(25,100)","2"]])
    end
    
  end  
  
  
end
