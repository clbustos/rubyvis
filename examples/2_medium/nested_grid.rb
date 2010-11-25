# = Nested grid
# Two level nested grid.  The first is created at random with n rows and m columns The second level is a 9x9 grid inside the cell of first level
# You can obtain the same result using a grid layout
$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'


w = 600
h = 600
cs=pv.Colors.category20()
rows=2.0+rand(3)
cols=2.0+rand(3)
row_h=h/rows
col_w=w/cols
cel_h=row_h/3.0
cel_w=col_w/3.0

letters=%w{a b c d e f g h i j k}

    
vis = pv.Panel.new()
    .width(w)
    .height(h);
    
p1=vis.add(pv.Panel).data(letters[0,rows]).
  top(lambda {index*(row_h)}).
  height(row_h)

p2=p1.add(pv.Panel).data(letters[0,cols]).
  width(col_w).
  left(lambda {index*(col_w)})

p2.anchor("center").add(pv.Label).
  text(lambda {|d,a,b| return "#{b}-#{a}"}).
  font("bold large Arial")


p2.add(pv.Bar).data([1,2,3,4,5,6,7,8,9]).
  width(-3+cel_w).
  height(-3+cel_h).
  visible(lambda {|d| d!=5}).
  fillStyle(lambda {|d| cs.scale(d)}).
  top(lambda { (index / 3.0).floor*cel_h}).
  left(lambda { (index % 3)*cel_w}).
  anchor('center').
    add(pv.Label).
      visible(lambda {|a,b,c| a!=5}).
      text(lambda {|a,b,c| "#{c}-#{b}-#{a}"})

vis.render();

puts vis.to_svg
