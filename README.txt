= protoruby

* http://rubyvis.rubyforge.org/

== DESCRIPTION:

Ruby port of Protovis[http://vis.stanford.edu/protovis/], a great visualization toolkit

== FEATURES/PROBLEMS:

Implemented: All marks, except transient and transitions. 

Basic protovis examples[http://vis.stanford.edu/protovis/ex/] works exactly like ruby ones with minor sintactic modifications:
* Area Charts: Ok
* Bar & Column Charts: Ok
* Scatterplots: Ok
* Pie & Donut: Interaction with mouse not implemented
* Line & Step Charts: Ok
* Stacked Charts: Ok
* Grouped Charts: Ok.

Complex examples requires more works:

* antibiotics: Ok
* barley: Ok
* crimea: line and grouped line ok.


I try to maintain, when posible, complete compatibility with Javascript API, including camel case naming of functions. Johnson [http://github.com/jbarnette/johnson] - the lovely Javascript wrapper inside Ruby embrace - is our friend to test implementation of basic object. 

Until version 0.1.0, lambdas should always should created explicitly for method you may be temted to call it with a block.

On a second stage, traditional block calling could be using maintaining backwards compatibily with Javascript API. See TODO section for proposal of new API.

User could use +pv+ freely, cause is defined as a global method which call Rubyvis.

== CURRENT PROGRESS

* pv.js
* pv-internals.js
* color/Color.js (incomplete)
* color/Colors.js
* data/Arrays.js
* data/Numbers.js
* data/Scale.js
* data/LinearScale.js
* data/LogScale.js (incomplete)
* data/Nest.js
* data/QuantitativeScale.js
* data/OrdinalScale.js
* mark/Anchor.js
* mark/Area.js
* mark/Bar.js 
* mark/Dot.js 
* mark/Label.js
* mark/Line.js
* mark/Mark.js
* mark/Panel.js
* mark/Rule.js
* mark/Wedge.js
* scene/SvgBar.js
* scene/SvgLabel.js
* scene/SvgLine.js
* scene/SvgPanel.js
* scene/SvgRule.js
* scene/SvgScene.js
* text/Format.js (incomplete)
* text/NumberFormat.js (incomplete)

== SYNOPSIS:

    require 'rubyvis'
    
    vis = Rubyvis::Panel.new.width(150).height(150);
    vis.add(pv.Bar).data([1, 1.2, 1.7, 1.5, 0.7, 0.3]).
    width(20).
    height(lambda {|d| d * 80}).
    bottom(0).
    left(lambda {self.index * 25});
    vis.render
    puts vis.to_svg
    
See examples directory for original protovis examples adaptations.

== TODO

Implement a ruby-like API, like ReportBuilder[http://ruby-statsample.rubyforge.org/reportbuilder/] or Prawn [http://prawn.majesticseacreature.com/docs/] 

The examples/area.rb script should like somethink like that

    require 'rubyvis'
    vis = Rubyvis::Panel.new {
      width w 
      height h 
      bottom 20 
      left 20 
      right 10
      top 5
      # Y-axis
      rule {
        data y.ticks(5)
        bottom y
        stroke_style {|d| d!=0 ? "#eee" : "#000"}
        anchor("left") {  
          label {
            text y.tick_format
          }
        }
      }
      # X-axis
      rule {
        data x.ticks
        visible {|d| d!=0}
        left x
        bottom -5
        height -5
        label(:anchor=>'bottom') { # shortcut to create a mark inside an anchor
          text x.tick_format
        }
      }
      
      # The area with top line.
      area {
        data(data)
        bottom 1
        left {|d| x.scale(d.x)}
        height {|d| y.scale(d.y)}
        fill_style "rgb(121,173,210)"
        line(:anchor=>"top") {
          line_width 3
        }
      }
    }
    
    puts vis.to_svg


== REQUIREMENTS:

Ruby 1.8.7 or 1.9.1

== INSTALL:

$ sudo gem install rubyvis

== LICENSE:

GPL-2
