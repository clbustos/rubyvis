require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Scale::Log do
  if Rubyvis::JohnsonLoader.available?
    context "direct protovis API comparison" do 
      before(:all) do
        @rt=  Rubyvis::JohnsonLoader.new("/data/LogScale.js").runtime
      end
      before do 
        @h=280
        @h_dom=1000
        @y = Rubyvis.Scale.log(1, @h_dom).range(1,@h)
        @rt[:h_dom] = @h_dom
        @rt[:h] = @h
        @y_js=@rt.evaluate("y=pv.Scale.log(1, h_dom).range(1,h)")
        @v1,@v2,@v3=rand()+1,rand()+3,rand()+5
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
    y = Rubyvis.Scale.log(1, 1500)
  end
  
  before do
    @h=280
    @h_dom=1000
    @y = Rubyvis.Scale.log(1, @h_dom).range(1,@h)
  end
  it "y should be a Scale" do
    expect(@y).to be_a(Rubyvis::Scale::Log)
  end
  it "should respond to domain" do
    expect(@y.domain).to eq([1, 1000])
    @y.domain(1)
    expect(@y.domain).to eq([1,1])
    @y.domain(1,100,300)
    expect(@y.domain).to eq([1,100,300])
  end
  it "should respond to range" do
    expect(@y.range).to eq([1, 280])
    @y.range(1)
    expect(@y.range).to eq([1,1])
    @y.range(1,100,300)
    expect(@y.range).to eq([1,100,300])
  end
  it "should returns correct scale" do
    expect(@y.scale(@h_dom)).to eq(280)
    expect(@y[@h_dom]).to eq(280)
    val=20
    expect(@y.scale(val)).to be_within( 0.001).of(121.995)
  end
  it "should returns correct invert" do
    expect(@y.invert(100)).to be_within( 0.001).of(11.601)
    expect(@y.invert(200)).to be_within( 0.001).of(137.970)
  end
  it "should returns correct ticks" do
    t=1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000
    expect(@y.ticks).to eq(t)
  end
  it "should return :ArgumentError on domain that includes 0 or less" do
    h=280
    h_dom=1000
    expect {Rubyvis.Scale.log(-1, @h_dom)}.to raise_error(ArgumentError)
    
  end
  it "should returns correct ticks with subdivisions" do
    t=1,5,10,50,100,500,1000
    expect(@y.ticks(2)).to eq(t)
    t=1,2.5,5,7.5,10,25,50,75,100,250,500,750,1000
    expect(@y.ticks(4)).to eq(t)
    t=1,2,4,6,8,10,20,40,60,80,100,200,400,600,800,1000
    expect(@y.ticks(5)).to eq(t)
    t=1,10,100,1000
    expect(@y.ticks(1)).to eq(t)
  end
  it "should nice nicely" do
    @y.domain([0.20147987687960267, 0.996679553296417])
    @y.nice
    expect(@y.domain()).to eq([0.1,1])
  end  
end
