module Protoruby
   # Represents a data-driven graphical mark. The <tt>Mark</tt> class is
   # the base class for all graphical marks in Protovis; it does not provide any
   # specific rendering functionality, but together with {@link Panel} establishes
   # the core framework.
  class Mark
    # Defines and registers a property method for the property with the
    # given name.  
    # This method should be called on a mark class prototype to define
    # each exposed property. 
    # If invoked with a block, this functions is evaluated for each
    # associated datum.
    # If invoked with non-block, the propery is treated as a constant
    # If invoked with no arument, the computed property value is returned
    def self.property(*syms)
      syms.each do |sym|
        sym_w_sm=sym.to_s.gsub(":","")
        define_method(sym) do |*args, &block|
          if args.size==0
            var=instance_variable_get("@#{sym_w_sm}")
            if var.is_a? Proc
              var.arity<1 ? self.instance_eval(&var) : var.call(self)
            else
              var
            end
          else
            if args.size==0 and block
              instance_variable_set("@#{sym_w_sm}", block)
            else
              instance_variable_set("@#{sym_w_sm}", args[0])
            end
            return self
          end
        end
        
        define_method(sym.to_s+"=") do |*args|
          instance_variable_set("@#{sym_w_sm}", args[0])
        end
      end
    end
    
    property :data, :visible, :left, :right, :top, :bottom, :cursor, :title, :reverse, :antialias, :events, :id
    attr_reader :child_index, :index, :scale
    def initialize
      @child_index=-1
      @index=-1
      @scale=1
      
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
       return new pv.Anchor(self)
    .name(name)
    .data(lambda {self.scene.target.map {|s| s.data}})
    .visible(lambda {self.scene.target[self.index].visible})
    .id(lambda {self.scene.target[self.index].id})
    .left(lambda {
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
      })
    .top(lambda {|s|
        s1 = s.scene.target[s.index]
        h = s1.height
        h||=0;
        case s.name
          when "center"
            return s.top + h.quo(2)
          when "top"
            return nil
        end
        return s.top + h;
      })
    .right(lambda {|s1|
        s = s1.scene.target[s1.index];
        return s1.name() == "left" ? s.right + (s.width || 0) : nil;
      })
    .bottom(lambda {|s1|
        s = s1.scene.target[this.index];
        return s1.name() == "top" ? s.bottom + (s.height || 0) : nil;
      })
    .text_align(lambda {|this|
        case this.name() 
          when "center"
            return "center";
          when "right"
            return "right";
        end
        return "left";
      })
    .text_baseline(lambda {|this|
        case this.name
          when "center"
            return "middle";
          when "top"
            return "top";
        end
        return "bottom";
      });
    end
    def instance(default_index=nil)
      scene=self.scene || self.parent.instance(-1).children[self.child_index]
      index=!default_index.nil? || self.respond_to? :index ? self.index : default_index
      return scene[index < 0 ? scene.length - 1 : index];.
    end
  end
end
