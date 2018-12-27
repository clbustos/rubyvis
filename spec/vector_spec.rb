require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Vector do
  before do
    @x1,@x2,@y1,@y2=rand(10)+1,rand(10)+1,rand(10)+1,rand(10)+1
    @v1=Rubyvis::Vector.new(@x1,@y1)
    @v2=Rubyvis::Vector.new(@x2,@y2)
  end
  it "should return the same as Rubyvis.vector" do
    expect(Rubyvis.vector(@x1,@y1)).to eq(@v1)
  end
  it "method perp" do
    expect(@v1.perp).to eq(Rubyvis::Vector.new(-@y1,@x1))
  end
  it "method times" do
    times=rand(10)+1
    expect(@v1.times(times)).to eq(Rubyvis::Vector.new(@x1*times,@y1*times))
  end
  it "method length" do
    l=Math.sqrt(@x1*@x1+@y1*@y1)
    expect(@v1.length).to eq l
  end
  it "method norm" do
    l=@v1.length
    expect(@v1.norm).to eq(@v1.times(1/l.to_f))
  end
  it "method plus" do
    expect(@v1.plus(@v2)).to eq(Rubyvis::Vector.new(@x1+@x2,@y1+@y2))
  end
  it "method minus" do
    expect(@v1.minus(@v2)).to eq(Rubyvis::Vector.new(@x1-@x2,@y1-@y2))
  end
  it "method dot" do
    expect(@v1.dot(@v2)).to eq(@x1*@x2+@y1*@y2)
  end
end

