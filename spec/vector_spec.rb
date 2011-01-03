require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Vector do
  before do
    @x1,@x2,@y1,@y2=rand(10)+1,rand(10)+1,rand(10)+1,rand(10)+1
    @v1=Rubyvis::Vector.new(@x1,@y1)
    @v2=Rubyvis::Vector.new(@x2,@y2)
  end
  it "should return the same as Rubyvis.vector" do
    Rubyvis.vector(@x1,@y1).should== @v1
  end
  it "method perp" do
    @v1.perp.should==Rubyvis::Vector.new(-@y1,@x1)
  end
  it "method times" do
    times=rand(10)+1
    @v1.times(times).should==Rubyvis::Vector.new(@x1*times,@y1*times)
  end
  it "method length" do
    l=Math.sqrt(@x1*@x1+@y1*@y1)
    @v1.length.should eq l
  end
  it "method norm" do
    l=@v1.length
    @v1.norm.should==@v1.times(1/l.to_f)
  end
  it "method plus" do
    @v1.plus(@v2).should==Rubyvis::Vector.new(@x1+@x2,@y1+@y2)
  end
  it "method minus" do
    @v1.minus(@v2).should==Rubyvis::Vector.new(@x1-@x2,@y1-@y2)
  end
  it "method dot" do
    @v1.dot(@v2).should==@x1*@x2+@y1*@y2
  end
end

