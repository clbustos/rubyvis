require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Javascript compatibility" do
  it "extends Proc with js_apply and js_call" do
    f=lambda {|a,b| a+b}
    expect(f).to respond_to(:js_apply)
    expect(f).to respond_to(:js_call)
  end
  it "lambdas should respond correctly to js_call with same numbers of arguments and parameters" do
    o=OpenStruct.new :x=>15
    f=lambda {|m1,m2| "#{m1}-#{m2}-#{self.x}"}
    expect(f.js_call(o,"a","b")).to eq("a-b-15")
  end
  it "lambdas should respond correctly to js_call without arguments" do
    o=OpenStruct.new :x=>15    
    f=lambda { self.x.to_s}
    expect(f.js_call(o)).to eq("15")    
  end
  it "lambdas should respond correctly to js_call with different number or arguments" do
    o=OpenStruct.new :x=>15    
    f=lambda {|a,b,c| [a,b,c]}
    expect(f.js_call(o,1)).to eq([1,nil,nil])
    expect(f.js_call(o,1,2,3,4)).to eq([1,2,3])
  end
  context "js_call using lambda with variable arguments" do
    before do
      @o=OpenStruct.new :x=>15    
      @f=lambda {|a,b,*c| {:a=>a, :b=>b, :c=>c}}
    end
    it "should work without 0 parameters" do
      expect(@f.js_call(@o)).to eq({:a=>nil, :b=>nil, :c=>[]})
    end
    it "should work with required parameter and 0 optional" do
      expect(@f.js_call(@o,1,2)).to eq({:a=>1, :b=>2, :c=>[]})
    end
    it "should work with required and optional parameters" do
      expect(@f.js_call(@o,1,2,3,4)).to eq({:a=>1, :b=>2, :c=>[3,4]})
    end
  end
  it "lambdas should respond correctly to js_apply" do
    o=OpenStruct.new :x=>15
    f=lambda {|m1,m2| "#{m1}-#{m2}-#{self.x}"}
    expect(f.js_apply(o, ["a","b"])).to eq("a-b-15")
  end
  it "lambdas should respond correctly to js_apply with empty arguments" do
    o=OpenStruct.new :x=>15
    f=lambda { "#{self.x}"}
    expect(f.js_apply(o, [])).to eq("15")
    expect(f.js_apply(o, [1])).to eq("15")

  end
  
  it "lambdas should respond correctly to js_call with fewer parameters" do
    o=OpenStruct.new :x=>15    
    f=lambda {|a,b,c| [a,b,c]}
    expect(f.js_apply(o,[1])).to eq([1,nil,nil])
  end
  it "lambdas should respond correctly to js_call with more parameters" do
    o=OpenStruct.new :x=>15    
    f=lambda {|a,b,c| [a,b,c]}    
    expect(f.js_apply(o,[1,2,3,4])).to eq([1,2,3])    
  end
  
  
end