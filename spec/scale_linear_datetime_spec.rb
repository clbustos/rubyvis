require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Rubyvis::Scale::Linear with dates" do
  it "should be created as Javascript" do
    h=280
    y = Rubyvis.Scale.linear(Time.utc(2010,1,1), Time.utc(2010,2,1))
  end
  
  before do
    @bd=Time.utc(2010,1,1)
    @ed=Time.utc(2010,2,1)
    @h=280
    @y = Rubyvis.Scale.linear(@bd, @ed).range(0,@h)
  end
  it "y should be a Scale" do
    @y.should be_a(Rubyvis::Scale::Linear)
  end
  it "should respond to domain" do
    @y.domain.should==[@bd, @ed]
    @y.domain(@bd)
    @y.domain.should==[@bd,@bd]
    @y.domain(@bd,@ed,@ed+1)
    @y.domain.should==[@bd,@ed,@ed+1]
  end
  it "should respond to range" do
    @y.range.should==[0, @h]
    @y.range(1)
    @y.range.should==[1,1]
    @y.range(1,100,300)
    @y.range.should==[1,100,300]
  end
  it "should returns correct scale" do
    @y.scale(@bd).should==0
    @y.scale(@ed).should==@h
    @y[@ed].should==@h
    val= (@ed.to_f+@bd.to_f) / 2.0
    @y.scale(val).should be_within( 0.001).of(@h / 2.0)
  end
  it "should returns correct invert" do
    @y.invert(0).should==@bd
    @y.invert(@h).should==@ed
  end
  it "should returns correct ticks" do
    @y.ticks.size.should==5
    @y.ticks(5).size.should==5
    @y.ticks(5)[0].should be_instance_of Time
    
    #p @y.ticks
  end
  it "should returns correct tick_format" do
    pending()
  end

  it "should nice nicely" do
    pending()
  end
end