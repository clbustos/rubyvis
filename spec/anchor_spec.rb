require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Anchor do
  include Rubyvis::GeneralSpec
  
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :id,  :left, :name, :reverse, :right,  :title, :top, :visible].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Anchor.properties.should==props
  end
  it "should be initialized with an object which respond to parent" do
    my_mock=mock('mark')
    my_mock.should_receive(:parent).with(no_args())
    Rubyvis.Anchor(my_mock)
    
  end
  describe "inner anchor data should work fine" do
    before  do
      w=200
      h=200
      data_p1=[]
      data_p2=[]
      data_l=[]
      @expected_l=[]
      @expected_p2=[]  
      vis = pv.Panel.new().width(w).height(h)      
      cell=vis.add(pv.Panel).
        data([1,2]).top(lambda {|*args| data_p1.push(args); 100}).
        add(pv.Panel). data(['a','b']).top(lambda {|*args| data_p2.push(args); 100;})
      
      cell.anchor('center').add(pv.Bar).top(lambda {|*args| data_l.push args; 1})

      [1,2].each {|a| %w{a b}.each {|b| 
        @expected_l.push([b,b,a,nil])
        @expected_p2.push([b,a,nil])
      }}
      @expected_p1=[[1,nil],[2,nil]]
      @data_p1=data_p1
      @data_p2=data_p2
      @data_l=data_l
      vis.render
      
    end
    if(true)
    it "first loop correct" do
      @data_p1.should==@expected_p1
    end
    it "second loop correct" do
      @data_p2.should==@expected_p2
    end
    end
    
    it "label loop correct" do
      @data_l.should==@expected_l
    end
  end
  
  it "antibiotics example should render correct data" do

    a1=['a','b','c']
    a2=[1,2,3]
    antibiotics=["penicillin", "streptomycin", "neomycin"]
    adatas=[]
    s = 180
    _p = 20
    vis = pv.Panel.new().
      height(s * antibiotics.size + _p * (antibiotics.size - 1)).
      width(s * antibiotics.size + _p * (antibiotics.size - 1)).
      top(14.5).
      left(14.5).
      bottom(44).
      right(14)

    cell = vis.add(pv.Panel).
      data(a1).
      width(s).
      left(lambda {(s + _p) * index}).
    add(pv.Panel).
      data(a2).
      height(s).
      top(lambda {(s + _p) * self.index});

    
    cell.anchor("center").add(pv.Label).text(lambda {|*args| adatas.push args})
    
    expected=[]
    a1.each {|a| a2.each {|b| expected.push([b,b,a,nil])}}
    vis.render
    adatas.should==expected
    
  end
  
  context "Panel-Panel-label assigment" do
    before do
      @h=200
      @w=200
      @values=["a","b","c"]
      @vis = Rubyvis.Panel.new.width(@w).height(@h). add(pv.Panel).data(@values). add(pv.Panel).data(@values)
      @anchor=@vis.anchor('center')
      @label=@vis.add(pv.Label)
    end
    it "should have correct data" do
      datas=[]
      @label.text(lambda {|*args| datas.push args})
      @vis.render
      expected=[]
      @values.each {|a| @values.each {|b| expected.push([b,b,a,nil])}}
      datas.should==expected
    end
  end
  it "should render equal to protovis 'anchor.html' example" do
      @vis = Rubyvis::Panel.new().
        width(200).
        height(200)
      
      @vis.add(Rubyvis::Bar).
        fill_style("#ccc").
        anchor("top").add(Rubyvis::Label).
        text("top").
        target.
        anchor("bottom").
        add(pv.Label).
        text("bottom")
      @vis.render
      @pv_out=fixture_svg_read("anchor.svg")
      @vis.to_svg.should have_same_svg_elements(@pv_out)
  end
  context "Panel-bar assigment" do 
    before do
      @h=200
      @w=200
      @vis = Rubyvis.Panel.new.width(@w).height(@h)
      @bar = @vis.add(Rubyvis::Bar).data([1,2,3])
      @anchor=@bar.anchor('center')
      @label=@anchor.add(Rubyvis::Label)
      
    end
    
    it "should have correct data for direct asigment" do
      datas=[]
      expected=[[1,nil],[2,nil],[3,nil]]
      @label.text(lambda {|*args| datas.push args})
      @vis.render
      datas.should==expected
    end
    
    it "should have correct data for two levels of data" do
      datas=[]
      @vis.data(%w{a b c})
      expected=[]
      %w{a b c}.each {|a| [1,2,3].each {|b| expected.push([b,a])}}
      @label.text(lambda {|*args| datas.push args})
      @vis.render
      datas.should==expected
    end
  end  
end
