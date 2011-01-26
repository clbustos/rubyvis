require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Rule do
  include Rubyvis::GeneralSpec
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :height,  :id, :left, :line_width, :reverse, :right, :stroke_style, :title, :top, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Rule.properties.should==props
  end
  it "Rubyvis.Rule be the same as Rubyvis::Rule" do
    Rubyvis.Rule.should eql Rubyvis::Rule
  end
  it "should render equal to protovis 'rule-anchor.html' test" do
    vis = Rubyvis::Panel.new().
      width(400).
      height(300)
    
    
    bar=vis.add(pv.Bar).
      data(["left", "top", "right", "bottom", "center"]).
      width(300).
      height(30).
      left(40).
      right(40).
      top(lambda {self.index*60}).fill_style('red')
    
    rule = bar.add(pv.Rule)
    rule.anchor(lambda {|d| d}).add(pv.Label).text(lambda {|d| d})
    
    vis.render();
    pv_out=fixture_svg_read("rule_anchor.svg")
    vis.to_svg.should have_same_svg_elements(pv_out)
  end  
  
end