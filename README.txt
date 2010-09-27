= protoruby

* http://github.com/clbustos/rubyvis

== DESCRIPTION:

Ruby version of Protovis, a great visualization toolkit

== FEATURES/PROBLEMS:

I try to maintain, when posible, complete compatibility with Javascript API.
Until version 0.1.0, this implies that lambdas should always should created explicitly and this library will run only on Ruby 1.9.1.
On a second stage, traditional block calling could be using maintaining backwards compatibily with Javascript API and provides Ruby 1.8.7 support.
User could use +pv+ freely, cause is defined as a global method which call Rubyvis.


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
