require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Scale::Ordinal do
  if Rubyvis::JohnsonLoader.available?
    context "direct protovis API comparison" do 
      before(:all) do
        @rt=  Rubyvis::JohnsonLoader.new("/data/OrdinalScale.js").runtime
      end
      before do 
        @base  = %w{a b c d e f}
        @range = %w{black red white orange yellow blue}
        @n=rand(3)+3
        @base=@base[0,@n]
        @range=@range[0,@n]        
        @y = Rubyvis.Scale.ordinal(@base).range(@range)
        @rt[:domain] = @base
        @rt[:range] = @range
        @y_js=@rt.evaluate("y=pv.Scale.ordinal(domain).range(range)")

      end
      
      it "domain() implemented equally" do
        @y.domain(@base[0])
        @rt.evaluate("y.domain(domain[0])")
        @y.domain.should==@rt.evaluate("y.domain()").to_a
        @y.domain(@base[0],@base[1])
        @rt.evaluate("y.domain(domain[0],domain[1])")
        @y.domain.should==@rt.evaluate("y.domain()").to_a        
      end
      
    end
  end
  describe "on ruby domain" do 
    it "should be created as Javascript" do
      lambda {y = Rubyvis.Scale.ordinal(%w{a b c}).range(%w{red blue black})}.should_not raise_exception
    end
    
    before do
      @domain=%w{a b c}
      @range=%w{red white blue}
      @y = Rubyvis.Scale.ordinal(@domain).range(@range)
    end
    it "y should be a Scale::Ordinal" do
      @y.should be_a(Rubyvis::Scale::Ordinal)
    end
    it "should respond to domain" do
      @y.domain.should==%w{a b c}
      @y.domain(%w{a})
      @y.domain.should==%w{a}
      @y.domain(1,100,300)
      @y.domain.should==[1,100,300]
    end
    it "should respond to range" do
      @y.range.should==@range.map {|c| pv.color(c)}
      @y.range('red')
      @y.range.should==[pv.color('red')]
      @y.range('black','white')
      @y.range.should==[pv.color('black'), pv.color('white')]
    end
    it "should returns correct scale with unknown values" do
      @y.scale(1).should==pv.color('red')
      @y.scale('x').should==pv.color('white')
      @y.scale(9).should==pv.color('blue')
      @y.scale(1).should==pv.color('red')      
    end
    it "should return the same using [] and scale()" do
      a=rand()
      @y[a].should==@y.scale(a)
    end
    it "should returns correct scale with known values" do
      @y.scale('a').should==pv.color('red')
      @y.scale('b').should==pv.color('white')
      @y.scale('c').should==pv.color('blue')
    end
    it "should return correct by" do
      @y = Rubyvis.Scale.ordinal(@domain).range(@range).by(lambda {|v| v.nombre})
      a=OpenStruct.new({:nombre=>'c'})
      b=OpenStruct.new({:nombre=>'b'})
      c=OpenStruct.new({:nombre=>'a'})
      @y.call(a).should==pv.color('blue')
      @y.call(b).should==pv.color('white')
      @y.call(c).should==pv.color('red')
      
    end
  end
end