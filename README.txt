= protoruby

* http://rubyvis.rubyforge.org/

== DESCRIPTION:

Ruby port of Protovis, a great visualization toolkit

== FEATURES/PROBLEMS:

Implemented: All marks, except transient, image and transition. 
Basic protovis examples works exactly like ruby ones with minor sintactic modifications. 
Complex examples requires some careful update.

I try to maintain, when posible, complete compatibility with Javascript API. Johnson [http://github.com/jbarnette/johnson] - the lovely Javascript wrapper inside Ruby embrace - is our friend. 

Until version 0.1.0, lambdas should always should created explicitly for method you may be temted to call it with a block.
On a second stage, traditional block calling could be using maintaining backwards compatibily with Javascript API,
User could use +pv+ freely, cause is defined as a global method which call Rubyvis.

+self.parent.index+ doesn't work always as expected. +self.index+ works ok.

== CURRENT PROGRESS

* pv.js
* pv-internals.js
* color/Color.js (incomplete)
* color/Colors.js
* data/Arrays.js
* data/Numbers.js
* data/Scale.js
* data/LinearScale.js
* data/QuantitativeScale.js
* data/OrdinalScale.js (not tested)
* mark/Mark.js
* mark/Bar.js 
* mark/Panel.js
* mark/Label.js
* mark/Line.js
* mark/Rule.js
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
    

== REQUIREMENTS:

Ruby 1.8.7 or 1.9.1

== INSTALL:

$ sudo gem install rubyvis

== LICENSE:

GPL-2
