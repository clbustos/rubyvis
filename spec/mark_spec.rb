require File.dirname(__FILE__)+"/spec_helper.rb"
describe Protoruby::Mark do
  it "could be created" do
    lambda { Protoruby::Mark.new}.should_not raise_exception
  end
  it "should set and retrieve properties according to spec" do
    a=Protoruby::Mark.new
    a.data("hola")
    a.data.should=='hola'
    a.data(lambda{ object_id})
    a.data.should==a.object_id
  end
  it "should set values using chained methods" do
    r,l,b,t=rand(),rand(),rand(),rand()
    a=Protoruby::Mark.new
    a.right(r).left(l).bottom(b).top(t)
    a.right.should==r
    a.left.should==l
    a.top.should==t
    a.bottom.should==b    
  end
  it "should set margin correctly" do
    margin=rand()
    a=Protoruby::Mark.new
    a.margin(margin)
    a.right.should==margin
    a.left.should==margin
    a.top.should==margin
    a.bottom.should==margin
    
  end
  
end