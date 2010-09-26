require File.dirname(__FILE__)+"/spec_helper.rb"
describe Protoruby::Scale::Linear do
  it "should be created as Javascript" do
    h=280
    y = Protoruby.Scale.linear(0, 1500)
  end
  before do
    @h=280
    @h_dom=1000
    @y = Protoruby.Scale.linear(0, @h_dom).range(0,@h)
  end
  it "y should be a Scale" do
    @y.should be_a(Protoruby::Scale::Linear)
  end
  it "should set domain with dates" do
    pending("Should accept dates as domain values")
    data= [
    { :date=> Date.today, :wounds=> 0, :other=> 110, :disease=> 110 },
    { :date=> Date.new, :wounds=> 2, :other=> 130, :disease=> 110 }
    
    ]
    x=Protoruby.Scale.linear(data, lambda {|d| d[:date]})
    
  end
  it "should respond to domain" do
    @y.domain.should==[0, 1000]
    @y.domain(1)
    @y.domain.should==[1,1]
    @y.domain(1,100,300)
    @y.domain.should==[1,100,300]
  end
  it "should respond to range" do
    @y.range.should==[0, 280]
    @y.range(1)
    @y.range.should==[1,1]
    @y.range(1,100,300)
    @y.range.should==[1,100,300]
  end
  it "should returns correct scale" do
    @y.scale(@h_dom).should==280
    @y[@h_dom].should==280
    val=20
    @y.scale(val).should be_close(val.quo(@h_dom)*@h.to_f, 0.001)
  end
  it "should returns correct invert" do
    @y.invert(100).should be_close(357.1428, 0.001)
    @y.invert(200).should be_close(714.2857, 0.001)
  end
  it "should returns correct ticks" do
    @y.ticks.should==[0,100,200,300,400,500,600,700,800,900,1000]
    @y.ticks(13).should==[0,100,200,300,400,500,600,700,800,900,1000]
    @y.ticks(5).should==[0,200,400,600,800,1000]

  end
  it "should returns correct tick_format" do
    @y.tick_format(5).should=="5"
  end
  it "should nice nicely" do
    @y.domain([0.20147987687960267, 0.996679553296417])
    @y.nice
    @y.domain().should==[0.2,1]
    
  end
end