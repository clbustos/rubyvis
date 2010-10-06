$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

data = pv.range(0, 10, 1).map {|x| 
  OpenStruct.new({:x=> x, :y=> Math.sin(x) + 2})
}


w = 400
h = 200
x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, w)


y = pv.Scale.linear(0, 4).range(0, h);

#/* The root panel. */
vis = pv.Panel.new()
    .width(w)
    .height(h)
    .bottom(20)
    .left(20)
    .right(10)
    .top(5)

# Y-axis and ticks.
vis.add(pv.Rule)
    .data(y.ticks(5))
    .bottom(y)
    .stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"})
  .anchor("left").add(pv.Label)
  .text(y.tick_format)

# X-axis and ticks.
vis.add(pv.Rule)
    .data(x.ticks())
    .visible(lambda {|d| d!=0})
    .left(x)
    .bottom(-5)
    .height(5)
    .anchor("bottom").add(pv.Label)
  .text(x.tick_format)

#/* The area with top line. */
vis.add(pv.Area)
    .data(data)
    .bottom(1)
    .left(lambda {|d| x.scale(d.x)})
    .height(lambda {|d| y.scale(d.y)})
    .fill_style("rgb(121,173,210)")
  .anchor("top").add(pv.Line)
  .line_width(3)

vis.render();


puts vis.to_svg

=begin
<svg font-size="10px" font-family="sans-serif" fill="none" stroke="none" stroke-width="1.5" width="430" height="225">
<g transform="translate(20, 5)">
<line shape-rendering="crispEdges" x1="0" y1="200" x2="400" y2="200" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="0" y1="150" x2="400" y2="150" stroke="rgb(238,238,238)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="0" y1="100" x2="400" y2="100" stroke="rgb(238,238,238)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="0" y1="50" x2="400" y2="50" stroke="rgb(238,238,238)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="0" y1="0" x2="400" y2="0" stroke="rgb(238,238,238)" stroke-width="1"/>
</g>
<g transform="translate(20, 5)">
<text pointer-events="none" x="-3" dy="0.35em" transform="translate(0, 200)" fill="rgb(0,0,0)" text-anchor="end">0</text>
<text pointer-events="none" x="-3" dy="0.35em" transform="translate(0, 150)" fill="rgb(0,0,0)" text-anchor="end">1</text>
<text pointer-events="none" x="-3" dy="0.35em" transform="translate(0, 100)" fill="rgb(0,0,0)" text-anchor="end">2</text>
<text pointer-events="none" x="-3" dy="0.35em" transform="translate(0, 50)" fill="rgb(0,0,0)" text-anchor="end">3</text>
<text pointer-events="none" x="-3" dy="0.35em" fill="rgb(0,0,0)" text-anchor="end">4</text>
</g>
<g transform="translate(20, 5)">
<line shape-rendering="crispEdges" x1="44.44444444444444" y1="200" x2="44.44444444444444" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="88.88888888888889" y1="200" x2="88.88888888888889" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="133.33333333333331" y1="200" x2="133.33333333333331" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="177.77777777777777" y1="200" x2="177.77777777777777" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="222.22222222222223" y1="200" x2="222.22222222222223" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="266.66666666666663" y1="200" x2="266.66666666666663" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="311.11111111111114" y1="200" x2="311.11111111111114" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="355.55555555555554" y1="200" x2="355.55555555555554" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
<line shape-rendering="crispEdges" x1="400" y1="200" x2="400" y2="205" stroke="rgb(0,0,0)" stroke-width="1"/>
</g>
<g transform="translate(20, 5)">
<text pointer-events="none" y="3" dy="0.71em" transform="translate(44.4444, 205)" fill="rgb(0,0,0)" text-anchor="middle">1</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(88.8889, 205)" fill="rgb(0,0,0)" text-anchor="middle">2</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(133.333, 205)" fill="rgb(0,0,0)" text-anchor="middle">3</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(177.778, 205)" fill="rgb(0,0,0)" text-anchor="middle">4</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(222.222, 205)" fill="rgb(0,0,0)" text-anchor="middle">5</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(266.667, 205)" fill="rgb(0,0,0)" text-anchor="middle">6</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(311.111, 205)" fill="rgb(0,0,0)" text-anchor="middle">7</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(355.556, 205)" fill="rgb(0,0,0)" text-anchor="middle">8</text>
<text pointer-events="none" y="3" dy="0.71em" transform="translate(400, 205)" fill="rgb(0,0,0)" text-anchor="middle">9</text>
</g>
<g transform="translate(20, 5)">
<path d="M0,99L44.44444444444444,56.92645075960516L88.88888888888889,53.535128658715905L133.33333333333331,91.94399959700664L177.77777777777777,136.8401247653964L222.22222222222223,146.94621373315692L266.66666666666663,112.9707749099463L311.11111111111114,66.15067006406053L355.55555555555554,49.53208766883091L400,78.39407573791217L400,199L355.55555555555554,199L311.11111111111114,199L266.66666666666663,199L222.22222222222223,199L177.77777777777777,199L133.33333333333331,199L88.88888888888889,199L44.44444444444444,199L0,199Z" fill="rgb(121,173,210)"/>
</g>
<g transform="translate(20, 5)">
<path d="M0,99L44.44444444444444,56.92645075960516L88.88888888888889,53.535128658715905L133.33333333333331,91.94399959700664L177.77777777777777,136.8401247653964L222.22222222222223,146.94621373315692L266.66666666666663,112.9707749099463L311.11111111111114,66.15067006406053L355.55555555555554,49.53208766883091L400,78.39407573791217" stroke="rgb(31,119,180)" stroke-width="3"/>
</g>
</svg>
=end
