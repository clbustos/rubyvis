require File.dirname(__FILE__)+"/spec_helper.rb"
describe "Javascript simulation" do
  it "extends Proc with js_apply and js_call" do
    f=lambda {|a,b| a+b}
    f.should respond_to(:js_apply)
    f.should respond_to(:js_call)
  end
  it "lambdas should respond correctly to js_call" do
    o=OpenStruct.new :x=>15
    f=lambda {|m1,m2| "#{m1}-#{m2}-#{self.x}"}
    f.js_call(o,"a","b").should=="a-b-15"
  end
  it "lambdas should respond correctly to js_apply" do
    o=OpenStruct.new :x=>15
    f=lambda {|m1,m2| "#{m1}-#{m2}-#{self.x}"}
    f.js_apply(o, ["a","b"]).should=="a-b-15"
  end
  
end