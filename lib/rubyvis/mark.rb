module Rubyvis
  # Constructs a new mark with default properties. Marks, with the exception of
  # the root panel, are not typically constructed directly; instead, they are
  # added to a panel or an existing mark via Mark#add
  #
  # Represents a data-driven graphical mark. The +Mark+ class is
  # the base class for all graphical marks in Protovis; it does not provide any
  # specific rendering functionality, but together with Panel establishes
  # the core framework.
  #
  # Concrete mark types include familiar visual elements such as bars, lines
  # and labels. Although a bar mark may be used to construct a bar chart, marks
  # know nothing about charts; it is only through their specification and
  # composition that charts are produced. These building blocks permit many
  # combinatorial possibilities.
  #
  # Marks are associated with <b>data</b>: a mark is generated once per
  # associated datum, mapping the datum to visual <b>properties</b> such as
  # position and color. Thus, a single mark specification represents a set of
  # visual elements that share the same data and visual encoding. The type of
  # mark defines the names of properties and their meaning. A property may be
  # static, ignoring the associated datum and returning a constant; or, it may be
  # dynamic, derived from the associated datum or index. Such dynamic encodings
  # can be specified succinctly using anonymous functions. Special properties
  # called event handlers can be registered to add interactivity.
  #
  # Protovis uses <b>inheritance</b> to simplify the specification of related
  # marks: a new mark can be derived from an existing mark, inheriting its
  # properties. The new mark can then override properties to specify new
  # behavior, potentially in terms of the old behavior. In this way, the old mark
  # serves as the <b>prototype</b> for the new mark. Most mark types share the
  # same basic properties for consistency and to facilitate inheritance.
  #
  # The prioritization of redundant properties is as follows:<ol>
  #
  # <li>If the <tt>width</tt> property is not specified (i.e., null), its value
  # is the width of the parent panel, minus this mark's left and right margins;
  # the left and right margins are zero if not specified.
  #
  # <li>Otherwise, if the <tt>right</tt> margin is not specified, its value is
  # the width of the parent panel, minus this mark's width and left margin; the
  # left margin is zero if not specified.
  #
  # <li>Otherwise, if the <tt>left</tt> property is not specified, its value is
  # the width of the parent panel, minus this mark's width and the right margin.
  #
  # </ol>This prioritization is then duplicated for the <tt>height</tt>,
  # <tt>bottom</tt> and <tt>top</tt> properties, respectively.
  #
  # While most properties are <i>variable</i>, some mark types, such as lines
  # and areas, generate a single visual element rather than a distinct visual
  # element per datum. With these marks, some properties may be <b>fixed</b>.
  # Fixed properties can vary per mark, but not <i>per datum</i>! These
  # properties are evaluated solely for the first (0-index) datum, and typically
  # are specified as a constant. However, it is valid to use a function if the
  # property varies between panels or is dynamically generated.
  #
  # == 'RBP' API
  # 
  # Since version 0.2.0, you could use a new API to use marks
  # , similar to one described on Brown's "Ruby Best Practices".
  # === Set properties using blocks 
  # You could use a block to set a property, without using explicitly
  # lambda statement. So
  #   area.width {|d| d*20}
  # is the same as
  #   area.width lambda {|d| d*20}
  # === Shortcuts methods
  # The protovis API uses the chain method aproach. Every method which
  # set a value on a object returns the same object. I maintain
  # this approach, and you can do
  #
  #   area.width(10).height(20).top(lambda {|d| d*10})
  #
  # To add a mark to another, you need to use +add+ method. This methods
  # returns the new mark, so you can still use the chain methods API,
  #
  #   area.width(10).height(20). # object is 'area'
  #   add(Rubyvis::Label).       # object changed to new label
  #     text('hi')               # text refers to new label
  # 
  # In the spirit of RBP, I created several methods as shortcut for +add+:
  # area(), bar(), dot(), image(), label(), line(), panel(), rule() and wedge().
  # If you provide a block, it will be executed inside the context of current of new mark depending on block's parameter.
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Parameter references the new mark
  # 
  # ==Example
  #
  # *Without parameter*
  #  vis=Rubyvis::Panel.new do
  #    area do
  #      width 10 # width changed for area
  #      height 10 # height changed for area
  #    end
  #  end
  # 
  # *Without parameter*
  #  vis=Rubyvis::Panel.new do
  #    area do |a|
  #      width 10 # width changed for panel
  #      a.height 10 # height changed for area
  #    end
  #  end
  #
  class Mark
    # On ruby 1.8, we must delete #id method
    # Is deprecated, so any good developer should'nt use it....
    if RUBY_VERSION<"1.9"
      undef_method :id
    end

    # Hash storing properties names for current Mark type. 
    @properties={}
    
     # The enclosing parent panel. The parent panel is generally undefined only for the root panel; however, it is possible to create "offscreen" marks that are used only for inheritance purposes.
    # @attr [Panel]
    attr_accessor :parent
    
    # The root parent panel. This may be undefined for "offscreen" marks that are
    # created for inheritance purposes only.
    #
    # @attr [Panel]
    attr_accessor :root
    
    # The child index. -1 if the enclosing parent panel is nil; otherwise, the
    # zero-based index of this mark into the parent panel's <tt>children</tt>
    # array.
    # @attr [Number]
    attr_accessor :child_index
    
    
    # The scene graph. The scene graph is an array of objects; each object
    # (or "node") corresponds to an instance of this mark and an element in the
    # data array. The scene graph can be traversed to lookup previously-evaluated
    # properties.
    attr_accessor :scene
    
    # The mark prototype, possibly undefined, from which to inherit property
    # functions. The mark prototype is not necessarily of the same type as this
    # mark. Any properties defined on this mark will override properties inherited
    # either from the prototype or from the type-specific defaults.
    # @attr [Mark]
    attr_accessor :proto
    
    # The mark anchor target, possibly undefined.
    # @attr [Mark]
    attr_accessor :target
    
    # The current scale factor, based on any enclosing transforms. The current
    # scale can be used to create scale-independent graphics. For example, to
    # define a dot that has a radius of 10 irrespective of any zooming, say:
    #
    # <pre>dot.shape_radius(lambda { 10 / self.scale})</pre>
    #
    # Note that the stroke width and font size are defined irrespective of scale
    # (i.e., in screen space) already. Also note that when a transform is applied
    # to a panel, the scale affects only the child marks, not the panel itself.
    # @attr [Float]
    # @see Panel#transform
    attr_accessor :scale
    
    # Array with stores properties values 
    attr_reader :_properties
    
    # OpenStruct which store values for scenes
    attr_accessor :binds

    
    # Defines a setter-getter for the specified property.
    #
    # If a cast function has been assigned to the specified property name, the
    # property function is wrapped by the cast function, or, if a constant is
    # specified, the constant is immediately cast. Note, however, that if the
    # property value is nil, the cast function is not invoked.
    # 
    # Parameters:
    # * @param [String] name the property name.
    # * @param [Boolean] +def+ whether is a property or a def.
    # * @param [Proc] +cast+ the cast function for this property.
    # * @param [Class] +klass+ the klass on which property will be added
    
    def self.property_method(name, _def, func=nil, klass=nil)
      return if klass.method_defined? name
      klass.send(:define_method, name) do |*arguments,&block|
        v=arguments[0]
        #v,dummy = arguments
        if block
          v=block
        end
        if _def and self.scene
          if arguments.size>0
            defs[name]=OpenStruct.new({:id=>(v.nil?) ? 0 : Rubyvis.id, :value=> v})
            return self
          end
          return defs[name]
        end
        
        if arguments.size>0 or block
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
    
    # Creates a dinamic property using property_method().
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
    
    # Delete index
    # @private
    def delete_index
      @index=nil
      @index_defined=false
    end
    
    # The mark index. The value of this field depends on which instance (i.e.,
    # which element of the data array) is currently being evaluated. During the
    # build phase, the index is incremented over each datum; when handling events,
    # the index is set to the instance that triggered the event.
    # @return [Integer]
    def index
      if @index.nil?
        Mark.index
      else
        @index
      end
    end
    # Returns true if index attribute is set and not deleted
    def index_defined?
      @index_defined
    end
    # Set index attribute.
    def index=(v)
      @index_defined=true
      @index=v
      v
    end
    
    # Sets the value of the property <i>name</i> to <i>v</i>    
    def property_value(name,v)
      prop=Property.new({:name=>name, :id=>Rubyvis.id, :value=>v})
      @_properties.delete_if{|v1| v1.name==name}
      @_properties.push(prop)
      #@_properties_values[name]=v
      prop
    end
    
    # Alias for setting the left, right, top and bottom properties simultaneously.
    # 
    # @see Mark#left
    # @see Mark#right
    # @see Mark#top
    # @see Mark#bottom
    # @return [Mark] self
    def margin(n)
      self.left(n).right(n).top(n).bottom(n)
    end
    
    
    # Returns the current instance of this mark in the scene graph.
    # This is typically equivalent to +self.scene[self.index]+, however if the scene or index is unset, the default instance of the mark is returned. If no default is set, the default is the last instance. 
    # Similarly, if the scene or index of the parent panel is unset, the default instance of this mark in the last instance of the enclosing panel is returned, and so on.
    #
    # @return a node in the scene graph.
    def instance(default_index=nil)
      scene=self.scene
      scene||=self.parent.instance(-1).children[self.child_index]
      
      index = !self.index.nil? ? self.index : default_index
      
      #puts "defined?: #{index_defined?} : type: #{type}, self.index: #{self.index}, default_index: #{default_index}, index:#{index}"
      scene[index < 0 ? scene.size-1: index]
    end

    ##
    # :section: Marks properties
    ##
    
    ##
    # :attr: data
    # The data property; an array of objects. The size of the array determines the number of marks that will be instantiated; each element in the array will be passed to property functions to compute the property values. Typically, the data property is specified as a constant array, such as
    #   m.data([1, 2, 3, 4, 5])
    # However, it is perfectly acceptable to define the data property as a
    # proc. This function might compute the data dynamically, allowing
    # different data to be used per enclosing panel. For instance, in the stacked
    # area graph example (see Mark#scene), the data function on the area mark
    # dereferences each series.
    
    ##
    # :attr: visible
    # The visible property; a boolean determining whether or not the mark instance
    # is visible. If a mark instance is not visible, its other properties will not
    # be evaluated. Similarly, for panels no child marks will be rendered.
    
    ##
    # :attr: left
    # The left margin; the distance, in pixels, between the left edge of the
    # enclosing panel and the left edge of this mark. Note that in some cases this
    # property may be redundant with the right property, or with the conjunction of
    # right and width.
    
    ##
    # :attr: right
    # The right margin; the distance, in pixels, between the right edge of the
    # enclosing panel and the right edge of this mark. Note that in some cases this
    # property may be redundant with the left property, or with the conjunction of
    # left and width.
    
    ##
    # :attr: top
    # The top margin; the distance, in pixels, between the top edge of the
    # enclosing panel and the top edge of this mark. Note that in some cases this
    # property may be redundant with the bottom property, or with the conjunction
    # of bottom and height.
    
    ##
    # :attr: bottom
    # The bottom margin; the distance, in pixels, between the bottom edge of the
    # enclosing panel and the bottom edge of this mark. Note that in some cases
    # this property may be redundant with the top property, or with the conjunction
    # of top and height.
    
    ##
    # :attr: cursor
    # The cursor property; corresponds to the CSS cursor property. This is
    # typically used in conjunction with event handlers to indicate interactivity.
    # See {CSS 2 cursor}[http://www.w3.org/TR/CSS2/ui.html#propdef-cursor]
    
    ##
    # :attr: title
    # The title property; corresponds to the HTML/SVG title property, allowing the
    # general of simple plain text tooltips.
    
    
    ##
    # :attr: events
    # The events property; corresponds to the SVG pointer-events property,
    # specifying how the mark should participate in mouse events. The default value
    # is "painted". Supported values are:
    #
    # <p>"painted": The given mark may receive events when the mouse is over a
    # "painted" area. The painted areas are the interior (i.e., fill) of the mark
    # if a 'fillStyle' is specified, and the perimeter (i.e., stroke) of the mark
    # if a 'strokeStyle' is specified.
    #
    # <p>"all": The given mark may receive events when the mouse is over either the
    # interior (i.e., fill) or the perimeter (i.e., stroke) of the mark, regardless
    # of the specified fillStyle and strokeStyle.
    #
    # <p>"none": The given mark may not receive events.
    
    ##
    # :attr: reverse
    # The reverse property; a boolean determining whether marks are ordered from
    # front-to-back or back-to-front. SVG does not support explicit z-ordering;
    # shapes are rendered in the order they appear. Thus, by default, marks are
    # rendered in data order. Setting the reverse property to false reverses the
    # order in which they are rendered; however, the properties are still evaluated
    # (i.e., built) in forward order.
    
    ##
    # :attr: id
    # The instance identifier, for correspondence across animated transitions. If
    # no identifier is specified, correspondence is determined using the mark
    # index. Identifiers are not global, but local to a given mark.
    
    #
    
    attr_accessor_dsl :data, :visible, :left, :right, :top, :bottom, :cursor, :title, :reverse, :antialias, :events, :id

    @scene=nil
    @stack=[]
    @index=nil

    # @private Records which properties are defined on this mark type.
    def self.properties
      @properties
    end
    # Common index for all marks
    def Mark.index
      @index
    end
    
    # Set common index for all marks    
    def Mark.index=(v)
      @index=v
    end
    # Get common scene for all marks    
    def self.scene
      @scene
    end
    # Set common scene for all marks        
    def self.scene=(v)
      @scene=v
    end
    
    
    # Return properties for current mark
    def properties
      (self.class).properties
    end
    # Get common stack for all marks    
    def Mark.stack
      @stack
    end
    # Set common stack for all marks        
    def Mark.stack=(v)
      @stack=v
    end

    # Create a new Mark
    def initialize(opts=Hash.new, &block)
      @_properties=[]
      opts.each {|k,v|
        self.send("#{k}=",v) if self.respond_to? k
      }
      @defs={}
      @child_index=-1
      @index=-1
      @index_defined = true
      @scale=1
      @scene=nil
      if block
        execute(&block)
        #block.arity<1 ? self.instance_eval(&block) : block.call(self)
      end
    end
    # Execute a block using this mark as a reference
    # <b>Example</b>
    #   bar.execute |b|
    #     b.width 10
    #     b.add(Rubyvis::Label)
    #   end
    def execute(&block)
      block.arity<1 ? self.instance_eval(&block) : block.call(self)      
    end
    # The mark type; a lower name. The type name controls rendering
    # behavior, and unless the rendering engine is extended, must be one of the
    # built-in concrete mark types: area, bar, dot, image, label, line, panel,
    # rule, or wedge.
    def type
      "mark"
    end
    
    # Default properties for all mark types. By default, the data array is the
    # parent data as a single-element array; if the data property is not
    # specified, this causes each mark to be instantiated as a singleton 
    # with the parents  datum. The visible property is true by default, 
    # and the reverse property is false.    
    def self.defaults
      Mark.new({:data=>lambda {|d| [d]}, :visible=>true, :antialias=>true, :events=>'painted'})
    end
    
    # Sets the prototype of this mark to the specified mark. Any properties not
    # defined on this mark may be inherited from the specified prototype mark,
    # or its prototype, and so on. The prototype mark need not be the same 
    # type of mark as this mark. (Note that for inheritance to be useful,
    # properties with the same name on different mark types should 
    # have equivalent meaning).
    # On protovis, this method is called +extend+, but it should be changed
    # because clashed with native +extend+ method
    def mark_extend(proto)
      @proto=proto
      @target=proto.target
      self
    end
    # Find the instances of this mark that match source.
    # @see Anchor
    def instances(source)
      mark = self
      _index = []
      scene=nil
      
      while (!(scene = mark.scene)) do
        source = source.parent;
        _index.push(OpenStruct.new({:index=>source.index, :child_index=>mark.child_index}))
        mark = mark.parent
      end

      while (_index.size>0) do
        i = _index.pop()
        scene = scene[i.index].children[i.child_index]
      end
      #
      # When the anchor target is also an ancestor, as in the case of adding
      # to a panel anchor, only generate one instance per panel. Also, set
      # the margins to zero, since they are offset by the enclosing panel.
      # /
      
      if (index_defined?)
        s = scene[self.index].dup
        s.right = s.top = s.left = s.bottom = 0;
        return [s];
      end
      scene
    end
    

    # Returns the first instance of this mark in the scene graph. This
    # method can only be called when the mark is bound to the scene graph (for
    # example, from an event handler, or within a property function).
    #
    # * @returns a node in the scene graph.
    def first 
      scene[0]
    end
    # Returns the last instance of this mark in the scene graph. This
    # method can only be called when the mark is bound to the scene graph (for
    # example, from an event handler, or within a property function). In addition,
    # note that mark instances are built sequentially, so the last instance of this
    # mark may not yet be constructed.
    #
    # * @returns a node in the scene graph.
    def last 
      scene[scene.size - 1]
    end
    
        
    # Returns the previous instance of this mark in the scene graph, or
    # nil if this is the first instance.
    #
    # @return a node in the scene graph, or nil.
    def sibling
      (self.index==0) ? nil: self.scene[self.index-1]
    end
    
    
    # Returns the current instance in the scene graph of this mark,
    # in the previous instance of the enclosing parent panel. 
    # May return nil if this instance could not be found.
    #
    # @return a node in the scene graph, or nil.
    def cousin
      par=self.parent
      s= par ? par.sibling : nil
      (s and s.children) ? s.children[self.child_index][self.index] : nil
    end
    
    # Adds a new mark of the specified type to the enclosing parent panel,
    # whilst simultaneously setting the prototype of the new mark 
    # to be this mark.
    #
    # * @param {function} type the type of mark to add; a constructor, such as
    # +Rubyvis::Bar+
    # * @returns {Mark} the new mark.
    # * @see #mark_extend
    def add(type)
      parent.add(type).mark_extend(self)
    end
    # Returns an anchor with the specified name. All marks support the five
    # standard anchor names:
    # * top
    # * left
    # * center
    # * bottom
    # * right
    #
    # In addition to positioning properties (left, right, top bottom), the
    # anchors support text rendering properties (text-align, text-baseline).
    # Text is rendered to appear inside the mark by default.
    #
    # To facilitate stacking, anchors are defined in terms of their opposite
    # edge. For example, the top anchor defines the bottom property, 
    # such that the mark extends upwards; the bottom anchor instead defines 
    # the top property, such that the mark extends downwards. See also Layout::Stack
    #
    # While anchor names are typically constants, the anchor name is a true
    # property, which means you can specify a function to compute the anchor name
    # dynamically. See the Anchor#name property for details.
    #
    # @param [String] name the anchor name; either a string or a property function.
    # @return [Anchor] the new anchor.
    def anchor(name='center')
      mark_anchor(name)
    end
    # Implementation of mark anchor
    def mark_anchor(name="center") # :nodoc:
      anchor=Rubyvis::Anchor.
        new(self).
        name(name).
        data(lambda {
          pp self.scene.target if $DEBUG
          a=self.scene.target.map {|s| puts "s:#{s.data}" if $DEBUG; s.data}
          p a if $DEBUG
          a 
        }).visible(lambda {
          
          self.scene.target[index].visible
        }).id(lambda {
            self.scene.target[index].id
        }).
        left(lambda {
          s = self.scene.target[index]
          w = s.width
          w||=0
          if ['bottom','top','center'].include?(self.name)
            s.left + w / 2.0
          elsif self.name=='left'
            nil
          else
            s.left + w
          end
        }).
        top(lambda {
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
      anchor
    end


    # Computes the implied properties for this mark for the specified
    # instance <tt>s</tt> in the scene graph. Implied properties are those with
    # dependencies on multiple other properties; for example, the width property
    # may be implied if the left and right properties are set. This method can be
    # overridden by concrete mark types to define new implied properties, if
    # necessary.
    #
    # @param s a node in the scene graph; the instance of the mark to build.
    def build_implied(s) # :nodoc:
      mark_build_implied(s)
    end
    
    def mark_build_implied(s) # :nodoc:
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
      
      height=self.parent ? self.parent.height(): (h+(t.nil? ? 0 : t )+(b.nil? ? 0 : b))
      
      puts "build implied #{type}: l:#{l},r:#{r},t:#{t},b:#{b}, w:#{prop[:width]} #{w},h: #{prop[:height]} #{h}, width:#{width}, height:#{height}" if $DEBUG
      
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

      puts "Post->left: #{l},right:#{r},top:#{t},bottom:#{b}, width:#{w}, height:#{h}\n\n" if $DEBUG
      s.width  = w if prop[:width]
      s.height = h if prop[:height]
      s.text_style=Rubyvis::Color.transparent if prop[:text_style] and !s.text_style
      s.fill_style=Rubyvis::Color.transparent if prop[:fill_style] and !s.fill_style
      s.stroke_style=Rubyvis::Color.transparent if prop[:stroke_style] and !s.stroke_style
    end
    # Renders this mark, including recursively rendering all child marks if this is
    # a panel. This method finds all instances of this mark and renders them. This
    # method descends recursively to the level of the mark to be rendered, finding
    # all visible instances of the mark. After the marks are rendered, the scene
    # and index attributes are removed from the mark to restore them to a clean
    # state.
    #
    # <p>If an enclosing panel has an index property set (as is the case inside in
    # an event handler), then only instances of this mark inside the given instance
    # of the panel will be rendered; otherwise, all visible instances of the mark
    # will be rendered.
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

      self.context( parent ? parent.scene : nil,
        parent ? parent.index : -1,
        lambda { render_render(root, 0,1) }
        )

    end

    def render_render(mark,depth,scale) # :nodoc:
      mark.scale=scale
      if (depth < @indexes.size)
        @stack.unshift(nil)
        if (mark.index_defined?)
          render_instance(mark, depth, scale);
        else
          mark.scene.size.times {|i|
            mark.index = i;
            render_instance(mark, depth, scale);
          }
          mark.delete_index
        end
        stack.shift
      else
        mark.build
        Rubyvis::SvgScene.scale = scale;
        Rubyvis::SvgScene.update_all(mark.scene);
      end
      mark.scale=nil
    end
    
    
    def render_instance(mark,depth,scale) # :nodoc:
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
    def bind_bind(mark)
      begin
        #puts "Binding:#{mark.type}->#{mark._properties.map {|v| v.name}}"
        
        mark._properties.reverse.each {|v|
          
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
    private :bind_bind, :render_render, :render_instance
    # @private In the bind phase, inherited property definitions are cached so they
    # do not need to be queried during build.
    def bind
      mark_bind
    end
    
    def mark_bind() # :nodoc:
      @seen={}
      @types={1=>[],2=>[],3=>[]}
      @_data=nil
      @_required=[]
      #puts "Binding!"
      bind_bind(self)
      bind_bind((self.class).defaults)
      @types[1].reverse!
      @types[3].reverse!
      #puts "***"
      #pp @types[3]
      #puts "***"
      mark=self
      begin
        properties.each {|name,v|
          if !@seen[name]
            @seen[name]=Property.new(:name=>name, :_type=>2, :value=>nil)
            @types[2].push(@seen[name])
          end
        }
      end while(mark = mark.proto)
      @binds=OpenStruct.new({:properties=>@seen, :data=>@_data, :required=>@_required, :optional=>@types[1]+@types[2]+@types[3]
      })
    end


    def context_apply(scene,index) # :nodoc:
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
    def context_clear(scene,index) # :nodoc:
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
    def context(scene, index, f) # :nodoc:
      #proto=Mark
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

    # Evaluates properties and computes implied properties. Properties are
    # stored in the Mark.scene array for each instance of this mark.
    #
    # As marks are built recursively, the Mark.index property is updated to
    # match the current index into the data array for each mark. Note that the
    # index property is only set for the mark currently being built and its
    # enclosing parent panels. The index property for other marks is unset, but is
    # inherited from the global +Mark+ class prototype. This allows mark
    # properties to refer to properties on other marks <i>in the same panel</i>
    # conveniently; however, in general it is better to reference mark instances
    # specifically through the scene graph rather than depending on the magical
    # behavior of Mark#index.
    #
    # The root scene array has a special property, <tt>data</tt>, which stores
    # the current data stack. The first element in this stack is the current datum,
    # followed by the datum of the enclosing parent panel, and so on. The data
    # stack should not be accessed directly; instead, property functions are passed
    # the current data stack as arguments.
    #
    # <p>The evaluation of the <tt>data</tt> and <tt>visible</tt> properties is
    # special. The <tt>data</tt> property is evaluated first; unlike the other
    # properties, the data stack is from the parent panel, rather than the current
    # mark, since the data is not defined until the data property is evaluated.
    # The <tt>visible</tt> property is subsequently evaluated for each instance;
    # only if true will the {@link #buildInstance} method be called, evaluating
    # other properties and recursively building the scene graph.
    #
    # <p>If this mark is being re-built, any old instances of this mark that no
    # longer exist (because the new data array contains fewer elements) will be
    # cleared using {@link #clearInstance}.
    #
    # @param parent the instance of the parent panel from the scene graph.
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
        Mark.index=i
        self.index=i
        s=scene[i]
        if !s
          scene[i]=s=SceneElement.new
        end
        stack[0]=data[i]
        s.data=data[i]
        build_instance(s)
      }
      Mark.index=-1
      delete_index
      stack.shift()
      self
    end
    # @private
    def build_instance(s) # :nodoc:
      mark_build_instance(s)
    end
    # @private
    def mark_build_instance(s1) # :nodoc:
      build_properties(s1, self.binds.required)
      if s1.visible
        build_properties(s1, self.binds.optional)
        build_implied(s1)
      end
    end
    
    # Evaluates the specified array of properties for the specified
    # instance <tt>s</tt> in the scene graph.
    #
    # @param s a node in the scene graph; the instance of the mark to build.
    # @param properties an array of properties.
    
    def build_properties(ss,props) # :nodoc:
      mark_build_properties(ss,props)
    end
    
    def mark_build_properties(ss, props) # :nodoc:
      #p "#{type}:"+props.map {|prop| prop.name}.join(",")
      props.each do |prop|
        v=prop.value
        # p "#{prop.name}=#{v}"
        if prop._type==3
          v=v.js_apply(self, Mark.stack)
        end
        ss.send((prop.name.to_s+"=").to_sym, v)
      end
    end
    
    # @todo implement
    def event(type,handler) # :nodoc:
      #@_handlers[type]=handler
      self
    end
  end
end

require 'rubyvis/mark/anchor'
require 'rubyvis/mark/bar'
require 'rubyvis/mark/image'
require 'rubyvis/mark/panel'
require 'rubyvis/mark/area'
require 'rubyvis/mark/line'
require 'rubyvis/mark/rule'
require 'rubyvis/mark/label'
require 'rubyvis/mark/dot'
require 'rubyvis/mark/wedge'

