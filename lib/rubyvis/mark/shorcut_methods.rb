class Rubyvis::Mark
  ##
  # :section: Ruby API
  ##
  
  # Create 
  def self.mark_method(name,mark) #:nodoc:
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
  # :method: area(opts,&block)
  #
  mark_method :area, Rubyvis::Area
  ##
  # :method: bar(opts,&block)
  #
  mark_method :bar, Rubyvis::Bar
  ##
  # :method: dot(opts,&block)
  #
  mark_method :dot, Rubyvis::Dot
  ##
  # :method: _image(opts,&block)
  #
  mark_method :_image, Rubyvis::Image
  ##
  # :method: label(opts,&block)
  #
  mark_method :label, Rubyvis::Label
  ##
  # :method: line(opts,&block)
  #
  mark_method :line, Rubyvis::Line
  ##
  # :method: panel(opts,&block)
  #
  mark_method :panel, Rubyvis::Panel
  ##
  # :method: rule(opts,&block)
  #    
  mark_method :rule, Rubyvis::Rule
  ##
  # :method: wedge(opts,&block)
  #    
  mark_method :wedge, Rubyvis::Rule
end
