require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Histogram do
  describe "bins" do
    before do 
      data = Rubyvis.range(0, 10, 0.1).map {|x| 
        Math.sin(x)
      }
      @hist=Rubyvis::Histogram.new(data)
      @bins=@hist.bins
    end
    it "size should be correct" do
      @bins.size.should eq 8
    end
    it "bin.x should be correct" do
      @bins.map {|b| b.x}.should eq [-0.8, -0.6, -0.4, -0.2, 0, 0.2,0.4, 0.6]
    end
    it "bin.dx should be correct" do
      @bins.map {|b| b.dx}.should eq [0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2]
    end
    it "bin.y should be correct" do
      @bins.map {|b| b.y}.should eq [19,5,6,7,8,8,11,36]
    end
    it "bin.y should be correct using frequency=false" do
      @hist.frequency=false
      @hist.bins.map {|b| b.y}.should eq [0.19,0.05,0.06,0.07,0.08,0.08,0.11,0.36]
    end
  end
end