require 'date'
require 'ostruct'
require 'rexml/document'
require 'pp'
require 'rubyvis/internals'
require 'rubyvis/sceneelement'

require 'rubyvis/javascript_behaviour'
require 'rubyvis/format'
require 'rubyvis/label'
require 'rubyvis/mark'
require 'rubyvis/scale'
require 'rubyvis/color/color'
require 'rubyvis/color/colors'

require 'rubyvis/scene/svg_scene'
require 'rubyvis/transform'

def pv
  Rubyvis
end

module Rubyvis
  VERSION = '0.1.0'
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
  def self.document
    @document||=REXML::Document.new
  end
    
end
