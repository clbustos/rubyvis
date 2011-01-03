require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
  describe Rubyvis::Bar do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :fill_style, :height, :id, :left, :line_width, :reverse, :right, :stroke_style, :title, :top, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Bar.properties.should==props
  end
  it "Rubyvis.Bar be the same as Rubyvis::Bar" do
    Rubyvis.Bar.should eql Rubyvis::Bar
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
    @h=200
    @w=200
    @vis = Rubyvis.Panel.new.width(@w).height(@h)
    @bar=@vis.add(pv.Bar).data([1,2]).width(20).height(lambda {|d| d * 80}).bottom(0).left(lambda {self.index * 25});
    end
    it "should bould propertly" do
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      attribs=doc.xpath("//xmlns:rect").map {|v|
      [v.attributes['y'].value, v.attributes['height'].value, v.attributes['fill'].value]
      }
      attribs.should==[["120","80","rgb(31,119,180)"],["40","160","rgb(31,119,180)"]]
    end
    
    it "should bould properly with string fill_style" do
      @bar.fill_style('red')
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      doc.at_xpath("//xmlns:rect").attributes['fill'].value.should=='rgb(255,0,0)'
    end
    it "should bould properly with pv.color" do
      @bar.fill_style(pv.color('red'))
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      doc.at_xpath("//xmlns:rect").attributes['fill'].value.should=='rgb(255,0,0)'
    end
    it "should bould properly with pv.colors" do
      @bar.fill_style(pv.colors('black','red'))
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      attr=doc.xpath("//xmlns:rect").map {|x| x.attributes['fill'].value}
      attr.should==['rgb(0,0,0)', 'rgb(255,0,0)']
    end
    
    it "should bould propertly with double data" do
      @vis = Rubyvis.Panel.new.width(@w).height(100)
      @vis.add(pv.Bar).data([1,2]).width(20).height(lambda {|d| d * 10}).bottom(0).left(lambda {self.index * 25}).add(pv.Bar).width(10).height(lambda {|d| d * 30}).bottom(0).left(lambda {self.index * 25});
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      attribs=doc.xpath("//xmlns:rect").map {|v|
      x=v.attributes['x'] ? v.attributes['x'].value : nil
        [x, v.attributes['y'].value, v.attributes['height'].value]
      }
      attribs.should==[[nil,"90","10"], ["25","80","20"], [nil,"70","30"], ["25","40","60"]]
    end
    
  end  
  
  
end