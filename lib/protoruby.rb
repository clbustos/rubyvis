require 'date'
require 'ostruct'
require 'protoruby/internals'
require 'protoruby/javascript_behaviour'
require 'protoruby/format'
require 'protoruby/label'
require 'protoruby/mark'
require 'protoruby/bar'
require 'protoruby/panel'
require 'protoruby/scale'
require 'protoruby/color/color'
require 'protoruby/color/colors'

def pv
  Protoruby
end

module Protoruby
  VERSION = '1.0.0'
  Infinity=1.0 / 0 # You actually can do it! http://snipplr.com/view/2137/uses-for-infinity-in-ruby/
  # :section: basic methods
  def self.identity
    lambda {|x,*args| x}
  end
  def self.index
    lambda {|*args| self.index}
  end
  def self.child
    lambda {|*args| self.child_index}
  end
  def self.parent
    lambda {|*args| self.parent.index}
  end
end
