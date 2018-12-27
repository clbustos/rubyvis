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
    def @y.mock_ticks_floor(d,prec) 
      ticks_floor(d,prec)
    end
  end
  it "should not crash on :week_day precision (bug #15)" do
    ct=Time.utc(2012,03,19,10,10,10)
    expect(@y.mock_ticks_floor(ct,:week_day)).to eq(Time.utc(2012,03,18,10,10,10))
  end
  it "y should be a Scale" do
    expect(@y).to be_a(Rubyvis::Scale::Linear)
  end
  it "should respond to domain" do
    expect(@y.domain).to eq([@bd, @ed])
    @y.domain(@bd)
    expect(@y.domain).to eq([@bd,@bd])
    @y.domain(@bd,@ed,@ed+1)
    expect(@y.domain).to eq([@bd,@ed,@ed+1])
  end
  it "should respond to range" do
    expect(@y.range).to eq([0, @h])
    @y.range(1)
    expect(@y.range).to eq([1,1])
    @y.range(1,100,300)
    expect(@y.range).to eq([1,100,300])
  end
  it "should returns correct scale" do
    expect(@y.scale(@bd)).to eq(0)
    expect(@y.scale(@ed)).to eq(@h)
    expect(@y[@ed]).to eq(@h)
    val= (@ed.to_f+@bd.to_f) / 2.0
    expect(@y.scale(val)).to be_within( 0.001).of(@h / 2.0)
  end
  it "should returns correct invert" do
    expect(@y.invert(0)).to eq(@bd)
    expect(@y.invert(@h)).to eq(@ed)
  end
  it "should returns correct ticks" do
    expect(@y.ticks.size).to eq(5)
    expect(@y.ticks(5).size).to eq(5)
    expect(@y.ticks(5)[0]).to be_instance_of Time
    
    #p @y.ticks
  end
  it "should return correct tick_floor" do
    ct=Time.utc(2012,04,05,10,10,10)
    expect(@y.mock_ticks_floor(ct,:month)).to eq(Time.utc(2012,01,05,10,10,10))
    expect(@y.mock_ticks_floor(ct,:month_day)).to eq(Time.utc(2012,04,01,10,10,10))
    expect(@y.mock_ticks_floor(ct,:week_day)).to eq(Time.utc(2012,04,01,10,10,10))
    expect(@y.mock_ticks_floor(ct,:hour)).to eq(Time.utc(2012,04,05,00,10,10))
    expect(@y.mock_ticks_floor(ct,:minute)).to eq(Time.utc(2012,04,05,10,00,10))
    expect(@y.mock_ticks_floor(ct,:second)).to eq(Time.utc(2012,04,05,10,10,00))
    
  end 
  
  it "should returns correct tick_format"
  it "should nice nicely"
  
end
