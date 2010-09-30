require File.dirname(__FILE__)+"/spec_helper.rb"
describe Rubyvis::Mark do
  it "could be created" do
    lambda { Rubyvis::Mark.new}.should_not raise_exception
  end
  it "should set and retrieve properties according to spec" do
    a=Rubyvis::Mark.new
    a.data("hola")
    a.data("hola")

    p a

    pending("")

    a.data.should=='hola'
    a.data(lambda{ object_id})
    a.data.should==a.object_id
  end
  it "should set values using chained methods" do
    pending("")

    r,l,b,t=rand(),rand(),rand(),rand()
    a=Rubyvis::Mark.new
    a.right(r).left(l).bottom(b).top(t)
    a.right.should==r
    a.left.should==l
    a.top.should==t
    a.bottom.should==b    
  end
  it "should set margin correctly" do
    pending("")

    margin=rand()
    a=Rubyvis::Mark.new
    a.margin(margin)
    a.right.should==margin
    a.left.should==margin
    a.top.should==margin
    a.bottom.should==margin
    
  end
  
end