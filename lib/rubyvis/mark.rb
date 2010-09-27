module Rubyvis
   # Represents a data-driven graphical mark. The <tt>Mark</tt> class is
   # the base class for all graphical marks in Protovis; it does not provide any
   # specific rendering functionality, but together with {@link Panel} establishes
   # the core framework.
  class Mark
    @properties={}
    @cast={}
    
    # Defines and registers a property method for the property with the
    # given name.  
    # This method should be called on a mark class prototype to define
    # each exposed property. 
    # If invoked with a block, this functions is evaluated for each
    # associated datum.
    # If invoked with non-block, the propery is treated as a constant
    # If invoked with no arument, the computed property value is returned
    
    def self.property(name,_def=false)
      @properties[name]=true
      define_method(:name) {|*arguments|
        v,v1=arguments
        # Ommited def stuff
        if (self.scene and _def)
          raise "Not implemented"
        end
        if arguments.size>0
          is_function=v.is_a? Proc
        else
          instance[name]
        end
      }
      self
    end
    
    property(:data).    property(:visible).    property(:left).    property(:right).    property(:top).    property(:bottom).    property(:cursor).    property(:title).    property(:reverse).    property(:antialias).    property(:events).    property(:id)
    attr_accessor :child_index
    attr_reader :index, :scale
    def initialize
      @child_index=-1
      @index=-1
      @scale=1
      @properties=[]
    end
    def defaults
      Mark.new.data(lambda {|d| return [d];}).visible(true).antialias(true).events("painted")
    end
    def add(type)
      parent.add(type)._extend(self)
    end
    def _extend(proto)
      self.proto=proto
      self.target=proto.target
      return self
    end
    def margin(n)
      left(n).right(n).top(n).bottom(n)
    end
    def anchor(name)
       name = "center" if (!name) # default anchor name
       return new pv.Anchor(self).name(name).data(lambda {self.scene.target.map {|s| s.data}}).visible(lambda {self.scene.target[self.index].visible}).id(lambda {self.scene.target[self.index].id}).left(lambda {
        s = self.scene.target[self.index]
        w = s.width
        w||=0
        case s.name 
          when "center"
            return s.left + w.quo(2)
          when "left"
            return nil
        end
        return s.left + w
      }).top(lambda {
        s1 = self.scene.target[self.index]
        h = s1.height
        h||=0;
        case s.name
          when "center"
            return s.top + h.quo(2)
          when "top"
            return nil
        end
        return s.top + h;
      }).right(lambda {
        s = self.scene.target[self.index];
        return self.name() == "left" ? s.right + (s.width || 0) : nil;
      }).bottom(lambda {
        s = self.scene.target[self.index];
        return self.name() == "top" ? s.bottom + (s.height || 0) : nil;
      }).text_align(lambda {
        case self.name() 
          when "center"
            return "center";
          when "right"
            return "right";
        end
        return "left";
      }).text_baseline(lambda {
        case self.name
          when "center"
            return "middle";
          when "top"
            return "top";
        end
        return "bottom";
      });
    end
    def instance(default_index=nil)
      scene=scene || parent.instance(-1).children[child_index]
      index=!default_index.nil? || (self.respond_to?(:index) ? self.index : default_index)
      return scene[index < 0 ? scene.length - 1 : index]
    end
  end
end
