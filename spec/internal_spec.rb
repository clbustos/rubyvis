require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Rubyvis module methods" do
  describe "from pv.js" do
    it "method identify should always return the same value" do
      f=Rubyvis.identity
      a="a"
      expect(f.js_call(a, 5)).to eq(5)
    end
    it "method index should return index method from a object" do
      o1=Rubyvis.o_index(1)
      o2=Rubyvis.o_index(10)
      expect(Rubyvis.index.js_call(o1,1,2)).to eq(1)
      expect(Rubyvis.index.js_call(o2,1,2)).to eq(10)
    end
  end
  describe "from pv-internal.js" do 
    it "should create a infinite succesion with id" do
      f=Rubyvis.id
      expect(Rubyvis.id).to eq(f+1)
    end
    it "should return a lambda with functor" do
      expect(Rubyvis.functor(5).call).to eq(5)
    end
  end
  describe "from data/Arrays.js" do 
    it "map method should map an array using a index based object" do
      f=lambda {|d| "#{self.index}-#{d}"}
      i=%w{a b c}
      o=%w{0-a 1-b 2-c}
      expect(Rubyvis.map(i)).to eq(i)
      expect(Rubyvis.map(i,f)).to eq(o)
    end
    it "repeat method should repeat the specified array n times" do
      expect(Rubyvis.repeat([1,2])).to eq([1,2,1,2])
      expect(Rubyvis.repeat([1,2],3)).to eq([1,2,1,2,1,2])
    end
    it "cross method should return an array of all posible pairs of element" do
      expect(Rubyvis.cross([1,2],[3,4])).to eq([[1,3],[1,4],[2,3],[2,4]])
    end
    it "blend method should concatenates the arrays into a single array" do
      expect(Rubyvis.blend([[1,2,3],[4,5,6],[7,8,9]])).to eq((1..9).to_a)
    end
    it "transpose method should returns a transposed array of arrays" do
      expect(Rubyvis.transpose([[1,2,3],[4,5,6]])).to eq([[1,4],[2,5],[3,6]])
    end
    it "normalize method should returns a normalized copy of array" do
      expect(Rubyvis.normalize([1,1,3])).to eq([0.2,0.2,0.6])
      a=%w{aa ccc ddddd}
      f=lambda {|e| e.size}
      expect(Rubyvis.normalize(a,f)).to eq([0.2,0.3,0.5])
    end
    it "permute method allows to permute the order of elements" do
      expect(Rubyvis.permute(%w{a b c},[1,2,0])).to eq(%w{b c a})
      f=lambda {|e| [self.index,e]}
      expect(Rubyvis.permute(%w{a b c},[1,2,0],f)).to eq([[1,"b"],[2,"c"],[0,"a"]])
    end
    it "numerate should  map from key to index for the specified keys array" do
      expect(Rubyvis.numerate(["a", "b", "c"])).to eq({"a"=>0,"b"=>1,"c"=>2})
    end
    it "method uniq returns the unique elements in the specified array" do
      expect(Rubyvis.uniq(["a", "b", "c","c"])).to eq(["a","b","c"])
      expect(Rubyvis.uniq(["a", "b", "c","c"], lambda{|e| e*2})).to eq(["aa","bb","cc"])
    end
    it "method search should return correct values" do
      a=(0..9).to_a
      expect(Rubyvis.search(a,1)).to eq(1)
      expect(Rubyvis.search(a,20)).to eq(-11)
      expect(Rubyvis.search(a,5.5)).to eq(-7)
    end
    it "method search_index should return correct values" do
      a=(0..9).to_a
      expect(Rubyvis.search_index(a,1)).to eq(1)
      expect(Rubyvis.search_index(a,20)).to eq(10)
      expect(Rubyvis.search_index(a,5.5)).to eq(6)
    end
  end
  describe "from data/Numbers.js" do
    it "method range should create range of numbers" do
      expect(Rubyvis.range(1,10)).to eq([1,2,3,4,5,6,7,8,9])
      expect(Rubyvis.range(1,10,0.5)).to eq([1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5])
      expect(Rubyvis.range(1,10,3)).to eq([1,4,7])  
      expect {Rubyvis.range(1,10,0)}.to raise_exception
    end
    it "method random returns a random number between values" do
      srand(10)
      expect(100.times.map{ Rubyvis.random(5)}.uniq.sort).to eq((0..4).to_a)
      expect(100.times.map{ Rubyvis.random(1,5)}.uniq.sort).to eq((1..4).to_a)
      expect(100.times.map{ Rubyvis.random(1,3,0.5)}.uniq.sort).to eq([1.0,1.5,2.0,2.5])
    end
    it "methods sum returns a sum" do
      expect(Rubyvis.sum([1,2,3,4])).to eq(1+2+3+4)
      expect(Rubyvis.sum(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index})).to eq(4*1 + 3*2 + 2*3 + 5*4)
    end
    it "method max returns maximum value" do
      expect(Rubyvis.max([1,2,3,4])).to eq(4)
      expect(Rubyvis.max([1,2,3,4], Rubyvis.index)).to eq(3)
      expect(Rubyvis.max(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index})).to eq(20)
    end
    it "method max_index returns maximum value index" do
      expect(Rubyvis.max_index([1,2,4,3])).to eq(2)
      expect(Rubyvis.max_index(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index})).to eq(4)
    end
    it "method min returns minimum value" do
      expect(Rubyvis.min([1,2,3,4])).to eq(1)
      expect(Rubyvis.min([1,2,3,4], Rubyvis.index)).to eq(0)
      expect(Rubyvis.min(%w{2 0 3 2 5}, lambda {|v| v.to_i + self.index})).to eq(1)
    end
    it "method min_index returns minimum value index" do
      expect(Rubyvis.min_index([1,2,4,-1])).to eq(3)
      expect(Rubyvis.min_index(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index})).to eq(0)
    end
    it "method mean returns mean of values" do
      a,b,c,d=rand,rand,rand,rand
      #Rubyvis.mean([a,b,c,d]).should==(a+b+c+d).quo(4)
      expect(Rubyvis.mean([a,b,c,d].map {|x| x.to_s}, lambda {|v| v.to_f+1})).to eq((a+b+c+d).quo(4)+1)
    end
    it "method median returns median of values" do
      expect(Rubyvis.median([1,2,4,3])).to eq(2.5)
      expect(Rubyvis.median([1,3,2,5,3])).to eq(3)
      expect(Rubyvis.median([1,3,2,5,3].map {|v| v.to_s}, lambda {|v| v.to_f})).to eq(3)
    end
    it "method variance returns sum of squares" do
      expect(Rubyvis.variance([5,7,9,11])).to eq(20)
      expect(Rubyvis.variance([5,7,9,11], lambda {|x| x+self.index})).to eq(45)
    end
    it "method deviation returns standard deviation" do
      expect(Rubyvis.deviation([5,7,9,11])).to be_within( 0.001).of(2.581)
    end
    it "method log" do
      expect(Rubyvis.log(5,4)).to be_within( 0.001).of(1.16)
    end
    it "method log_symmetric" do
      expect(Rubyvis.log_symmetric(-5,4)).to be_within( 0.001).of(-1.16)
    end
    it "method log_adjusted" do
      expect(Rubyvis.log_adjusted(6,10)).to be_within( 0.001).of(0.806)
    end
    it "method log_floor" do
      expect(Rubyvis.log_floor(-5,4)).to be_within( 0.001).of(16)
    end
    it "method log_ceil" do
      expect(Rubyvis.log_ceil(-5,4)).to be_within( 0.001).of(-4)
    end
    it "method dict" do
      expect(Rubyvis.dict(["one", "three", "seventeen"], lambda {|s| s.size})).to eq({"one"=> 3, "three"=> 5, "seventeen"=> 9})
      expect(Rubyvis.dict(["one", "three", nil, "seventeen"], lambda {|s| s.size})).to eq({"one"=> 3, "three"=> 5, "seventeen"=> 9})
      
    end
  end
  
end
