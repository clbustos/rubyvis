module Rubyvis
  def self.Layout
    Rubyvis::Layout
  end
  class Layout < Rubyvis::Panel
    @properties=Panel.properties.dup
    def build_properties(s,properties)      
      layout_build_properties(s,properties)
    end
    def layout_build_properties(s,properties)
      mark_build_properties(s, properties)
    end
    def layout_build_implied(s)      
      panel_build_implied(s)
    end
    def self.attr_accessor_dsl(*attr)
      attr.each  do |sym|
        if sym.is_a? Array
          name,func=sym
        else
          name=sym
          func=nil
        end
        @properties[name]=true
        self.property_method(name,false, func, self)

        remove_method(name.to_s+"=") if public_method_defined? name.to_s+"="
        
        define_method(name.to_s + "=") {|v|
          self.send(name,v)
        }
      end
    end
  end
end

require 'rubyvis/layout/stack'
require 'rubyvis/layout/horizon'
require 'rubyvis/layout/grid'
require 'rubyvis/layout/network'
require 'rubyvis/layout/hierarchy'
require 'rubyvis/layout/tree'
require 'rubyvis/layout/treemap'
require 'rubyvis/layout/partition'
require 'rubyvis/layout/cluster'
require 'rubyvis/layout/indent'
require 'rubyvis/layout/pack'
require 'rubyvis/layout/arc'
require 'rubyvis/layout/matrix'

