$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'spec'
require 'spec/autorun'
require 'rubyvis'
require 'pp'
require 'nokogiri'
$PROTOVIS_DIR=File.dirname(__FILE__)+"/../vendor/protovis/src"
module Rubyvis
  class JohnsonLoader
    begin
      require 'johnson'
      def self.available?
        true
      end
    rescue LoadError
      def self.available?
        false
      end
    end
    attr_accessor :runtime
    def initialize(*files)
      files=["/pv.js","/pv-internals.js", "/data/Arrays.js","/data/Numbers.js", "/data/Scale.js", "/data/QuantitativeScale.js", "/data/LinearScale.js","/color/Color.js","/color/Colors.js","/text/Format.js", "/text/DateFormat.js","/text/NumberFormat.js","/text/TimeFormat.js"]+files
      files.uniq!
      files=files.map {|v| $PROTOVIS_DIR+v}
      @runtime = Johnson.load(*files)
    end
  end
end