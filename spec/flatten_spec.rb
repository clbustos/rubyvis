require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Flatten do
  before do
    @data={
      "Genesis"=>{
        "Live"=>{
          "Genesis Live"=>1973,
          "Seconds Out"=>1977
        },
        "Studio"=>{
          "Nursery Cryme"=>1971,
          "Foxtrot"=>1972
        }
      },
      "Rush"=>{
        "Studio"=>{
          "Permanent Waves"=>1980,
          "Moving Pictures"=>1981
        },
        "Live"=>{
          "Exit...Stage Left"=>1981,
          "A Show of Hands"=>1989
        }
      },
    }
    @flatten = Rubyvis.flatten(@data)
    @flatten.key("band").key("type").key("album").key("year")

  end
  it "should return correct array" do
    sorting=lambda {|a,b|
      f1=a["band"]<=>a["band"]
      f2=a["type"]<=>a["type"]
      f3=a["album"]<=>a["album"]
      f4=a["year"]<=>a["year"]
      f1!=0 ? f1 : (f2!=0 ? f2 :(f3!=0 ? f3 : (f4!=0 ? f4 : 0)))
    }
    expected=[{"band"=>"Genesis", "type"=>"Live", "album"=>"Genesis Live", "year"=>1973}, {"band"=>"Genesis", "type"=>"Live", "album"=>"Seconds Out", "year"=>1977}, {"band"=>"Genesis", "type"=>"Studio", "album"=>"Nursery Cryme", "year"=>1971}, {"band"=>"Genesis", "type"=>"Studio", "album"=>"Foxtrot", "year"=>1972}, {"band"=>"Rush", "type"=>"Studio", "album"=>"Permanent Waves", "year"=>1980}, {"band"=>"Rush", "type"=>"Studio", "album"=>"Moving Pictures", "year"=>1981}, {"band"=>"Rush", "type"=>"Live", "album"=>"Exit...Stage Left", "year"=>1981}, {"band"=>"Rush", "type"=>"Live", "album"=>"A Show of Hands", "year"=>1989}].sort(&sorting)
    
    @flatten.array.sort(&sorting).should eq expected
  end
  it "other example" do
    @flatten.leaf(lambda {|f| f.is_a? Numeric})
    expected=[{:keys=>["Genesis", "Live", "Genesis Live"], :value=>1973}, {:keys=>["Genesis", "Live", "Seconds Out"], :value=>1977}, {:keys=>["Genesis", "Studio", "Nursery Cryme"], :value=>1971}, {:keys=>["Genesis", "Studio", "Foxtrot"], :value=>1972}, {:keys=>["Rush", "Studio", "Permanent Waves"], :value=>1980}, {:keys=>["Rush", "Studio", "Moving Pictures"], :value=>1981}, {:keys=>["Rush", "Live", "Exit...Stage Left"], :value=>1981}, {:keys=>["Rush", "Live", "A Show of Hands"], :value=>1989}]
    @flatten.array.should eql expected
  end
end
