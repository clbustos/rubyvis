require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Scale do
  it "should return a correct numeric interpolator" do
    i=Rubyvis::Scale.interpolator(0,20)
    i[10].should==200
    i[20].should==400
  end
end