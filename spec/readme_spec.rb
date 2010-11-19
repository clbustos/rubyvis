require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Rubyvis Readme" do
  it "should work with RBP API" do
    vis=nil
    lambda {
    vis = Rubyvis::Panel.new do 
      width 150
      height 150
      bar do
        data [1, 1.2, 1.7, 1.5, 0.7, 0.3]
        width 20
        height {|d| d * 80}
        bottom(0)
        left {index * 25}
      end
    end
    
    vis.render}.should_not raise_exception
    vis.to_svg.size.should>0
  end
  it "should work with Protovis API" do
    vis=nil
    lambda {
    vis = Rubyvis::Panel.new.width(150).height(150);
    
    vis.add(pv.Bar).
      data([1, 1.2, 1.7, 1.5, 0.7, 0.3]).
      width(20).
      height(lambda {|d| d * 80}).
      bottom(0).
      left(lambda {self.index * 25});
    
    vis.render
    }.should_not raise_exception
    vis.to_svg.size.should>0
  end
  
end
