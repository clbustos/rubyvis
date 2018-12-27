require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Scale::Linear do
  if Rubyvis::JohnsonLoader.available?
    context "direct protovis API comparison" do 
      before(:all) do
        @rt=  Rubyvis::JohnsonLoader.new().runtime
      end
      before do 
        @h=280
        @h_dom=1000
        @y = Rubyvis.Scale.linear(0, @h_dom).range(0,@h)
        @rt[:h_dom] = @h_dom
        @rt[:h] = @h
        @y_js=@rt.evaluate("y=pv.Scale.linear(0, h_dom).range(0,h)")
        @v1,@v2,@v3=rand(),rand()+3,rand()+5
        @rt[:v1]=@v1
        @rt[:v2]=@v2
        @rt[:v3]=@v3

      end
      it "domain() implemented equally" do
        @y.domain(@v1)
        @rt.evaluate("y.domain(v1)")
        expect(@y.domain).to eq(@rt.evaluate("y.domain()").to_a)
        @y.domain(@v1,@v2,@v3)
        @rt.evaluate("y.domain(v1,v2,v3)")
        expect(@y.domain).to eq(@rt.evaluate("y.domain()").to_a)        
      end
      it "scale() implemented equally for complex domain" do
        @y.domain(@v1,@v2,@v3)
        @rt.evaluate("y.domain(v1,v2,v3)")
        expect(@y.scale(@v1+1)).to eq(@rt.evaluate("y(v1+1)"))
        expect(@y.scale(@v2+1)).to eq(@rt.evaluate("y(v2+1)"))
        expect(@y.scale(@v3+1)).to eq(@rt.evaluate("y(v3+1)"))
      end
      it "invert() implemented equally" do
        @y.domain(@v1,@v2,@v3)
        @rt.evaluate("y.domain(v1,v2,v3)")
        expect(@y.invert(@v1+1)).to eq(@rt.evaluate("y.invert(v1+1)"))
        expect(@y.invert(@v2+1)).to eq(@rt.evaluate("y.invert(v2+1)"))
        expect(@y.invert(@v3+1)).to eq(@rt.evaluate("y.invert(v3+1)"))
      end
      it "ticks() implemented equally for numbers" do
        expect(@y.ticks).to eq(@rt.evaluate("y.ticks()").to_a)
        (5..20).each {|i|
          @rt[:i]=i
          expect(@y.ticks(i)).to eq(@rt.evaluate("y.ticks(i)").to_a)
        }
      end
      it "nice() implemented equally" do
        @y.domain(@v1,@v2)
        @rt.evaluate("y.domain(v1,v2)")
        @y.nice
        @rt.evaluate("y.nice()")
        expect(@y.domain).to eq(@rt.evaluate("y.domain()").to_a)
      end
   
    end
    
  end
  it "should be created as Javascript" do
    h=280
    y = Rubyvis.Scale.linear(0, 1500)
  end
  
  before do
    @h=280
    @h_dom=1000
    @y = Rubyvis.Scale.linear(0, @h_dom).range(0,@h)
  end
  it "y should be a Scale" do
    expect(@y).to be_a(Rubyvis::Scale::Linear)
  end
  it "should respond to domain" do
    expect(@y.domain).to eq([0, 1000])
    @y.domain(1)
    expect(@y.domain).to eq([1,1])
    @y.domain(1,100,300)
    expect(@y.domain).to eq([1,100,300])
  end
  it "should respond to range" do
    expect(@y.range).to eq([0, 280])
    @y.range(1)
    expect(@y.range).to eq([1,1])
    @y.range(1,100,300)
    expect(@y.range).to eq([1,100,300])
  end
  it "should returns correct scale" do
    expect(@y.scale(@h_dom)).to eq(280)
    expect(@y[@h_dom]).to eq(280)
    val=20
    expect(@y.scale(val)).to be_within( 0.001).of(val.quo(@h_dom)*@h.to_f)
  end
  it "should return correct scale when values are extracted from data " do
    data = pv.range(0, 10, 0.1).map {|x| OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2+rand()}) }
    w = 400
    h = 200
    x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)
    y = pv.Scale.linear(data, lambda {|d| d.y}).range(0, h)
    expect {y.scale 0.5}.not_to raise_error
  end
  it "should returns correct invert" do
    expect(@y.invert(100)).to be_within( 0.001).of(357.1428)
    expect(@y.invert(200)).to be_within( 0.001).of(714.2857)
  end
  it "should returns correct ticks" do
    expect(@y.ticks).to eq([0,100,200,300,400,500,600,700,800,900,1000])
    expect(@y.ticks(13)).to eq([0,100,200,300,400,500,600,700,800,900,1000])
    expect(@y.ticks(5)).to eq([0,200,400,600,800,1000])
  end
  it "should return correct tick when domain is a scalar" do
    expect(@y.domain(1,1,1).ticks).to eq([1])
  end

  it "should nice nicely" do
    @y.domain([0.20147987687960267, 0.996679553296417])
    @y.nice
    expect(@y.domain()).to eq([0.2,1])
  end
  
  it "should returns correct tick_format" do
    expect(@y.tick_format).to be_instance_of Proc
    expect(@y.tick_format.call( 2)).to eq('2')
    expect(@y.tick_format.call(2.0)).to eq('2')
    expect(@y.tick_format.call(2.1)).to eq('2.1')
    expect(@y.tick_format.call("a")).to eq('')
  end
  it "should return correct tick_format for small numbers" do
    @y.domain(0.00001,0.0001)
    @y.range(0.000001,0.0001)
    expect(@y.ticks).to eq([1.quo(100000), 1.quo(50000), 3.quo(100000), 1.quo(25000), 1.quo(20000), 3.quo(50000), 7.quo(100000), 1.quo(12500), 9.quo(100000), 1.quo(10000)])
    expect(@y.tick_format.call(0.2)).to eq('0.20000')
  end
  it "should return correct by" do
    by=@y.by(lambda {|v| v.value})
    a=OpenStruct.new({:value=>rand})
    expect(by.call(a)).to eq(@y[a.value])
  end
  
end