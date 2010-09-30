module Rubyvis
   # Represents a data-driven graphical mark. The <tt>Mark</tt> class is
   # the base class for all graphical marks in Protovis; it does not provide any
   # specific rendering functionality, but together with {@link Panel} establishes
   # the core framework.
  class Mark
     @properties={}
     
     def self.property_method(name,_def)
       define_method(name) do |*arguments|
         v,dummy = arguments
         if _def and self.scene
           if arguments.size>0
             defs[name]=OpenStruct.new({:id=>(v.nil?) ? 0 : Rubyvis.id, :value=> v})
             return self
           end
           return defs[name]
         end
         if arguments.size>0
           type=(!_def).to_i<<1 | (v.is_a? Proc).to_i
           property_value(name,(type & 1 !=0) ? lambda {|*args| return v.js_apply(self, args)} : v).type=type
           @_properties_types[name]=type
           return self
         end
         i=instance()
         if i.nil?
           raise "No instancia para #{name}"
         else
           #puts "Instancia para #{name}"
           
           i.send(name)
         end
       end
     end
     def property_value(name,v)
       prop=OpenStruct.new({:name=>name, :id=>Rubyvis.id, :value=>v})
       @_properties.delete_if{|v| v.name==name}
       @_properties.push(prop)
       @_properties_values[name]=v
       return prop
     end
     def instance(default_index=nil)
       scene=self.scene
       scene||=self.parent.instance(-1).children[self.child_index]
       if(default_index)
         index=self.respond_to?(:index) ? self.index : default_index
       else
         index=scene.size-1
       end
       #puts "index:#{index} , scene.size:#{scene.size}, default_index:#{default_index}"
       scene[index]
     end
     
     
     def self.attr_accessor_dsl(*attr)
      attr.each  do |sym|
        @properties[sym]=true
        sym_w_sm=sym.to_s.gsub(":","")
        self.property_method(sym,false)
        define_method(sym.to_s+"=") {|v|
          self.send(sym,v)
        }
      end
    end
    
    attr_accessor :parent, :root, :index, :child_index, :scene, :proto, :target, :scale
    attr_accessor_dsl :data,:visible, :left, :right, :top, :bottom, :title, :reverse, :antialias
   
    @scene=nil
    @stack=[]
    @index=nil
    def self.properties
      @properties
    end
    def self.index
      @index
    end
    def self.index=(v)
      @index=v
    end



    def self.scene
      @scene
    end
    def self.scene=(v)
      @scene=v
    end
    def properties
      (self.class).properties
    end
    def Mark.stack
      @stack
    end
    def Mark.stack=(v)
      @stack=v
    end
    def stack
      (self.class).stack
    end
    
    def initialize(opts=Hash.new)
      @_properties_values={}
      @_properties_types={}
      @_properties=[]
      @options=defaults.merge opts
      @stack=[]
      @options.each {|k,v|
        self.send("#{k}=",v) if self.respond_to? k
      }
      @defs={}
      @child_index=-1
      @index=-1
      @scale=1
      @scene=nil
      
    end
    def type
      "mark"
    end
    def _properties
      out={}
      @_properties_values.each {|k,v|
        out[k]=OpenStruct.new({:name=>k.to_s,:value=>v, :type=>@_properties_types[k]})
      }
      out
    end
   
    
   


    
    
    def defaults
      {:data=>lambda {|d| return [d]}, :visible=>true, :antialias=>true}
    end
    def extend(proto)
      @proto=proto
      @target=target
      self
    end
    
    def add(type)
      parent.add(type).extend(self)
    end
    def anchor(name)
      return Anchor.new(self)
    end
    def svg_render_pre
      ""
    end
    def svg_render_post
      ""
    end
    
    
    
    
    
    def build_implied(s)
      l=s.left
      r=s.right
      t=s.top
      b=s.bottom
      prop=self.properties
      w = (prop[:width] and !prop[:width].nil?)  ? s.width : 0
      h = (prop[:height] and !prop[:height].nil?)  ? s.height : 0
      #puts "#{l},#{r},#{t},#{b}"
      #puts "#{w},#{h}"
      
      width=self.parent ? self.parent.width(): (w+(l.nil? ? 0 : l)+(r.nil? ? 0 :r))
      if w.nil?
        w=width-(r ? r :0)-(l ? l : 0)
      elsif r.nil?
        if l.nil?
          l=r=(width-w) / (2.0)
        else
          r=width-w-l
        end
      elsif l.nil?
        l=width-w-r
      end
      
      height=self.parent ? self.parent.height(): (h+(t.nil? ? 0 : t )+(b.nil? ? 0 : b))
      
      if h.nil?
        h=height-(t ? t :0)-(b ? b : 0)
      elsif b.nil?
        if t.nil?
          b=t=(height-h) / 2.0
        else
          b=height-h-t
        end
      elsif t.nil?
        t=height-h-b
      end
      s.left=l
      s.right=r
      s.top=t
      s.bottom=b
      
       # puts "#{l},#{r},#{t},#{b}"
      
      s.width=w if prop[:width]
      s.height=h if prop[:height]
      s.text_style=Rubyvis::Color.transparent if prop[:text_style] and !s.text_style
      s.fill_style=Rubyvis::Color.transparent if prop[:fill_style] and !s.fill_style
      s.stroke_style=Rubyvis::Color.transparent if prop[:stroke_style] and !s.stroke_style
    end
    
    
    
    
    def pr_svg(name)
      res=self.send(name)
      if res.nil?
        "none"
      else
        res.to_s
      end
    end
    def render_render(mark,depth,scale)
      mark.scale=scale
      if (depth < @indexes.size) 
        @stack.unshift(nil)
        if (mark.respond_to? :index) 
            render_instance(mark, depth, scale);
        else 
          mark.scene.size.times {|i|
            mark.index = i;
            render_instance(mark, depth, scale);
          }
        mark.index=nil
        end
        stack.shift();
      else 
        mark.build();
        pv.Scene.scale = scale;
        pv.Scene.update_all(mark.scene);
      end
      mark.scale=nil
    end
    def render_instance(mark,depth,scale)
      s=mark.scene[mark.index]
      if s.visible
        child_index=@indexes[depth]
        child=mark.children[child_index]
        child_index.times {|i|
          mark.children[i].scene=s.children[i]
        }
        @stack[0]=s.data
        if (child.scene)
          render_render(child,depth+1,scale*s.transform.k)
        else
          child.scene=s.children[child_index]
          render_render(child, depth+1,scale*s.transform.k)
          child.scene=nil
        end
        child_index.times {|i|
          mark.children[i].scene=nil
        }
        
      end
    end
    private :render_render, :render_instance
    def bind_bind(mark)
      begin
        @_properties.each {|v|
          k=v.name.to_s
          if !@seen.has_key?(k)
            @seen[k]=v
            case k
              when "data"
                @_data=v
              when "visible"
                @_required.push(v)
              when "id"
                @_required.push(v)
              else
                @types[v.type].push(v)
            end
          end
        }
      end while(mark = mark.proto)
    end
    attr_accessor :binds
    def bind()
      @seen={}
      @types={1=>[],2=>[],3=>[]}
      @_data=nil
      @_required=[]
      bind_bind(self)
      @types[1].reverse!
      @types[3].reverse!
      mark=self
      begin
      properties.each {|name,v|
        if !@seen[name.to_s]
          @seen[name.to_s]=OpenStruct.new(:name=>name.to_s, :type=>2, :value=>nil)
          @types[2].push(@seen[name.to_s])
        end
      }
      end while(mark=mark.proto)
      @binds=OpenStruct.new({:properties=>@seen, :data=>@_data, :required=>@_required, :optional=>@types[1]+@types[2]+@types[3]
      })
    end
    def render
      parent=self.parent
      @stack=Mark.stack
      if parent and !self.root.scene
        root.render()
        return 
      end
      @indexes=[]
      mark=self
      until mark.parent.nil?
        indexes.unshift(mark.child_index)
      end
      self.bind()
      while(parent and !parent.respond_to? :index) do
        parent=parent.parent
      end
      self.context( parent ? parent.scene : nil, parent ? parent.index : -1, lambda {render_render(self.root, 0,1)})
      
    end
    
    def context_apply(scene,index)
      Mark.scene=scene
      Mark.index=index
      return if(!scene)
      that=scene.mark
      mark=that
      ancestors=[]
      begin
        ancestors.push(mark)
        Mark.stack.push(scene[index].data)
        mark.index=index
        mark.scene=scene
        index=scene.parent_index
        scene=scene.parent
      end while(mark=mark.parent)
      k=1
      ancestors.size.times {|ic|
        i=ancestors.size-ic-1
        mark=ancestors[i]
        mark.scale=k
        k=k*mark.scene[mark.index].transform.k
      }
      if (that.children)
        n=than.children.size
        n.times {|i|
          mark=that.children[i]
          mark.scene=that.scene[that.index].children[i]
          mark.scale=k
        }
        
      end
      
    end
    def context_clear(scene,index)
      return if !scene
      that=scene.mark
      mark=nil
      if(that.children)
        that.children.size.times {|i|
          mark=that.children[i]
          mark.scene=nil
          mark.scale=nil
        }
        
      end
      mark=that
      begin
        Mark.stack.pop
        if(mark.parent)
          mark.scene=nil
          mark.scale=nil
        end
        mark.index=nil
      end while(mark=mark.parent)
    end
    def context(scene,index,f)
      proto=Mark
      stack=Mark.stack
      oscene=Mark.scene
      oindex=Mark.index
      context_clear(oscene,oindex)
      context_apply(scene,index)
      begin
        f.js_apply(self, stack)
      ensure
        context_clear(scene,index)
        context_apply(oscene,oindex)
      end
    end
    
    def build
      scene=self.scene
      stack=Mark.stack
      if(!scene)
        self.scene=SceneElement.new
        scene=self.scene
        scene.mark=self
        scene.type=self.type
        scene.child_index=self.child_index
        if(self.parent)
          scene.parent=self.parent.scene
          scene.parent_index=self.parent.index
        end
        if(self.target)
          scene.target=self.target.instances(scene)
        end
        data=self.binds.data
        
        data=(data.type & 1)>0 ? data.value.js_apply(self, stack) : data.value
        stack.unshift(nil)
        
        scene.size=data.size
        data.each_with_index {|d,i|
          Mark.index=self.index=i
          s=scene[i]
          if !s
            scene[i]=s=SceneElement.new
          end
          stack[0]=data[i]
          s.data=data[i]
          build_instance(s)
        }
        Mark.index=-1
        self.index=nil
        stack.shift()
        return self
      end
    end
    def build_instance(s1)
      build_properties(s1, self.binds.required)
      if s1.visible
        build_properties(s1,self.binds.optional)
        build_implied(s1)
      end
    end
    def build_properties(ss, props)
      #p props
      props.each do |prop|
        v=prop.value

      #  p "#{prop.name}=#{v}"
        
        if prop.type==3
          v=v.js_apply(self, Mark.stack)
        end
        ss.send((prop.name.to_s+"=").to_sym, v)
      end
      #p ss
    end
    def naive_render
      out=""
      if !data.nil?
        if data.is_a? Proc
        elsif data.is_a? Array
          data.each_with_index do |d,i|
            self.index=i
            Mark.stack=[d]
            prot=self.clone
            build_implied(prot)
           
            out << prot.svg_render_pre
            out << prot.svg_render_post
          end
          self.index=nil
        end
      end
      out
      
    end
  end
end

require 'rubyvis/mark/bar'
require 'rubyvis/mark/panel'
