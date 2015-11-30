require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
  describe Rubyvis::Bar do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :fill_style, :height, :id, :left, :line_width, :reverse, :right, :stroke_style, :title, :top, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    expect(Rubyvis::Bar.properties).to eq(props)
  end
  it "Rubyvis.Bar be the same as Rubyvis::Bar" do
    expect(Rubyvis.Bar).to eql Rubyvis::Bar
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
      expect(attribs).to eq([["120","80","rgb(31,119,180)"],["40","160","rgb(31,119,180)"]])
    end
    
    it "should bould properly with string fill_style" do
      @bar.fill_style('red')
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      expect(doc.at_xpath("//xmlns:rect").attributes['fill'].value).to eq('rgb(255,0,0)')
    end
    it "should bould properly with pv.color" do
      @bar.fill_style(pv.color('red'))
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      expect(doc.at_xpath("//xmlns:rect").attributes['fill'].value).to eq('rgb(255,0,0)')
    end
    it "should bould properly with pv.colors" do
      @bar.fill_style(pv.colors('black','red'))
      @vis.render
      s=@vis.to_svg
      doc=Nokogiri::XML(s)
      attr=doc.xpath("//xmlns:rect").map {|x| x.attributes['fill'].value}
      expect(attr).to eq(['rgb(0,0,0)', 'rgb(255,0,0)'])
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
      expect(attribs).to eq([[nil,"90","10"], ["25","80","20"], [nil,"70","30"], ["25","40","60"]])
    end
    
  end  
  
  
end