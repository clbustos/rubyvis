require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Javascript compatibility" do
  it "extends Proc with js_apply and js_call" do
    f=lambda {|a,b| a+b}
    f.should respond_to(:js_apply)
    f.should respond_to(:js_call)
  end
  it "lambdas should respond correctly to js_call with same numbers of arguments and parameters" do
    o=OpenStruct.new :x=>15
    f=lambda {|m1,m2| "#{m1}-#{m2}-#{self.x}"}
    f.js_call(o,"a","b").should=="a-b-15"
  end
  it "lambdas should respond correctly to js_call without arguments" do
    o=OpenStruct.new :x=>15    
    f=lambda { self.x.to_s}
    f.js_call(o).should=="15"    
  end
  it "lambdas should respond correctly to js_call with different number or arguments" do
    o=OpenStruct.new :x=>15    
    f=lambda {|a,b,c| [a,b,c]}
    f.js_call(o,1).should==[1,nil,nil]
    f.js_call(o,1,2,3,4).should==[1,2,3]
  end
  context "js_call using lambda with variable arguments" do
    before do
      @o=OpenStruct.new :x=>15    
      @f=lambda {|a,b,*c| {:a=>a, :b=>b, :c=>c}}
    end
    it "should work without 0 parameters" do
      @f.js_call(@o).should=={:a=>nil, :b=>nil, :c=>[]}
    end
    it "should work with required parameter and 0 optional" do
      @f.js_call(@o,1,2).should=={:a=>1, :b=>2, :c=>[]}
    end
    it "should work with required and optional parameters" do
      @f.js_call(@o,1,2,3,4).should=={:a=>1, :b=>2, :c=>[3,4]}
    end
  end
  it "lambdas should respond correctly to js_apply" do
    o=OpenStruct.new :x=>15
    f=lambda {|m1,m2| "#{m1}-#{m2}-#{self.x}"}
    f.js_apply(o, ["a","b"]).should=="a-b-15"
  end
  it "lambdas should respond correctly to js_apply with empty arguments" do
    o=OpenStruct.new :x=>15
    f=lambda { "#{self.x}"}
    f.js_apply(o, []).should=="15"
    f.js_apply(o, [1]).should=="15"

  end
  
  it "lambdas should respond correctly to js_call with fewer parameters" do
    o=OpenStruct.new :x=>15    
    f=lambda {|a,b,c| [a,b,c]}
    f.js_apply(o,[1]).should==[1,nil,nil]
  end
  it "lambdas should respond correctly to js_call with more parameters" do
    o=OpenStruct.new :x=>15    
    f=lambda {|a,b,c| [a,b,c]}    
    f.js_apply(o,[1,2,3,4]).should==[1,2,3]    
  end
  
  
end