$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rubyvis'


w = 600
h = 600
cs=pv.Colors.category20()
    
    
vis = pv.Panel.new()
    .width(w)
    .height(h);
    
p1=vis.add(pv.Panel).data(['a','b','c','d']).
  top(lambda {self.index*(h/4.0);}).
height(h/4.0)
p2=p1.add(pv.Panel).data(['a','b','c','d']).
width(w/4.0).
left(lambda {return self.index*(w/4);})
p2.anchor("center").add(pv.Label).text(lambda {|d,a,b| puts "#{d},#{a},#{b}"; return "#{b}-#{a}"})
p2.add(pv.Bar).data([1,2,3,4,5,6,7,8,9]).
width(-3+w/12.0).
height(-3+h/12.0).
fillStyle(lambda {|d| (d!=5) ? cs.scale(d):"transparent"}).
top(lambda {return (self.index / 3.0).floor*(h/12.0)}).
left(lambda {return (self.index % 3)*(w/12.0)}).anchor('center').add(pv.Label).
text(lambda {|a,b,c,x| (a!=5) ? "#{c}-#{b}-#{a}-#{x}":""})

vis.render();

puts vis.to_svg;
