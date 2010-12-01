# encoding: UTF-8 
# = Censo Agropecuario 2007, Chile: Treemap
# This treemap represents farm explotations on Biobío province, Chile.
# Colors represent different 'comunas' and bar inside one color
# represent different types of explotation
$:.unshift(File.dirname(__FILE__)+"/../../../lib")
require 'rubyvis'
load(File.dirname(__FILE__)+"/censo_agropecuario_chile_data.rb")

w = 500
h = 500
max_s=30

c_p_c={}

te = {
 1=>"Explotación agropecuaria con actividad",
 2=>"Explotación forestal", 
 3=>"Explotación agropecuaria sin tierra", 
 4=>"Explotación agropecuaria temporalmente sin actividad", 
 5=>"Parques nacionales y reservas forestales"}

number=Rubyvis::Format.number
color=Rubyvis::Colors.category20

$censo.each_with_index do |c,i|
  c_p_c[c[:glosa]]||=Hash.new
  c_p_c[c[:glosa]][c[:te]]=OpenStruct.new(c)
end



nodes = pv.dom(c_p_c).root("censo").nodes

# The root panel.
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(30)
    .right(10)
    .top(5);

treemap = vis.add(Rubyvis::Layout::Treemap).
  nodes(nodes).mode("squarify").round(true).
  size(lambda {|d| d.node_value.superficie})

treemap.leaf.add(Rubyvis::Panel).
  fill_style(lambda{|d| 
  color.scale(d.node_value.glosa)}).
  stroke_style("#fff").
  line_width(1).
  antialias(false).
  title(lambda {|d| d.parent_node ? d.node_value.glosa+"-#{te[d.node_value.te]}" : ""})

treemap.node_label.add(Rubyvis::Label).
  text_style(lambda {|d| pv.rgb(0, 0, 0, 1)}).
  visible(lambda {|d| d.node_value and d.node_value.superficie>200}).
  text(lambda {|d| number.format(d.node_value.superficie.to_i)})
    

vis.render()
puts vis.to_svg
