module Rubyvis
  def self.Layout
    Rubyvis::Layout
  end
  class Layout < Rubyvis::Panel
    @properties=Panel.properties.dup
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
        define_method(name.to_s+"=") {|v|
          self.send(name,v)
        }
      end
    end
  end
end

require 'rubyvis/layout/stack'
