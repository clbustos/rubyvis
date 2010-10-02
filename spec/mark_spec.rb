require File.dirname(__FILE__)+"/spec_helper.rb"
describe Rubyvis::Mark do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :id, :left, :reverse, :right, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Mark.properties.should==props
  end
  it "should return correct defaults" do
    props=Rubyvis::Mark.defaults._properties
    props[0].name.should==:data
    props[0].value.should be_instance_of Proc
    props[1].name.should==:visible
    props[2].name.should==:antialias
    props[3].name.should==:events
  end
  
end