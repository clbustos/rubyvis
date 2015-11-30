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
        expect(@y.domain).to eq(@rt.evaluate("y.domain()").to_a)
        @y.domain(@base[0],@base[1])
        @rt.evaluate("y.domain(domain[0],domain[1])")
        expect(@y.domain).to eq(@rt.evaluate("y.domain()").to_a)        
      end
      
    end
  end
  describe "on ruby domain" do 
    it "should be created as Javascript" do
      expect {y = Rubyvis.Scale.ordinal(%w{a b c}).range(%w{red blue black})}.not_to raise_exception
    end
    
    before do
      @domain=%w{a b c}
      @range=%w{red white blue}
      @y = Rubyvis.Scale.ordinal(@domain).range(@range)
    end
    it "y should be a Scale::Ordinal" do
      expect(@y).to be_a(Rubyvis::Scale::Ordinal)
    end
    it "should respond to domain" do
      expect(@y.domain).to eq(%w{a b c})
      @y.domain(%w{a})
      expect(@y.domain).to eq(%w{a})
      @y.domain(1,100,300)
      expect(@y.domain).to eq([1,100,300])
    end
    it "should respond to range" do
      expect(@y.range).to eq(@range.map {|c| pv.color(c)})
      @y.range('red')
      expect(@y.range).to eq([pv.color('red')])
      @y.range('black','white')
      expect(@y.range).to eq([pv.color('black'), pv.color('white')])
    end
    it "should returns correct scale with unknown values" do
      expect(@y.scale(1)).to eq(pv.color('red'))
      expect(@y.scale('x')).to eq(pv.color('white'))
      expect(@y.scale(9)).to eq(pv.color('blue'))
      expect(@y.scale(1)).to eq(pv.color('red'))      
    end
    it "should return the same using [] and scale()" do
      a=rand()
      expect(@y[a]).to eq(@y.scale(a))
    end
    it "should returns correct scale with known values" do
      expect(@y.scale('a')).to eq(pv.color('red'))
      expect(@y.scale('b')).to eq(pv.color('white'))
      expect(@y.scale('c')).to eq(pv.color('blue'))
    end
    it "should return correct by" do
      @y = Rubyvis.Scale.ordinal(@domain).range(@range).by(lambda {|v| v.nombre})
      a=OpenStruct.new({:nombre=>'c'})
      b=OpenStruct.new({:nombre=>'b'})
      c=OpenStruct.new({:nombre=>'a'})
      expect(@y.call(a)).to eq(pv.color('blue'))
      expect(@y.call(b)).to eq(pv.color('white'))
      expect(@y.call(c)).to eq(pv.color('red'))
      
    end
  end
end