module Rubyvis
  # Represents a data-driven graphical mark. The <tt>Mark</tt> class is
  # the base class for all graphical marks in Protovis; it does not provide any
  # specific rendering functionality, but together with {@link Panel} establishes
  # the core framework.
  class Mark
    @properties={}

    def self.property_method(name, _def, func=nil, klass=nil)
      return if klass.method_defined? name
      klass.send(:define_method, name) do |*arguments|
        v,dummy = arguments
        if _def and self.scene
          if arguments.size>0
            defs[name]=OpenStruct.new({:id=>(v.nil?) ? 0 : Rubyvis.id, :value=> v})
            return self
          end
          return defs[name]
        end
        if arguments.size>0
          v=v.to_proc if v.respond_to? :to_proc
          type=(!_def).to_i<<1 | (v.is_a? Proc).to_i          
          
          property_value(name,(type & 1 !=0) ? lambda {|*args|
              x=v.js_apply(self, args)
              (func and x) ? func.call(x) : x
          } : (func and v) ? func.call(v) : v)._type=type
          #@_properties_types[name]=type
          return self
        end
        i=instance()
        if i.nil?
          raise "No instance for #{self} on #{name}"
        else
        #          puts "index:#{self.index}, name:#{name}, val:#{i.send(name)}"
          i.send(name)
        end
      end
      
      camel=name.to_s.gsub(/(_.)/) {|v| v[1,1].upcase}
      if camel!=name
        klass.send(:alias_method, camel, name)
      end
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
      self.property_method(name,false, func, Rubyvis::Mark)        
      define_method(name.to_s+"=") {|v|
        self.send(name,v)
      }
      end
    end

    
    def property_value(name,v)
      prop=Property.new({:name=>name, :id=>Rubyvis.id, :value=>v})
      @_properties.delete_if{|v1| v1.name==name}
      @_properties.push(prop)
      #@_properties_values[name]=v
      return prop
    end
    def margin(n)
      self.left(n).right(n).top(n).bottom(n)
    end
    def instance(default_index=nil)
      scene=self.scene
      scene||=self.parent.instance(-1).children[self.child_index]

      index = self.respond_to?(:index) ? self.index : default_index
      #puts "type: #{type}, self.index: #{self.index}, index:#{index}"
      scene[index<0 ? scene.length-1: index]
    end



    attr_accessor :parent, :root, :index, :child_index, :scene, :proto, :target, :scale
    attr_reader :_properties
    
    
    attr_accessor_dsl :data,:visible, :left, :right, :top, :bottom, :cursor, :title, :reverse, :antialias, :events, :id

    @scene=nil
    @stack=[]
    @index=nil
    def self.properties
      @properties
    end
    def Mark.index
      @index
    end
    def Mark.index=(v)
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

    def initialize(opts=Hash.new)
      @_properties=[]
      opts.each {|k,v|
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
    def self.defaults
      Mark.new({:data=>lambda {|d| [d]}, :visible=>true, :antialias=>true, :events=>'painted'})
    end
    def extend(proto)
      @proto=proto
      @target=proto.target
      self
    end

    def instances(source)

      mark = self
      index = []
      scene=nil
      while (!(scene = mark.scene)) do
        source = source.parent;
        index.push(OpenStruct.new({:index=>source.index, :child_index=>mark.child_index}))
        mark = mark.parent
      end

      while (index.size>0) do
        i = index.pop()
        scene = scene[i.index].children[i.child_index]
      end
      #
      # When the anchor target is also an ancestor, as in the case of adding
      # to a panel anchor, only generate one instance per panel. Also, set
      # the margins to zero, since they are offset by the enclosing panel.
      # /
      if (self.respond_to? :index and self.index)

        s = scene[self.index].dup
        s.right = s.top = s.left = s.bottom = 0;
        return [s];
      end
      return scene;
    end
    def sibling
      (self.index==0) ? nil: self.scene[self.index-1]
    end
    def cousin
      par=self.parent
      s= par ? par.sibling : nil
      (s and s.children) ? s.children[self.child_index][self.index] : nil
    end
    def add(type)
      parent.add(type).extend(self)
    end
    def anchor(name='center')
      mark_anchor(name)
    end
    def mark_anchor(name="center")

      anchor=Rubyvis::Anchor.new(self).name(name).data(lambda {
      self.scene.target.map {|s| s.data} }).visible(lambda {
        self.scene.target[self.index].visible
      }).id(lambda {self.scene.target[self.index].id}).left(lambda {
        s = self.scene.target[self.index]
        w = s.width
        w||=0
        if ['bottom','top','center'].include?(self.name)
          s.left + w / 2.0
        elsif self.name=='left'
          nil
        else
          s.left + w
        end
      }).top(lambda {
        s = self.scene.target[self.index]
        h = s.height
        h||= 0
        if ['left','right','center'].include? self.name
          s.top+h/2.0
        elsif self.name=='top'
          nil
        else
          s.top + h
        end
      }).right(lambda {
        s = self.scene.target[self.index]
        self.name() == "left" ? s.right + (s.width ? s.width : 0) : nil;
      }).bottom(lambda {
        s = self.scene.target[self.index];
        self.name() == "top" ? s.bottom + (s.height ? s.height : 0) : nil;
      }).text_align(lambda {
        if ['bottom','top','center'].include? self.name
          'center'
        elsif self.name=='right'
          'right'
        else
          'left'
        end
      }).text_baseline(lambda {
        if ['right','left','center'].include? self.name
          'middle'
        elsif self.name=='top'
          'top'
        else
          'bottom'
        end
      })
      return anchor
    end



    def build_implied(s)
      mark_build_implied(s)
    end

    def mark_build_implied(s)
      l=s.left
      r=s.right
      t=s.top
      b=s.bottom
      prop=self.properties
      
      #p self
      
      w = (prop[:width])  ? s.width : 0
      h = (prop[:height])  ? s.height : 0
      
      width=self.parent ? self.parent.width() : (w+(l.nil? ? 0 : l)+(r.nil? ? 0 : r))
      #puts (self.parent)? "parent width: #{self.parent.width}" : "no parent" if $DEBUG
      #p prop.sort if $DEBUG
      puts "build implied #{type}: l:#{l},r:#{r},t:#{t},b:#{b}, w:#{prop[:width]} #{w},h: #{prop[:height]} #{h}, width:#{width}" if $DEBUG
      if w.nil?
        r||=0
        l||=0
        w=width-r-l
      elsif r.nil?
        if l.nil?
          r=(width-w) / (2.0)
          l=r
        else
          r=width-w-l
        end
      elsif l.nil?
        l=width-w-r
      end

      height=self.parent ? self.parent.height(): (h+(t.nil? ? 0 : t )+(b.nil? ? 0 : b))

      if h.nil?
        t||=0
        b||=0
        h=height-t-b
      elsif b.nil?
        if t.nil?
          t=(height-h) / 2.0
          b=t
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

      puts "Post->left: #{l},right:#{r},top:#{t},bottom:#{b}, width:#{w}, height:#{h}" if $DEBUG

      s.width=w if prop[:width]
      #puts "width:#{s.width}" if $DEBUG
      s.height=h if prop[:height]
      s.text_style=Rubyvis::Color.transparent if prop[:text_style] and !s.text_style
      s.fill_style=Rubyvis::Color.transparent if prop[:fill_style] and !s.fill_style
      s.stroke_style=Rubyvis::Color.transparent if prop[:stroke_style] and !s.stroke_style
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
        @indexes.unshift(mark.child_index)
      end
      bind
      while(parent and !parent.respond_to? :index) do
        parent=parent.parent
      end

      self.context( parent ? parent.scene : nil, parent ? parent.index : -1, lambda {render_render(self.root, 0,1)})

    end

    def render_render(mark,depth,scale)
      mark.scale=scale
      if (depth < @indexes.size)
        @stack.unshift(nil)
        if (mark.respond_to? :index and mark.index)
          render_instance(mark, depth, scale);
        else
          mark.scene.size.times {|i|
            mark.index = i;
            render_instance(mark, depth, scale);
          }
          mark.index=nil
        end
        stack.shift
      else
        mark.build
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
        Mark.stack[0]=s.data

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
        mark._properties.each {|v|
          #p v.name
          k=v.name
          if !@seen.has_key?(k)
            @seen[k]=v
            case k
            when :data
              @_data=v
            when :visible
              @_required.push(v)
            when :id
              @_required.push(v)
            else
              @types[v._type].push(v)
            end
          end
        }
      end while(mark = mark.proto)
    end

    attr_accessor :binds
    def bind
      mark_bind
    end
    def mark_bind()
      @seen={}
      @types={1=>[],2=>[],3=>[]}
      @_data=nil
      @_required=[]
      bind_bind(self)
      bind_bind((self.class).defaults)
      @types[1].reverse!
      @types[3].reverse!
      mark=self
      begin
        properties.each {|name,v|
          if !@seen[name]
            @seen[name]=Property.new(:name=>name, :_type=>2, :value=>nil)
            @types[2].push(@seen[name])
          end
        }
      end while(mark=mark.proto)
      @binds=OpenStruct.new({:properties=>@seen, :data=>@_data, :required=>@_required, :optional=>@types[1]+@types[2]+@types[3]
      })
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
        n=that.children.size
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
      end
      # Resolve anchor target
      #puts "Resolve target"
      if(self.target)
        scene.target=self.target.instances(scene)
      end
      #pp self.binds
      data=self.binds.data
      #puts "stack:#{stack}"
      #puts "data_value:#{data.value}"

      data=(data._type & 1)>0 ? data.value.js_apply(self, stack) : data.value
      #puts "data:#{data}"

      stack.unshift(nil)
      scene.size=data.size
      data.each_with_index {|d, i|
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
    def build_instance(s)
      mark_build_instance(s)
    end
    def mark_build_instance(s1)
      build_properties(s1, self.binds.required)
      if s1.visible
        build_properties(s1, self.binds.optional)
        build_implied(s1)
      end
    end
    def build_properties(ss, props)
      #p props
      props.each do |prop|
        v=prop.value

        # p "#{prop.name}=#{v}"
        if prop._type==3
          v=v.js_apply(self, Mark.stack)
        end
        ss.send((prop.name.to_s+"=").to_sym, v)
      end
      # p ss
    end
    def event(type,handler)
      #@_handlers[type]=handler
      return self
    end
  end
end

require 'rubyvis/mark/anchor'
require 'rubyvis/mark/bar'
require 'rubyvis/mark/panel'
require 'rubyvis/mark/area'
require 'rubyvis/mark/line'
require 'rubyvis/mark/rule'
require 'rubyvis/mark/label'
require 'rubyvis/mark/dot'
require 'rubyvis/mark/wedge'
