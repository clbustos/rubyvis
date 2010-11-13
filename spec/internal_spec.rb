require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Rubyvis module methods" do
  describe "from pv.js" do
    it "method identify should always return the same value" do
      f=Rubyvis.identity
      a="a"
      f.js_call(a, 5).should==5
    end
    it "method index should return index method from a object" do
      o1=Rubyvis.o_index(1)
      o2=Rubyvis.o_index(10)
      Rubyvis.index.js_call(o1,1,2).should==1
      Rubyvis.index.js_call(o2,1,2).should==10
    end
  end
  describe "from pv-internal.js" do 
    it "should create a infinite succesion with id" do
      f=Rubyvis.id
      Rubyvis.id.should==f+1
    end
    it "should return a lambda with functor" do
      Rubyvis.functor(5).call.should==5
    end
  end
  describe "from data/Arrays.js" do 
    it "map method should map an array using a index based object" do
      f=lambda {|d| "#{self.index}-#{d}"}
      i=%w{a b c}
      o=%w{0-a 1-b 2-c}
      Rubyvis.map(i).should==i
      Rubyvis.map(i,f).should==o
    end
    it "repeat method should repeat the specified array n times" do
      Rubyvis.repeat([1,2]).should==[1,2,1,2]
      Rubyvis.repeat([1,2],3).should==[1,2,1,2,1,2]
    end
    it "cross method should return an array of all posible pairs of element" do
      Rubyvis.cross([1,2],[3,4]).should==[[1,3],[1,4],[2,3],[2,4]]
    end
    it "blend method should concatenates the arrays into a single array" do
      Rubyvis.blend([[1,2,3],[4,5,6],[7,8,9]]).should==(1..9).to_a
    end
    it "transpose method should returns a transposed array of arrays" do
      Rubyvis.transpose([[1,2,3],[4,5,6]]).should==[[1,4],[2,5],[3,6]]
    end
    it "normalize method should returns a normalized copy of array" do
      Rubyvis.normalize([1,1,3]).should==[0.2,0.2,0.6]
      a=%w{aa ccc ddddd}
      f=lambda {|e| e.size}
      Rubyvis.normalize(a,f).should==[0.2,0.3,0.5]
    end
    it "permute method allows to permute the order of elements" do
      Rubyvis.permute(%w{a b c},[1,2,0]).should==%w{b c a}
      f=lambda {|e| [self.index,e]}
      Rubyvis.permute(%w{a b c},[1,2,0],f).should==[[1,"b"],[2,"c"],[0,"a"]]
    end
    it "numerate should  map from key to index for the specified keys array" do
      Rubyvis.numerate(["a", "b", "c"]).should=={"a"=>0,"b"=>1,"c"=>2}
    end
    it "method uniq returns the unique elements in the specified array" do
      Rubyvis.uniq(["a", "b", "c","c"]).should==["a","b","c"]
      Rubyvis.uniq(["a", "b", "c","c"], lambda{|e| e*2}).should==["aa","bb","cc"]
    end
    it "method search should return correct values" do
      a=(0..9).to_a
      Rubyvis.search(a,1).should==1
      Rubyvis.search(a,20).should==-11
      Rubyvis.search(a,5.5).should==-7
    end
    it "method search_index should return correct values" do
      a=(0..9).to_a
      Rubyvis.search_index(a,1).should==1
      Rubyvis.search_index(a,20).should==10
      Rubyvis.search_index(a,5.5).should==6
    end
  end
  describe "from data/Numbers.js" do
    it "method range should create range of numbers" do
      Rubyvis.range(1,10).should==[1,2,3,4,5,6,7,8,9]
      Rubyvis.range(1,10,0.5).should==[1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5]
      Rubyvis.range(1,10,3).should==[1,4,7]  
      lambda {Rubyvis.range(1,10,0)}.should raise_exception
    end
    it "method random returns a random number between values" do
      srand(10)
      100.times.map{ Rubyvis.random(5)}.uniq.sort.should==(0..4).to_a
      100.times.map{ Rubyvis.random(1,5)}.uniq.sort.should==(1..4).to_a
      100.times.map{ Rubyvis.random(1,3,0.5)}.uniq.sort.should== [1.0,1.5,2.0,2.5]
    end
    it "methods sum returns a sum" do
      Rubyvis.sum([1,2,3,4]).should==(1+2+3+4)
      Rubyvis.sum(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index}).should==(4*1 + 3*2 + 2*3 + 5*4)
    end
    it "method max returns maximum value" do
      Rubyvis.max([1,2,3,4]).should==4
      Rubyvis.max([1,2,3,4], Rubyvis.index).should==3
      Rubyvis.max(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index}).should==20
    end
    it "method max_index returns maximum value index" do
      Rubyvis.max_index([1,2,4,3]).should==2
      Rubyvis.max_index(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index}).should==4
    end
    it "method min returns minimum value" do
      Rubyvis.min([1,2,3,4]).should==1
      Rubyvis.min([1,2,3,4], Rubyvis.index).should==0
      Rubyvis.min(%w{2 0 3 2 5}, lambda {|v| v.to_i + self.index}).should==1
    end
    it "method min_index returns minimum value index" do
      Rubyvis.min_index([1,2,4,-1]).should==3
      Rubyvis.min_index(%w{1 4 3 2 5}, lambda {|v| v.to_i * self.index}).should==0
    end
    it "method mean returns mean of values" do
      a,b,c,d=rand,rand,rand,rand
      #Rubyvis.mean([a,b,c,d]).should==(a+b+c+d).quo(4)
      Rubyvis.mean([a,b,c,d].map {|x| x.to_s}, lambda {|v| v.to_f+1}).should==(a+b+c+d).quo(4)+1
    end
    it "method median returns median of values" do
      Rubyvis.median([1,2,4,3]).should==2.5
      Rubyvis.median([1,3,2,5,3]).should==3
      Rubyvis.median([1,3,2,5,3].map(&:to_s), lambda(&:to_f)).should==3
    end
    it "method variance returns sum of squares" do
      Rubyvis.variance([5,7,9,11]).should==20
      Rubyvis.variance([5,7,9,11], lambda {|x| x+self.index}).should==45
    end
    it "method deviation returns standard deviation" do
      Rubyvis.deviation([5,7,9,11]).should be_within( 0.001).of(2.581)
    end
    it "method log" do
      Rubyvis.log(5,4).should be_within( 0.001).of(1.16)
    end
    it "method log_symmetric" do
      Rubyvis.log_symmetric(-5,4).should be_within( 0.001).of(-1.16)
    end
    it "method log_adjusted" do
      Rubyvis.log_adjusted(6,10).should be_within( 0.001).of(0.806)
    end
    it "method log_floor" do
      Rubyvis.log_floor(-5,4).should be_within( 0.001).of(16)
    end
    it "method log_ceil" do
      Rubyvis.log_ceil(-5,4).should be_within( 0.001).of(-4)
    end
    it "method dict" do
      Rubyvis.dict(["one", "three", "seventeen"], lambda {|s| s.size}).should=={"one"=> 3, "three"=> 5, "seventeen"=> 9}
      Rubyvis.dict(["one", "three", nil, "seventeen"], lambda {|s| s.size}).should=={"one"=> 3, "three"=> 5, "seventeen"=> 9}
      
    end
  end
  
end