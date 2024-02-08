require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe "Issue #22 github: Pie chart" do
  skip "should use bold font" do
    
    width=600
    height=600
    percentages=[10,20,70]
    radius=10
    angle=20
    colours="red"
    labels=%w{a1 a2 a3}
    vis = Rubyvis::Panel.new.width(width).height(height)
    vis.add(pv.Wedge)
       .data(percentages)
       .bottom(radius)
       .left(radius)
       .outer_radius(radius)
       .angle(angle)
       .fill_style(colours)
       .anchor('center').add(pv.Label)
       .font("bold")
       .text_style('#000000')
       .text(labels)
       .text_angle(0)
    vis.render()
    puts vis.to_svg
  end
end
