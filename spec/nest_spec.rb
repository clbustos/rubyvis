require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Nest do
  before do
    @data=[
    { :year=>2010, :city=>'London',:value=>1},
    { :year=>2010, :city=>'France',:value=>2},
    { :year=>2011, :city=>'London',:value=>5},
    { :year=>2011, :city=>'France',:value=>6},
  ]
  end
  it "should generate correct map" do
    nest = pv.nest(@data).key(lambda {|d| d[:year]}).key(lambda {|d|  d[:city]}).map()
    
    expected={2010=>{"London"=>[{:year=>2010, :city=>"London", :value=>1}], "France"=>[{:year=>2010, :city=>"France", :value=>2}]}, 2011=>{"London"=>[{:year=>2011, :city=>"London", :value=>5}], "France"=>[{:year=>2011, :city=>"France", :value=>6}]}}
    nest.should==expected

  end
  it "should generate correct rollup" do
    nest = pv.nest(@data).key(lambda {|d| d[:year]}).key(lambda {|d|  d[:city]}).rollup(lambda {|d| d.map{|dd| dd[:value]}})
    expected={2010=>{"London"=>[1], "France"=>[2]}, 2011=>{"London"=>[5], "France"=>[6]}}
    nest.should==expected
    
  end
  it "should generate correct entries" do
    nest = pv.nest(@data).key(lambda {|d| d[:year]}).key(lambda {|d|  d[:city]}).entries();
    expected=[
    Rubyvis::NestedArray.new(:key=>2010, :values=>
      [
        Rubyvis::NestedArray.new(:key=>'London', :values=>
          [{:year=>2010, :city=>'London',:value=>1}]),
        Rubyvis::NestedArray.new(:key=>'France', :values=>
          [{:year=>2010, :city=>'France',:value=>2}])
      ]),
    Rubyvis::NestedArray.new(:key=>2011, :values=>
      [
        Rubyvis::NestedArray.new(:key=>'London', :values=>
          [{:year=>2011, :city=>'London',:value=>5}]),
        Rubyvis::NestedArray.new(:key=>'France', :values=>
          [{:year=>2011, :city=>'France',:value=>6}])
      ])
    ]
    
    nest.should==expected
      
  end
  
end