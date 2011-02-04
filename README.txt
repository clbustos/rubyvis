= Rubyvis

* http://rubyvis.rubyforge.org/

== DESCRIPTION:

Ruby port of Protovis[http://vis.stanford.edu/protovis/], a Javascript visualization toolkit.

== FEATURES/PROBLEMS:

This library implements almost completely core API of protovis, including all static marks, SVG builder class and data classes. Spec coverage is near 90%

Implemented: 

* Marks: All, except transient and transitions.
* Layout: Arc, Cluster, Grid, Horizon, Indent, Matrix, Pack, Partition, Stack, Tree and Treemap. To implement: Bullet, Force, and Rollup.

Using protovis examples[http://vis.stanford.edu/protovis/ex/] as reference

* Conventional: All working
* Custom: 
 * Backer's Barley
 * Burtin's Antibiotics: Scatterplot matrix
 * Cars: Parallel Coordinates
 * Crimea war: Grouped bar chart and line chart
* Hierarchies:
 * Treemap
 * Bubble Charts
 * Circle Packing
 * Dendogram
 * Icicle
 * Indent
 * Node-Link Tree
 * Sunburst
 * Treemap
* Networks:
 * Arc
 * Matrix
 
I try to maintain, when posible, complete compatibility with Javascript API, including camel case naming of functions. Johnson [http://github.com/jbarnette/johnson] - the lovely Javascript wrapper inside Ruby embrace - is our friend to test implementation of basic object. 

User could use +pv+ freely, cause is defined as a global method which call Rubyvis.

Nokogiri is used as XML library. If not available, or $rubyvis_no_nokogiri is set to true, REXML is used. Nokogiri is 30%-35% faster that REXML on our test.

== CURRENT PROGRESS

* pv.js
* pv-internals.js
* color/Color.js
* color/Colors.js
* data/Arrays.js
* data/Flatten.js
* data/Histogram.js
* data/Numbers.js
* data/LinearScale.js
* data/LogScale.js (incomplete)
* data/Nest.js
* data/QuantitativeScale.js
* data/OrdinalScale.js
* data/Scale.js
* layout/Arc.js
* layout/Cluster.js
* layout/Grid.js
* layout/Hierarchy.js
* layout/Horizon.js
* layout/Indent.js
* layout/Layout.js
* layout/Matrix.js
* layout/Network.js
* layout/Pack.js
* layout/Partition.js
* layout/Stack.js
* layout/Tree.js
* layout/Treemap.js
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
* scene/SvgWedge.js
* text/Format.js (incomplete)
* text/NumberFormat.js (incomplete)

== SYNOPSIS:

The primary API, based on Gregory Brown's Ruby Best Practices, uses blocks and name of marks as methods

    require 'rubyvis'
    
    vis = Rubyvis::Panel.new do 
      width 150
      height 150
      bar do
        data [1, 1.2, 1.7, 1.5, 0.7, 0.3]
        width 20
        height {|d| d * 80}
        bottom(0)
        left {index * 25}
      end
    end
    
    vis.render
    puts vis.to_svg


The library allows you to use chain methods API, like original protovis

    require 'rubyvis'
    
    vis = Rubyvis::Panel.new.width(150).height(150);
    
    vis.add(pv.Bar).
      data([1, 1.2, 1.7, 1.5, 0.7, 0.3]).
      width(20).
      height(lambda {|d| d * 80}).
      bottom(0).
      left(lambda {self.index * 25});
    
    vis.render
    puts vis.to_svg
    

See examples directory for original protovis examples adaptations and others graphics

== THE MOST FREQUENT QUESTION (MFQ)

¿Why use a server-side technology if I can use a client-side, which is faster and more economic for developer?

If you want to present graphs: (a) complex and/or dynamically generated, (b) only on the web and (c) on modern browsers, Protovis[http://vis.stanford.edu/protovis/] is an excellent option. For simpler charts, Protovis is overkill. I recomend jqPlot[http://www.jqplot.com/]

Rubyvis is designed mainly for off-line operation, like batch creation of graphs for use on printed documents (rtf-pdf), with possibility of use easily the script for on-line use.

== REQUIREMENTS:

Tested on Ruby 1.8.7, 1.9.1, 1.9.2-p0 and ruby-head (future 1.9.3)

== INSTALL:

$ gem install rubyvis

== LICENSE:

GPL-2
