require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Matrix do
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :directed, :events, :fill_style, :height, :id, :left, :line_width, :links, :nodes, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Matrix.properties.should==props 
  end
  describe "rendered" do
    before do
            
nodes=[
OpenStruct.new({:node_value=>'A', :group=>1}),
OpenStruct.new({:node_value=>'B', :group=>1}),
OpenStruct.new({:node_value=>'C', :group=>2}),
OpenStruct.new({:node_value=>'D',:group=>2}),
OpenStruct.new({:node_value=>'E',:group=>3}),
OpenStruct.new({:node_value=>'F',:group=>3})

]
links=[
OpenStruct.new({:source=>0,:target=>1, :value=>1}),
OpenStruct.new({:source=>1,:target=>2, :value=>1}),
OpenStruct.new({:source=>2,:target=>3, :value=>1}),
OpenStruct.new({:source=>3,:target=>4, :value=>1}),
OpenStruct.new({:source=>4,:target=>5, :value=>1}),
OpenStruct.new({:source=>1,:target=>0, :value=>1}),
OpenStruct.new({:source=>2,:target=>1, :value=>1}),
OpenStruct.new({:source=>3,:target=>2, :value=>1}),
OpenStruct.new({:source=>4,:target=>3, :value=>1}),
OpenStruct.new({:source=>5,:target=>4, :value=>1}),
]
    

w = 700
h = 700

color=Rubyvis::Colors.category19()
@vis = Rubyvis::Panel.new()
  .width(w)
  .height(h)
  .top(50)
  .left(50)

mat=@vis.add(Rubyvis::Layout.Matrix)
.directed(true)
.nodes(nodes).links(links)
.sort(lambda {|a,b| a.group<=>b.group})

mat.link.add(pv.Bar).
fill_style(lambda {|l| l.link_value!=0 ? 
((l.target_node.group==l.source_node.group) ? color[l.sourceNode] : "#555") : "#eee"}).
antialias(false).
line_width(1)
mat.node_label.add(Rubyvis::Label).
text_style(color)


      
      @vis.render
      
      html_out=<<EOF
<svg font-size="10px" font-family="sans-serif" fill="none" stroke="none" stroke-width="1.5" width="750" height="750"><g transform="translate(50, 50)"><g><rect shape-rendering="crispEdges" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(156,158,222)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" y="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(156,158,222)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="116.66666666666667" y="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="233.33333333333334" y="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(85,85,85)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="350" y="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="466.6666666666667" y="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="583.3333333333334" y="116.66666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" y="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="116.66666666666667" y="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(85,85,85)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="233.33333333333334" y="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="350" y="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(156,158,222)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="466.6666666666667" y="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="583.3333333333334" y="233.33333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" y="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="116.66666666666667" y="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="233.33333333333334" y="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(156,158,222)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="350" y="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="466.6666666666667" y="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(85,85,85)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="583.3333333333334" y="350" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" y="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="116.66666666666667" y="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="233.33333333333334" y="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="350" y="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(85,85,85)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="466.6666666666667" y="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="583.3333333333334" y="466.6666666666667" width="116.66666666666667" height="116.66666666666667" fill="rgb(156,158,222)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" y="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="116.66666666666667" y="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="233.33333333333334" y="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="350" y="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="466.6666666666667" y="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(156,158,222)" stroke="rgb(255,255,255)" stroke-width="1"/><rect shape-rendering="crispEdges" x="583.3333333333334" y="583.3333333333334" width="116.66666666666667" height="116.66666666666667" fill="rgb(238,238,238)" stroke="rgb(255,255,255)" stroke-width="1"/></g><g><text pointer-events="none" x="-4" dy="0.35em" transform="translate(0, 58.3333)" fill="rgb(156,158,222)" text-anchor="end">A</text><text pointer-events="none" x="4" dy="0.35em" transform="translate(58.3333) rotate(-90)" fill="rgb(156,158,222)">A</text><text pointer-events="none" x="-4" dy="0.35em" transform="translate(0, 175)" fill="rgb(156,158,222)" text-anchor="end">B</text><text pointer-events="none" x="4" dy="0.35em" transform="translate(175) rotate(-90)" fill="rgb(156,158,222)">B</text><text pointer-events="none" x="-4" dy="0.35em" transform="translate(0, 291.667)" fill="rgb(156,158,222)" text-anchor="end">C</text><text pointer-events="none" x="4" dy="0.35em" transform="translate(291.667) rotate(-90)" fill="rgb(156,158,222)">C</text><text pointer-events="none" x="-4" dy="0.35em" transform="translate(0, 408.333)" fill="rgb(156,158,222)" text-anchor="end">D</text><text pointer-events="none" x="4" dy="0.35em" transform="translate(408.333) rotate(-90)" fill="rgb(156,158,222)">D</text><text pointer-events="none" x="-4" dy="0.35em" transform="translate(0, 525)" fill="rgb(156,158,222)" text-anchor="end">E</text><text pointer-events="none" x="4" dy="0.35em" transform="translate(525) rotate(-90)" fill="rgb(156,158,222)">E</text><text pointer-events="none" x="-4" dy="0.35em" transform="translate(0, 641.667)" fill="rgb(156,158,222)" text-anchor="end">F</text><text pointer-events="none" x="4" dy="0.35em" transform="translate(641.667) rotate(-90)" fill="rgb(156,158,222)">F</text></g></g></svg>
EOF
      @rv_svg=Nokogiri::XML(@vis.to_svg)
      @pv_svg=Nokogiri::XML(html_out)
    end
    
    it "should render correct number of rects" do
      @rv_svg.xpath("//xmlns:rect").size.should eq @pv_svg.xpath("//rect").size
    end
  end
end
