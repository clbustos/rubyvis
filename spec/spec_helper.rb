$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'rspec'
#require 'spec/autorun'
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
# Spec matcher 
RSpec::Matchers.define :have_svg_attributes do |exp|
  match do |obs|
    exp.each {|k,v|
      obs.attributes[k].value.should==v
    }
  end
end
RSpec::Matchers.define :have_path_data_close_to do |exp|
  def path_scan(path)
      path.scan(/([MmCcZzLlHhVvSsQqTtAa, ])(\d+(?:\.\d+)?)/).map {|v|
      v[0]="," if v[0]==" "
      v[1]=v[1].to_f
      v
      }
    end
  match do |obs|
    correct=true
    obs_array=path_scan(obs.attributes["d"].value)
    
    exp_array=path_scan(exp)
    obs_array.each_with_index {|v,i|
      if (v[0]!=exp_array[i][0]) or (v[1]-exp_array[i][1]).abs>0.001
        correct=false
        break
      end
    }
    correct
  end
  failure_message_for_should do |obs|
    obs_array=path_scan(obs.attributes["d"].value)
    exp_array=path_scan(exp)
    "#{obs_array} path should be equal to #{exp_array}"
  end
end