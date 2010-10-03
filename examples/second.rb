$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'

vis = pv.Panel.new().width(150).height(150);

#vis.add(pv.Rule).data(pv.range(0, 2, 0.5)).bottom(lambda {|d| d * 80 + 0.5}).add(pv.Label).left(0)


vis.add(pv.Bar).data([1,2]).width(20).height(lambda {|d|  d * 80}).bottom(0).left(lambda { self.index * 25 + 25}).anchor('bottom').add(pv.Label)

#puts vis.children_inspect
#exit

vis.render();
puts vis.to_svg

# <svg height="150" width="150" stroke-width="1.5" stroke="none" fill="none" font-family="sans-serif" font-size="10px"><g><line stroke-width="1" stroke="rgb(0,0,0)" y2="149.5" x2="150" y1="149.5" x1="0" shape-rendering="crispEdges"></line><line stroke-width="1" stroke="rgb(0,0,0)" y2="109.5" x2="150" y1="109.5" x1="0" shape-rendering="crispEdges"></line><line stroke-width="1" stroke="rgb(0,0,0)" y2="69.5" x2="150" y1="69.5" x1="0" shape-rendering="crispEdges"></line><line stroke-width="1" stroke="rgb(0,0,0)" y2="29.5" x2="150" y1="29.5" x1="0" shape-rendering="crispEdges"></line></g><g><text fill="rgb(0,0,0)" transform="translate(75, 149.5)" y="-3" x="3" pointer-events="none">0</text><text fill="rgb(0,0,0)" transform="translate(75, 109.5)" y="-3" x="3" pointer-events="none">0.5</text><text fill="rgb(0,0,0)" transform="translate(75, 69.5)" y="-3" x="3" pointer-events="none">1</text><text fill="rgb(0,0,0)" transform="translate(75, 29.5)" y="-3" x="3" pointer-events="none">1.5</text></g><g><rect fill="rgb(31,119,180)" height="80" width="20" y="70" x="25"></rect><rect fill="rgb(31,119,180)" height="96" width="20" y="54" x="50"></rect><rect fill="rgb(31,119,180)" height="136" width="20" y="14" x="75"></rect><rect fill="rgb(31,119,180)" height="120" width="20" y="30" x="100"></rect><rect fill="rgb(31,119,180)" height="56" width="20" y="94" x="125"></rect></g><g><text text-anchor="middle" fill="rgb(0,0,0)" transform="translate(35, 150)" y="-3" pointer-events="none">1</text><text text-anchor="middle" fill="rgb(0,0,0)" transform="translate(60, 150)" y="-3" pointer-events="none">1.2</text><text text-anchor="middle" fill="rgb(0,0,0)" transform="translate(85, 150)" y="-3" pointer-events="none">1.7</text><text text-anchor="middle" fill="rgb(0,0,0)" transform="translate(110, 150)" y="-3" pointer-events="none">1.5</text><text text-anchor="middle" fill="rgb(0,0,0)" transform="translate(135, 150)" y="-3" pointer-events="none">0.7</text></g></svg>
