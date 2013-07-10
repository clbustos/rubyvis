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
  it "should return correct tick_floor" do
    ct=Time.utc(2012,04,05,10,10,10)
    @y.mock_ticks_floor(ct,:month).should==Time.utc(2012,01,05,10,10,10)
    @y.mock_ticks_floor(ct,:month_day).should==Time.utc(2012,04,01,10,10,10)
    @y.mock_ticks_floor(ct,:week_day).should==Time.utc(2012,04,01,10,10,10)
    @y.mock_ticks_floor(ct,:hour).should==Time.utc(2012,04,05,00,10,10)
    @y.mock_ticks_floor(ct,:minute).should==Time.utc(2012,04,05,10,00,10)
    @y.mock_ticks_floor(ct,:second).should==Time.utc(2012,04,05,10,10,00)
    
  end 
  
  it "should returns correct tick_format" do
    pending()
  end

  it "should nice nicely" do
    pending()
  end
end
