require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Scale do
  it "should return a correct numeric interpolator" do
    i=Rubyvis::Scale.interpolator(0,20)
    expect(i[10]).to eq(200)
    expect(i[20]).to eq(400)
  end
end