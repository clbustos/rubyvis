= protoruby

* http://github.com/clbustos/rubyvis

== DESCRIPTION:

Ruby version of Protovis, a great visualization toolkit

== FEATURES/PROBLEMS:

NOTE: THIS LIBRARY IS NOT YET OPERATIONAL. WILL BE RELEASED AS A GEM WHEN CAN OUTPUT SOMETHING

I try to maintain, when posible, complete compatibility with Javascript API. Johnson [http://github.com/jbarnette/johnson] - the lovely Javascript wrapper inside Ruby embrace - is out friend. 
 
Until version 0.1.0, lambdas should always should created explicitly for method you may be temted to call it with a block.
On a second stage, traditional block calling could be using maintaining backwards compatibily with Javascript API,
User could use +pv+ freely, cause is defined as a global method which call Rubyvis.

== CURRENT PROGRESS

* pv.js
* pv-internals.js
* color/Color.js (incomplete)
* color/Colors.js (incomplete)
* data/Arrays.js
* data/Numbers.js
* data/Scale.js
* data/LinearScale.js
* data/QuantitativeScale.js (only numbers)
* data/OrdinalScale.js (not tested)
* mark/Mark.js (doesn't pass tests)
* mark/Bar.js (doesn't pass tests)
* mark/Panel.js (doesn't pass tests)
* text/Format.js (incomplete)
* text/NumberFormat.js (incomplete)

== SYNOPSIS:

    require 'rubyvis'
    x = pv.Scale.linear(crimea, lambda {|d|  d[:date]}).range(0, w)
    y = pv.Scale.linear(0, 1500).range(0, h)
    

== REQUIREMENTS:

Ruby 1.9.1

== INSTALL:

Copy from github and create the gem for yourself (sorry)

== LICENSE:

GPL-2
