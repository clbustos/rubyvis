require File.dirname(__FILE__)+"/spec_helper.rb"
describe Rubyvis::Area do
  it "should have correct properties" do
    props=[:antialias, :bottom, :cursor, :data, :events, :fill_style, :height, :id, :interpolate, :left, :line_width, :reverse, :right, :segmented, :stroke_style, :tension, :title, :top, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Area.properties.should==props
  end
  context "rendered" do
    before do
      @h=200
      @w=200
      @vis = Rubyvis.Panel.new.width(@w).height(@h)
      @area=@vis.add(pv.Area).
        data([1,2,1,4,1,5]).
        height(lambda {|d| d*20}).
        left(lambda {index*20}).
        bottom(0)
    end
    it "should return correct default (linear) path" do
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to  "M0 180L20 160L40 180L60 120L80 180L100 100L100 200L80 200L60 200L40 200L20 200L0 200Z"
    end
    it "should return correct path for interpolate=step-before" do
      @area.interpolate('step-before')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0 180V160L20 160V180L40 180V120L60 120V180L80 180V100L100 100L100 200H80L80 200H60L60 200H40L40 200H20L20 200H0L0 200Z"
    end
    it "should return correct path for interpolate=step-after" do
      @area.interpolate('step-after')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0 180H20L20 160H40L40 180H60L60 120H80L80 180H100L100 100L100 200V200L80 200V200L60 200V200L40 200V200L20 200V200L0 200Z"
    end
    it "should return correct path for interpolate=basis" do
      @area.interpolate('basis')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0 180C0 180 0 180 3.333333333333333 176.66666666666666C6.666666666666666 173.33333333333331 13.333333333333332 166.66666666666666 20 166.66666666666666C26.666666666666664 166.66666666666666 33.33333333333333 173.33333333333331 40 166.66666666666666C46.666666666666664 160 53.33333333333333 140 60 140C66.66666666666666 140 73.33333333333333 160 80 156.66666666666666C86.66666666666666 153.33333333333331 93.33333333333331 126.66666666666666 96.66666666666666 113.33333333333331C99.99999999999999 99.99999999999999 99.99999999999999 99.99999999999999 99.99999999999997 99.99999999999997L100 200C99.99999999999999 199.99999999999997 99.99999999999999 199.99999999999997 96.66666666666664 199.99999999999994C93.33333333333331 199.99999999999997 86.66666666666666 199.99999999999997 80 199.99999999999994C73.33333333333333 199.99999999999997 66.66666666666666 199.99999999999997 59.99999999999999 199.99999999999994C53.33333333333333 199.99999999999997 46.666666666666664 199.99999999999997 40 199.99999999999994C33.33333333333333 199.99999999999997 26.666666666666664 199.99999999999997 20 199.99999999999994C13.333333333333332 199.99999999999997 6.666666666666666 199.99999999999997 3.333333333333333 199.99999999999994C0 199.99999999999997 0 199.99999999999997 0 199.99999999999994Z"
    end   
    it "should return correct path for interpolate=cardinal" do
      pending()
      @area.interpolate('cardinal')
      @vis.render
      doc=Nokogiri::XML(@vis.to_svg)
      doc.at_xpath("//xmlns:path").should have_path_data_close_to "M0 180Q16 160 20 160C26 160 34 186 40 180S54 120 60 120S74 183 80 180Q84 178 100 100L100 200Q84 200 80 200C74 200 66 200 60 200S46 200 40 200S26 200 20 200Q16 200 0 200Z"
    end
  end
end