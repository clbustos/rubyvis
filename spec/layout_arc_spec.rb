require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Layout::Arc do
  it "should have correct properties" do
    props=[:antialias, :bottom, :canvas, :cursor, :data, :directed, :events, :fill_style, :height, :id, :left, :line_width, :links, :nodes, :orient, :overflow, :reverse, :right, :stroke_style, :title, :top, :transform, :visible, :width].inject({}) {|ac, v| ac[v]=true; ac}
    Rubyvis::Layout::Arc.properties.should==props 
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
      
      
      w = 300
      h = 100
      
      color=Rubyvis::Colors.category19
      
      @vis = Rubyvis::Panel.new()
      .width(w)
      .height(h)
      .bottom(50)
      .left(0)
      
      mat=@vis.add(Rubyvis::Layout::Arc)
      .nodes(nodes).links(links)
      .sort(lambda {|a,b| a.group<=>b.group})
      
      mat.link.add(Rubyvis::Line).
      antialias(false).
      line_width(1)
      
      mat.node.add(Rubyvis::Dot).
      shape_size(10).
      fill_style(lambda {|l| color[l.group]})
      
      mat.node_label.add(Rubyvis::Label).
      text_style(lambda {|l| color[l.group]})
      
      @vis.render

      html_out=<<EOF
<svg font-size="10px" font-family="sans-serif" fill="none" stroke="none" stroke-width="1.5" width="300" height="150"><g><g><g><path shape-rendering="crispEdges" d="M25,100A25,25 0 0,1 75,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M75,100A25,25 0 0,1 125,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M125,100A25,25 0 0,1 175,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M175,100A25,25 0 0,1 225,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M225,100A25,25 0 0,1 275,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M25,100A25,25 0 0,1 75,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M75,100A25,25 0 0,1 125,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M125,100A25,25 0 0,1 175,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M175,100A25,25 0 0,1 225,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g><g><path shape-rendering="crispEdges" d="M225,100A25,25 0 0,1 275,100" stroke="rgb(0,0,0)" stroke-opacity="0.2" stroke-width="1"/></g></g><g><circle fill="rgb(156,158,222)" stroke="rgb(31,119,180)" cx="25" cy="100" r="3.1622776601683795"/><circle fill="rgb(156,158,222)" stroke="rgb(31,119,180)" cx="75" cy="100" r="3.1622776601683795"/><circle fill="rgb(115,117,181)" stroke="rgb(31,119,180)" cx="125" cy="100" r="3.1622776601683795"/><circle fill="rgb(115,117,181)" stroke="rgb(31,119,180)" cx="175" cy="100" r="3.1622776601683795"/><circle fill="rgb(74,85,132)" stroke="rgb(31,119,180)" cx="225" cy="100" r="3.1622776601683795"/><circle fill="rgb(74,85,132)" stroke="rgb(31,119,180)" cx="275" cy="100" r="3.1622776601683795"/></g><g><text pointer-events="none" x="-7" dy="0.35em" transform="translate(25, 100) rotate(270)" fill="rgb(156,158,222)" text-anchor="end">A</text><text pointer-events="none" x="-7" dy="0.35em" transform="translate(75, 100) rotate(270)" fill="rgb(156,158,222)" text-anchor="end">B</text><text pointer-events="none" x="-7" dy="0.35em" transform="translate(125, 100) rotate(270)" fill="rgb(115,117,181)" text-anchor="end">C</text><text pointer-events="none" x="-7" dy="0.35em" transform="translate(175, 100) rotate(270)" fill="rgb(115,117,181)" text-anchor="end">D</text><text pointer-events="none" x="-7" dy="0.35em" transform="translate(225, 100) rotate(270)" fill="rgb(74,85,132)" text-anchor="end">E</text><text pointer-events="none" x="-7" dy="0.35em" transform="translate(275, 100) rotate(270)" fill="rgb(74,85,132)" text-anchor="end">F</text></g></g></svg>
EOF
      @rv_svg=Nokogiri::XML(@vis.to_svg)
      @pv_svg=Nokogiri::XML(html_out)
    end
    
    it "should render correct number of clipaths" do
      
      @rv_svg.xpath("//xmlns:path").size.should eq @pv_svg.xpath("//path").size
    end
    it "should render equal paths (links)" do
      pv_paths=@pv_svg.xpath("//path")
      @rv_svg.xpath("//xmlns:path").each_with_index {|rv_path,i|
        rv_path.should have_path_data_close_to pv_paths[i]['d']
      }
    end
    it "should render equal dots (nodes)" do
      pv_circles=@pv_svg.xpath("//circle")
      @rv_svg.xpath("//xmlns:circle").each_with_index {|rv_circle,i|
        rv_circle.should have_same_position pv_circles[i]
      }
      
    end
  end
end
