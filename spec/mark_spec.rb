require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Mark do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :id, :left, :reverse, :right, :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    expect(Rubyvis::Mark.properties).to eq(props)
  end
  it "should return correct defaults" do
    props=Rubyvis::Mark.defaults._properties.sort {|a,b| a.name.to_s<=>b.name.to_s}
    expect(props[1].name).to eq(:data)
    expect(props[1].value).to be_instance_of Proc
    expect(props[3].name).to eq(:visible)
    expect(props[0].name).to eq(:antialias)
    expect(props[2].name).to eq(:events)
  end
  it "should have 'mark' as type" do
    m=Rubyvis::Mark.new
    expect(m.type).to eql "mark"
  end
  
end