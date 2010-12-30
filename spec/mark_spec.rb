require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Mark do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :id, :left, :reverse, :right, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Mark.properties.should==props
  end
  it "should return correct defaults" do
    props=Rubyvis::Mark.defaults._properties.sort {|a,b| a.name.to_s<=>b.name.to_s}
    props[1].name.should==:data
    props[1].value.should be_instance_of Proc
    props[3].name.should==:visible
    props[0].name.should==:antialias
    props[2].name.should==:events
  end
  it "should have 'mark' as type" do
    m=Rubyvis::Mark.new
    m.type.should eql "mark"
  end
  
end