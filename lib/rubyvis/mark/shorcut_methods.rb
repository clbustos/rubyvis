class Rubyvis::Mark
  ##
  # :section: Ruby API
  ##
  
  # Create 
  def self.mark_method(name, mark) #:nodoc:
    define_method(name) do |*args,&block|
      opts=args[0]
      opts||=Hash.new
      if opts[:anchor]
        base=anchor(opts[:anchor])
      else
        base=self
      end
      a=base.add(mark)
      if block
        block.arity<1 ? a.instance_eval(&block) : block.call(a)
      end
    end
  end
  ##
  # :method: area(opts, &block)
  #
  # Adds an Area mark to current mark. 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use
  
  mark_method :area, Rubyvis::Area
  ##
  # :method: bar(opts,&block)
  #
  # Adds a Bar mark to current mark. 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use
  
  mark_method :bar, Rubyvis::Bar
  ##
  # :method: dot(opts,&block)
  #
  # Adds a Dot mark to current mark. 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use  

  mark_method :dot, Rubyvis::Dot
  ##
  # :method: image(opts,&block)
  #
  # Adds an Image mark to current mark. 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  #
  mark_method :image, Rubyvis::Image
  
  ##
  # :method: label(opts,&block)
  #
  # Adds a Label mark to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use  
  
  mark_method :label, Rubyvis::Label
  ##
  # :method: line(opts,&block)
  #
  # Adds a Line mark to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  #
  mark_method :line, Rubyvis::Line
  ##
  # :method: panel(opts,&block)
  #
  # Adds a Panel mark to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  #
  mark_method :panel, Rubyvis::Panel
  ##  
  # :method: rule(opts,&block)
  #
  # Adds a Rule mark to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    

  mark_method :rule, Rubyvis::Rule
  ##
  # :method: wedge(opts,&block)  
  #
  # Adds a Wedge mark to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    

  mark_method :wedge, Rubyvis::Wedge
  ##
  # :method: layout_stack(opts,&block)  
  #
  # Adds a Layout::Stack to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  mark_method :layout_stack, Rubyvis::Layout::Stack
  
  ##
  # :method: layout_partition(opts,&block)  
  #
  # Adds a Layout::Partition to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  mark_method :layout_partition, Rubyvis::Layout::Partition
  
  ##
  # :method: layout_partition_fill(opts,&block)  
  #
  # Adds a Layout::Partition::Fill to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  mark_method :layout_partition_fill, Rubyvis::Layout::Partition::Fill
  
  ##
  # :method: layout_treemap(opts,&block)  
  #
  # Adds a Layout::Treemap to current mark. 
  # 
  # If a block is provided, the context will be defined differently if 
  # parameter is provided
  # * Without parameter: block executed inside context of new mark
  # * With paramenter: block executed inside context of current mark. 
  #   Paramenter references new mark
  # 
  # See Mark for examples of use    
  mark_method :layout_treemap, Rubyvis::Layout::Treemap
  
  
end
