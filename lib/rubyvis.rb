require 'date'
require 'ostruct'
require 'rubyvis/internals'
require 'rubyvis/javascript_behaviour'
require 'rubyvis/format'
require 'rubyvis/label'
require 'rubyvis/mark'
require 'rubyvis/bar'
require 'rubyvis/panel'
require 'rubyvis/scale'
require 'rubyvis/color/color'
require 'rubyvis/color/colors'

def pv
  Rubyvis
end

module Rubyvis
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
