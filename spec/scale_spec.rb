require File.dirname(__FILE__)+"/spec_helper.rb"
describe Protoruby::Scale do
  it "should return a correct numeric interpolator" do
    i=Protoruby::Scale.interpolator(0,20)
    i[10].should==200
    i[20].should==400
  end
end