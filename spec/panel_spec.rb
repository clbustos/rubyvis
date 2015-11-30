require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Panel do
  before do
    @h=200
    @w=200
    @vis = Rubyvis.Panel.new.width(@w).height(@h)
  end
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :events, :fill_style, :height, :id, :left, :line_width, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    expect(Rubyvis::Panel.properties).to eq(props)
  end
  it "should have correct defaults" do
    expect(Rubyvis::Panel.defaults._properties.size).to eq(2)
  end
  it "should build propertly" do
    expect {@vis.render}.not_to raise_exception
  end
  it "should return valid svg" do   
    @vis.render
    doc=Nokogiri::XML(@vis.to_svg)
    expect(doc.at_xpath("//xmlns:svg")).to have_svg_attributes({"font-size"=>"10px", "font-family"=>"sans-serif", "fill"=>"none", "stroke"=>"none", "stroke-width"=>"1.5", "width"=>"200.0", "height"=>"200.0"})
  end
  it "should allow multiple panel definitions" do
    vis2 = Rubyvis.Panel.new.width(@w+100).height(@h+100)
    @vis.render
    vis2.render
    doc1=Nokogiri::XML(@vis.to_svg)
    doc2=Nokogiri::XML(vis2.to_svg)

    expect(doc1.at_xpath("//xmlns:svg")).to have_svg_attributes({"font-size"=>"10px", "font-family"=>"sans-serif", "fill"=>"none", "stroke"=>"none", "stroke-width"=>"1.5", "width"=>"200.0", "height"=>"200.0"})
    
    expect(doc2.at_xpath("//xmlns:svg")).to have_svg_attributes({"font-size"=>"10px", "font-family"=>"sans-serif", "fill"=>"none", "stroke"=>"none", "stroke-width"=>"1.5", "width"=>"300.0", "height"=>"300.0"})
    
  end
end