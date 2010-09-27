$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'spec'
require 'spec/autorun'
require 'rubyvis'
require 'pp'
$PROTOVIS_DIR=File.dirname(__FILE__)+"/../vendor/protovis/src"
module Rubyvis
  class JohnsonLoader
    def initialize(*files)
      require 'johnson'
      @runtime = Johnson::Runtime.new
    end
  end
end