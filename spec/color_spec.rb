require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Rubyvis color methods" do
  it "should return correct Rubyvis.ramp" do
    a=Rubyvis.ramp("white","red")
    a[0].should eq Rubyvis.color("rgb(255,255,255)")
    a[0.5].should eq Rubyvis.color("rgb(255,128,128)")
    a[1].should eq Rubyvis.color("rgb(255,0,0)")
  end
  
  # <li>#f00 // #rgb
  # <li>#ff0000 // #rrggbb
  # <li>rgb(255, 0, 0)
  # <li>rgb(100%, 0%, 0%)
  # <li>hsl(0, 100%, 50%)
  # <li>rgba(0, 0, 255, 0.5)
  # <li>hsla(120, 100%, 50%, 1)
  describe "Rubyvis.color" do 
    
    it "should return correct Rubyvis.color with three hex" do
      Rubyvis.color("#f97").should eq Rubyvis::Color::Rgb.new("ff".to_i(16), "99".to_i(16),"77".to_i(16),1 )
    end
    it "should return correct Rubyvis.color with 6 hex" do
      Rubyvis.color("#f19171").should eq Rubyvis::Color::Rgb.new("f1".to_i(16), "91".to_i(16),"71".to_i(16),1 )
    end
    it "should return correct Rubyvis.color rbg() with integers" do
      r,g,b=rand(255),rand(255),rand(255)
      Rubyvis.color("rgb(#{r},#{g},#{b})").should eq Rubyvis::Color::Rgb.new(r, g, b,1 )
    end
    it "should return correct Rubyvis.color rbga() with integers" do
      r,g,b,a=rand(255),rand(255),rand(255), rand()
      Rubyvis.color("rgba(#{r},#{g},#{b},#{a})").should eq Rubyvis::Color::Rgb.new(r, g, b,"#{a}".to_f )
    end
    it "should return correct Rubyvis.color rbg() with percents" do
      r,g,b=rand(100),rand(100),rand(100)
      Rubyvis.color("rgb(#{r}%,#{g}%,#{b}%)").should eq Rubyvis::Color::Rgb.new((r*2.55).round, (g*2.55).round, (b*2.55).round,1 )
    end
    it "should return correct Rubyvis.color hsl" do
      Rubyvis.color("hsl(100,50,50)").should eq Rubyvis::Color::Rgb.new(106,191,64,1)
      
      h,s,l=rand(360),rand(100),rand(100)
      
      Rubyvis.color("hsl(#{h},#{s},#{l})").should eq Rubyvis::Color::Hsl.new(h,s/100.0,l/100.0,1).rgb
    end
    it "should return correct Rubyvis.color hsla" do
      h,s,l,a=rand(360),rand(100),rand(100), rand()
      Rubyvis.color("hsla(#{h},#{s},#{l},#{a})").should eq Rubyvis::Color::Hsl.new(h,s/100.0,l/100.0, "#{a}".to_f).rgb
    end
  end
  describe Rubyvis::Color::Hsl do
    it "convert some extreme value" do
      Rubyvis.color("hsl(96,50,50)").should eq Rubyvis.color("rgb(115,191,64)")
      Rubyvis.color("hsl(112.5,50.0,50.0)").should eq Rubyvis.color("rgb(80,191,64)")

    end
  end
  describe Rubyvis::Color::Rgb do
    before do
      @r,@g,@b,@a=rand(255),rand(255),rand(255),rand()
      @rgb=Rubyvis::Color::Rgb.new(@r,@g,@b,@a)
    end
    it "return correct ==" do
      Rubyvis::Color::Rgb.new(0, 0,0,1 ).should eq Rubyvis::Color::Rgb.new(0, 0,0,1 )
      
      Rubyvis::Color::Rgb.new(10, 0,0,1 ).should_not eq Rubyvis::Color::Rgb.new(0, 0,0,1 )
      
      Rubyvis::Color::Rgb.new(0, 10,0,1 ).should_not eq Rubyvis::Color::Rgb.new(0, 0,0,1 )
      
      Rubyvis::Color::Rgb.new(0, 0,10,1 ).should_not eq Rubyvis::Color::Rgb.new(0, 0,0,1 )
      Rubyvis::Color::Rgb.new(0, 0,0,0 ).should_not eq Rubyvis::Color::Rgb.new(0, 0,0,1 )
    end
    it "return correct red()" do
      @rgb.red(255).should eq Rubyvis::Color::Rgb.new(255,@g,@b,@a)
    end
    it "return correct green()" do
      @rgb.green(255).should eq Rubyvis::Color::Rgb.new(@r,255,@b,@a)
    end
    it "return correct blue()" do
      @rgb.blue(255).should eq Rubyvis::Color::Rgb.new(@r,@g,255,@a)
    end
    it "return correct alpha()" do
      @rgb.alpha(0.5).should eq Rubyvis::Color::Rgb.new(@r,@g,@b,0.5)
    end
    it "return correct darker()" do
      Rubyvis.color("red").darker().should eq Rubyvis::Color::Rgb.new(178,0,0,1)
    end
    it "return correct brighter()" do
      Rubyvis.color("rgb(100,110,120)").brighter().should eq Rubyvis::Color::Rgb.new(142,157,171,1)
    end    
    
  end
end
