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
        @y.domain.should==@rt.evaluate("y.domain()").to_a
        @y.domain(@v1,@v2,@v3)
        @rt.evaluate("y.domain(v1,v2,v3)")
        @y.domain.should==@rt.evaluate("y.domain()").to_a        
      end
      it "scale() implemented equally for complex domain" do
        @y.domain(@v1,@v2,@v3)
        @rt.evaluate("y.domain(v1,v2,v3)")
        @y.scale(@v1+1).should==@rt.evaluate("y(v1+1)")
        @y.scale(@v2+1).should==@rt.evaluate("y(v2+1)")
        @y.scale(@v3+1).should==@rt.evaluate("y(v3+1)")
      end
      it "invert() implemented equally" do
        @y.domain(@v1,@v2,@v3)
        @rt.evaluate("y.domain(v1,v2,v3)")
        @y.invert(@v1+1).should==@rt.evaluate("y.invert(v1+1)")
        @y.invert(@v2+1).should==@rt.evaluate("y.invert(v2+1)")
        @y.invert(@v3+1).should==@rt.evaluate("y.invert(v3+1)")
      end
      it "ticks() implemented equally for numbers" do
        @y.ticks.should==@rt.evaluate("y.ticks()").to_a
        (5..20).each {|i|
          @rt[:i]=i
          @y.ticks(i).should==@rt.evaluate("y.ticks(i)").to_a
        }
      end
      it "nice() implemented equally" do
        @y.domain(@v1,@v2)
        @rt.evaluate("y.domain(v1,v2)")
        @y.nice
        @rt.evaluate("y.nice()")
        @y.domain.should==@rt.evaluate("y.domain()").to_a
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
    @y.should be_a(Rubyvis::Scale::Linear)
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
    @y.scale(val).should be_within( 0.001).of(val.quo(@h_dom)*@h.to_f)
  end
  it "should returns correct invert" do
    @y.invert(100).should be_within( 0.001).of(357.1428)
    @y.invert(200).should be_within( 0.001).of(714.2857)
  end
  it "should returns correct ticks" do
    @y.ticks.should==[0,100,200,300,400,500,600,700,800,900,1000]
    @y.ticks(13).should==[0,100,200,300,400,500,600,700,800,900,1000]
    @y.ticks(5).should==[0,200,400,600,800,1000]

  end
  it "should nice nicely" do
    @y.domain([0.20147987687960267, 0.996679553296417])
    @y.nice
    @y.domain().should==[0.2,1]
  end
  
  it "should returns correct tick_format" do
    @y.tick_format.should be_instance_of Proc
    @y.tick_format.call( 2).should=='2'
    @y.tick_format.call(2.0).should=='2'
    @y.tick_format.call(2.1).should=='2.1'
    @y.tick_format.call("a").should==''
  end
  it "should return correct tick_format for small numbers" do
    @y.domain(0.00001,0.0001)
    @y.range(0.000001,0.0001)
    @y.ticks.should==[1.quo(100000), 1.quo(50000), 3.quo(100000), 1.quo(25000), 1.quo(20000), 3.quo(50000), 7.quo(100000), 1.quo(12500), 9.quo(100000), 1.quo(10000)]
    @y.tick_format.call(0.2).should=='0.20000'
  end
  it "should return correct by" do
    by=@y.by(lambda {|v| v.value})
    a=OpenStruct.new({:value=>rand})
    by.call(a).should==@y[a.value]
  end
  
  
end