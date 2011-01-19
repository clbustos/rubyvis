module Rubyvis
  # Represents an ordinal scale. <style
  # type="text/css">sub{line-height:0}</style> An ordinal scale represents a
  # pairwise mapping from <i>n</i> discrete values in the input domain to
  # <i>n</i> discrete values in the output range. For example, an ordinal scale
  # might map a domain of species ["setosa", "versicolor", "virginica"] to colors
  # ["red", "green", "blue"]. Thus, saying
  #
  #   .fill_style(lambda {|d|
  #         case (d.species)
  #           when "setosa"
  #             "red"
  #           when "versicolor"
  #             "green"
  #           when "virginica"
  #             "blue"
  #         }
  #       )
  #
  # is equivalent to
  #
  #   .fill_style(Rubyvis::Scale.ordinal("setosa", "versicolor", "virginica")
  #         .range("red", "green", "blue")
  #         .by(lambda {|d| d.species}))</pre>
  #
  # If the mapping from species to color does not need to be specified
  # explicitly, the domain can be omitted. In this case it will be inferred
  # lazily from the data:
  #
  #   .fill_style(Rubyvis.colors("red", "green", "blue")
  #         .by(lambda {|d| d.species}))</pre>
  #
  # When the domain is inferred, the first time the scale is invoked, the first
  # element from the range will be returned. Subsequent calls with unique values
  # will return subsequent elements from the range. If the inferred domain grows
  # larger than the range, range values will be reused. However, it is strongly
  # recommended that the domain and the range contain the same number of
  # elements.
  #
  # A range can be discretized from a continuous interval (e.g., for pixel
  # positioning) by using split, split_flush or
  # split_banded after the domain has been set. For example, if
  # <tt>states</tt> is an array of the fifty U.S. state names, the state name can
  # be encoded in the left position:
  #
  #   .left(Rubyvis::Scale.ordinal(states)
  #         .split(0, 640)
  #         .by(lambda {|d| d.state}))
  #
  # N.B.: ordinal scales are not invertible (at least not yet), since the
  # domain and range and discontinuous. A workaround is to use a linear scale.
  class Scale::Ordinal
    # range band, after use split_banded
    # equivalen to protovis scale.range().band
    attr_reader :range_band
    # Returns an ordinal scale for the specified domain. The arguments to this
    # constructor are optional, and equivalent to calling domain    
    def initialize(*args)
      @d=[] # domain
      @i={}
      @r=[]
      @range_band=nil
      @band=0
      domain(*args)
    end
    
    # Return 
    #   lambda {|d| scale_object.scale(d)}
    # Useful as value on dynamic properties
    #   scale=Rubyvis.ordinal("red","blue","green")
    #   bar.fill_style(scale)
    # is the same as
    #   bar.fill_style(lambda {|x| scale.scale(x)})
    def to_proc
      that=self
      lambda {|*args| args[0] ? that.scale(args[0]) : nil }
    end
    def scale(x)
      if @i[x].nil?
        @d.push(x)
        @i[x]=@d.size-1
      end
      @r[@i[x] % @r.size]
    end
    alias :[] :scale      
    # Sets or gets the input domain. This method can be invoked several ways:
    #
    # <p>1. <tt>domain(values...)</tt>
    #
    # <p>Specifying the domain as a series of values is the most explicit and
    # recommended approach. However, if the domain values are derived from data,
    # you may find the second method more appropriate.
    #
    # <p>2. <tt>domain(array, f)</tt>
    #
    # <p>Rather than enumerating the domain values as explicit arguments to this
    # method, you can specify a single argument of an array. In addition, you can
    # specify an optional accessor function to extract the domain values from the
    # array.
    #
    # <p>3. <tt>domain()</tt>
    #
    # <p>Invoking the <tt>domain</tt> method with no arguments returns the
    # current domain as an array.
    def domain(*arguments)
      array, f=arguments[0],arguments[1]
      if(arguments.size>0)
      array= (array.is_a? Array) ? ((arguments.size>1) ? Rubyvis.map(array,f) : array) : arguments.dup
        @d=array.uniq
        @i=Rubyvis.numerate(@d)
        return self
      end
      @d
    end
    
    # Sets the range from the given continuous interval. The interval [<i>
    # min</i>, <i>max</i>] is subdivided into <i>n</i> equispaced bands,
    # where <i>n</i> is the number of (unique) values in the domain. The first
    # and last band are offset from the edge of the range by the distance between bands.
    # 
    # <p>The band width argument, <tt>band</tt>, is typically in the range [0, 1]
    # and defaults to 1. This fraction corresponds to the amount of space in the
    # range to allocate to the bands, as opposed to padding. A value of 0.5
    # means  that the band width will be equal to the padding width. 
    # The computed  absolute band width can be retrieved from the range as
    # <tt>scale.range_band</tt>.
    #
    # <p>If the band width argument is negative, this method will allocate bands
    # of a <i>fixed</i> width <tt>-band</tt>, rather than a relative fraction of
    # the available space.
    #
    # <p>Tip: to inset the bands by a fixed amount <tt>p</tt>, specify a minimum
    # value of <tt>min + p</tt> (or simply <tt>p</tt>, if <tt>min</tt> is
    # 0). Then set the mark width to <tt>scale.range_band - p</tt>.
    #
    # <p>This method must be called <i>after</i> the domain is set.
    
    def split_banded(*arguments) # :args: (min,max,band=1)
      min,max,band=arguments
      band=1 if (arguments.size < 3)
      if (band < 0) 
        
        n = self.domain().size
        total = -band * n
        remaining = max - min - total
        padding = remaining / (n + 1).to_f
        @r = Rubyvis.range(min + padding, max, padding - band);
        @range_band = -band;
      else
        step = (max - min) / (self.domain().size + (1 - band))
        @r = Rubyvis.range(min + step * (1 - band), max, step);
        @range_band = step * band;
      end
      return self
    end
    def range(*arguments)
      array, f = arguments[0],arguments[1]
      if(arguments.size>0)
        @r=(array.is_a? Array) ? ((arguments.size>1) ? array.map(&f) : array) : arguments.dup
        if @r[0].is_a? String
          @r=@r.map {|i| Rubyvis.color(i)}
        end
        return self
      end
      @r
    end
    
    # Sets the range from the given continuous interval. The interval [<i>
    # min</i>, <i>max</i>] is subdivided into <i>n</i> equispaced points,
    # where <i>n</i> is the number of (unique) values in the domain. The first
    # and last point are offset from the edge of the range by half the distance
    # between points.
    #
    # <p>This method must be called <i>after</i> the domain is set.
    def split(min,max)
      step=(max-min).quo(domain().size)
      @r=Rubyvis.range(min+step.quo(2),max,step)
      self
    end
    
    # Sets the range from the given continuous interval. The interval
    # [<i>min</i>, <i>max</i>] is subdivided into <i>n</i> equispaced points,
    # where <i>n</i> is the number of (unique) values in the domain. The first
    # and last point are exactly on the edge of the range.
    #
    # <p>This method must be called <i>after</i> the domain is set.
    #
    # * @param {number} min minimum value of the output range.
    # * @param {number} max maximum value of the output range.
    # * @returns {pv.Scale.ordinal} <tt>this</tt>.
    # * @see Ordinal.split
    
    def split_flush(min,max)
      n = self.domain().size
      step = (max - min) / (n - 1).to_f
      @r = (n == 1) ? [(min + max) / 2.0] : Rubyvis.range(min, max + step/2.0, step)
      self
    end
    def by(f)
      that=self
      lambda {|*args|
        that.scale(f.js_apply(self,args))
      }
    end
  end
end
