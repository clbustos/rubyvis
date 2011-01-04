module Rubyvis
  # Represents an abstract quantitative scale; a function that performs a
  # numeric transformation. This class is typically not used directly; see one of
  # the quantitative scale implementations (linear, log, root, etc.)
  # instead. <style type="text/css">sub{line-height:0}</style> A quantitative
  # scale represents a 1-dimensional transformation from a numeric domain of
  # input data [<i>d<sub>0</sub></i>, <i>d<sub>1</sub></i>] to a numeric range of
  # pixels [<i>r<sub>0</sub></i>, <i>r<sub>1</sub></i>]. In addition to
  # readability, scales offer several useful features:
  #
  # <p>1. The range can be expressed in colors, rather than pixels. For example:
  #
  #   .fill_style(Scale.linear(0, 100).range("red", "green"))
  #
  # will fill the marks "red" on an input value of 0, "green" on an input value
  # of 100, and some color in-between for intermediate values.
  #
  # <p>2. The domain and range can be subdivided for a non-uniform
  # transformation. For example, you may want a diverging color scale that is
  # increasingly red for negative values, and increasingly green for positive
  # values:
  #
  #   .fill_style(Scale.linear(-1, 0, 1).range("red", "white", "green"))</pre>
  #
  # The domain can be specified as a series of <i>n</i> monotonically-increasing
  # values; the range must also be specified as <i>n</i> values, resulting in
  # <i>n - 1</i> contiguous linear scales.
  #
  # <p>3. Quantitative scales can be inverted for interaction. The
  # invert() method takes a value in the output range, and returns the
  # corresponding value in the input domain. This is frequently used to convert
  # the mouse location (see Mark#mouse) to a value in the input
  # domain. Note that inversion is only supported for numeric ranges, and not
  # colors.
  #
  # <p>4. A scale can be queried for reasonable "tick" values. The ticks()
  # method provides a convenient way to get a series of evenly-spaced rounded
  # values in the input domain. Frequently these are used in conjunction with
  # Rule to display tick marks or grid lines.
  #
  # <p>5. A scale can be "niced" to extend the domain to suitable rounded
  # numbers. If the minimum and maximum of the domain are messy because they are
  # derived from data, you can use nice() to round these values down and
  # up to even numbers.
  #
  # @see Scale.linear
  # @see Scale.log
  # @see Scale.root
  class Scale::Quantitative
    include Rubyvis::Scale
    attr_reader :l
    # Returns a default quantitative, linear, scale for the specified domain. The
    # arguments to this constructor are optional, and equivalent to calling
    # domain. The default domain and range are [0,1].
    #
    # This constructor is typically not used directly; see one of the
    # quantitative scale implementations instead.
    # @param {number...} domain... optional domain values.
    def initialize(*args)
      @d=[0,1] # domain
      @l=[0,1] # transformed domain
      @r=[0,1] # default range
      @i=[Rubyvis.identity] # default interpolator
      @type=:to_f # default type
      @n=false
      @f=Rubyvis.identity # default forward transformation
      @g=Rubyvis.identity
      @tick_format=lambda {|x|
        if x.is_a? Numeric
          ((x.to_f-x.to_i==0) ? x.to_i : x.to_f).to_s
        else
          ""
        end
      }
      domain(*args)
    end
    
    # Deprecated
    def new_date(x=nil) # :nodoc:
      x.nil? ? Time.new() : Time.at(x)
    end
    # Return 
    #   lambda {|d| scale_object.scale(d)}
    # Useful as value on dynamic properties
    #   scale=Rubyvis.linear(0,1000)
    #   bar.width(scale)
    # is the same as
    #   bar.width(lambda {|x| scale.scale(x)})
    def to_proc
      that=self
      lambda {|*args|  args[0] ? that.scale(args[0]) : nil }
    end
    # Transform value +x+ according to domain and range
    def scale(x)
      return nil if x.nil?
      x=x.to_f
      j=Rubyvis.search(@d, x)
      j=-j-2 if (j<0)
      j=[0,[@i.size-1,j].min].max
      # p @l
      # puts "Primero #{j}: #{@f.call(x) - @l[j]}"
      # puts "Segundo #{(@l[j + 1] - @l[j])}"
      @i[j].call((@f.call(x) - @l[j]) .quo(@l[j + 1] - @l[j]));
    end
    alias :[] :scale      
    def transform(forward, inverse)
      @f=lambda {|x| @n ? -forward.call(-x) : forward.call(x); }
      @g=lambda {|y| @n ? -inverse.call(-y) : inverse.call(y); }
      @l=@d.map{|v| @f.call(v)}
      self
    end
    private :transform
    # Sets or gets the input domain. This method can be invoked several ways:
    #
    # <p>1. <tt>domain(min, ..., max)</tt>
    #
    # <p>Specifying the domain as a series of numbers is the most explicit and
    # recommended approach. Most commonly, two numbers are specified: the minimum
    # and maximum value. However, for a diverging scale, or other subdivided
    # non-uniform scales, multiple values can be specified. Values can be derived
    # from data using Rubyvis.min and Rubyvis.max. For example:
    #
    #   .domain(0, Rubyvis.max(array))
    #
    # An alternative method for deriving minimum and maximum values from data
    # follows.
    #
    # <p>2. <tt>domain(array, minf, maxf)</tt>
    #
    # <p>When both the minimum and maximum value are derived from data, the
    # arguments to the <tt>domain</tt> method can be specified as the array of
    # data, followed by zero, one or two accessor functions. For example, if the
    # array of data is just an array of numbers:
    #
    #   .domain(array)
    #
    # On the other hand, if the array elements are objects representing stock
    # values per day, and the domain should consider the stock's daily low and
    # daily high:
    #
    #   .domain(array, lambda {|d|  d.low}, lambda {|d| d.high})
    #
    # The first method of setting the domain is preferred because it is more
    # explicit; setting the domain using this second method should be used only
    # if brevity is required.
    #
    # <p>3. <tt>domain()</tt>
    #
    # <p>Invoking the <tt>domain</tt> method with no arguments returns the
    # current domain as an array of numbers.
    def domain(*arguments)
      array,min,max=arguments
      o=nil
      if (arguments.size>0)
        if array.is_a? Array 
          min = Rubyvis.identity if (arguments.size < 2)
          max = min if (arguments.size < 3)
          o = [array[0]].min if array.size>0
          @d = array.size>0 ? [Rubyvis.min(array, min), Rubyvis.max(array, max)] : []
        else 
          o = array
          @d = arguments.map {|i| i.to_f}
        end
        
        if !@d.size 
          @d = [-Infinity, Infinity];
        elsif (@d.size == 1) 
          @d = [@d.first, @d.first]
        end
        
        @n = (@d.first.to_f<0 or @d.last.to_f<0)
        @l=@d.map{|v| @f.call(v)}
        
        @type = (o.is_a? Time) ? :time : :number;
        return self
      end
      # TODO: Fix this.
      @d.map{|v| 
        case @type
        when :number
          v.to_f
        when :time
          Time.at(v)
        else 
          v
        end
      }
    end
    
    # Sets or gets the output range. This method can be invoked several ways:
    #
    # <p>1. <tt>range(min, ..., max)</tt>
    #
    # <p>The range may be specified as a series of numbers or colors. Most
    # commonly, two numbers are specified: the minimum and maximum pixel values.
    # For a color scale, values may be specified as {@link Rubyvis.Color}s or
    # equivalent strings. For a diverging scale, or other subdivided non-uniform
    # scales, multiple values can be specified. For example:
    #
    #   .range("red", "white", "green")
    #
    # <p>Currently, only numbers and colors are supported as range values. The
    # number of range values must exactly match the number of domain values, or
    # the behavior of the scale is undefined.
    #
    # <p>2. <tt>range()</tt>
    #
    # <p>Invoking the <tt>range</tt> method with no arguments returns the current
    # range as an array of numbers or colors.
    # :call-seq:
    #   range(min,...,max)
    #   range()
    def range(*arguments)
      if (arguments.size>0) 
        @r = arguments.dup
        if (@r.size==0)
          @r = [-Infinity, Infinity];
        elsif (@r.size == 1)
          @r = [@r[0], @r[0]]
        end
        @i=(@r.size-1).times.map do |j|
          Rubyvis::Scale.interpolator(@r[j], @r[j + 1]);
        end
        return self
      end
      @r
    end
    
    def invert(y)
      j=Rubyvis.search(@r, y)
      j=-j-2 if j<0
      j = [0, [@i.size - 1, j].min].max
      
      val=@g.call(@l[j] + (y - @r[j]).quo(@r[j + 1] - @r[j]) * (@l[j + 1] - @l[j]))
      @type==:time ? Time.at(val) : val
    end
    
    def type(v=nil)
      return @type if v.nil?
      case @type
        when Numeric
          v.to_f
        when Date
          raise "Not implemented yet"
      end
    end
    def ticks_floor(d,prec) # :nodoc:
      ar=d.to_a
      #p ar
      # [ sec, min, hour, day, month, year, wday, yday, isdst, zone ]
      case(prec) 
        when 31536e6
          ar[4]=1
        when 2592e6
          ar[3]=1
        when 6048e5
          ar[3]=ar[3]-ar[6] if (prec == 6048e5)
        when 864e5
          ar[2]=0
        when 36e5
          ar[1]=0
        when 6e4
          ar[0]=0
        when 1e3
          # do nothing
      end
      to_date(ar)
    end
    
    private :ticks_floor
    
    def to_date(d) # :nodoc:
      
      Time.utc(*d)
    end
    # Returns an array of evenly-spaced, suitably-rounded values in the input
    # domain. This method attempts to return between 5 and 10 tick values. These
    # values are frequently used in conjunction with Rule to display
    # tick marks or grid lines.
    #
    # @todo: fix for dates and n>10
    def ticks(*arguments) # :args: (number_of_ticks=nil)
      m = arguments[0]
      start = @d.first
      _end = @d.last
      reverse = _end < start
      min = reverse ? _end : start
      max = reverse ? start : _end
      span = max - min
      # Special case: empty, invalid or infinite span.
      if (!span or (span.is_a? Float and span.infinite?)) 
        @tick_format= Rubyvis.Format.date("%x") if (@type == newDate) 
        return [type(min)];
      end
      
      #/* Special case: dates. */
      if (@type == :time) 
      #/* Floor the date d given the precision p. */
      precision, format, increment, step = 1,1,1,1
      if (span >= 3 * 31536e6 / 1000.0) 
        precision = 31536e6
        format = "%Y"
        increment = lambda {|d|  Time.at(d.to_f+(step*365*24*60*60)) }
      elsif (span >= 3 * 2592e6 / 1000.0) 
        precision = 2592e6;
        format = "%m/%Y";
        increment = lambda {|d| Time.at(d.to_f+(step*30*24*60*60)) }
      elsif (span >= 3 * 6048e5 / 1000.0) 
        precision = 6048e5;
        format = "%m/%d";
        increment = lambda {|d| Time.at(d.to_f+(step*7*24*60*60)) }
      elsif (span >= 3 * 864e5 / 1000.0) 
        precision = 864e5;
        format = "%m/%d";
        increment = lambda {|d| Time.at(d.to_f+(step*24*60*60)) }
      elsif (span >= 3 * 36e5 / 1000.0) 
        precision = 36e5;
        format = "%I:%M %p";
        increment = lambda {|d| Time.at(d.to_f+(step*60*60)) }
      elsif (span >= 3 * 6e4 / 1000.0 ) 
        precision = 6e4;
        format = "%I:%M %p";
        increment = lambda {|d| Time.at(d.to_f+(step*60)) }
      elsif (span >= 3 * 1e3 / 1000.0) 
        precision = 1e3;
        format = "%I:%M:%S";
        increment = lambda {|d|  Time.at(d.to_f+(step)) }
      else 
        precision = 1;
        format = "%S.%Qs";
        increment = lambda {|d|  Time.at(d.to_f+(step/1000.0)) }
      end
      
      @tick_format = Rubyvis.Format.date(format);
      date = Time.at(min.to_f)
      dates = []
      date = ticks_floor(date,precision)
      # If we'd generate too many ticks, skip some!.
      n = span / (precision/1000.0)
      # FIX FROM HERE
      if (n > 10) 
        case (precision) 
        when 36e5
          step = (n > 20) ? 6 : 3;
          date.setHours(Math.floor(date.getHours() / step) * step);
        when 2592e6
          step = 3; # seasons
          ar=date.to_a
          ar[4]=(date.month/step.to_f).floor*step
          date=to_date(ar)
        when 6e4
          step = (n > 30) ? 15 : ((n > 15) ? 10 : 5);
          date.setMinutes(Math.floor(date.getMinutes() / step) * step);
        when 1e3
          step = (n > 90) ? 15 : ((n > 60) ? 10 : 5);
          date.setSeconds(Math.floor(date.getSeconds() / step) * step);
        when 1
          step = (n > 1000) ? 250 : ((n > 200) ? 100 : ((n > 100) ? 50 : ((n > 50) ? 25 : 5)));
          date.setMilliseconds(Math.floor(date.getMilliseconds() / step) * step);
        else
          step = Rubyvis.logCeil(n / 15, 10);
          if (n / step < 2) 
            step =step.quo(5)
          elsif (n / step < 5)
            step = step.quo(2)
          end
          date.setFullYear((date.getFullYear().quo(step)).floor * step);
        end
      end
      # END FIX
        while (true)
          date=increment.call(date)
          break if (date.to_f > max.to_f)
          dates.push(date)
        end
        return reverse ? dates.reverse() : dates;
      end
      
      # Normal case: numbers. 
      m = 10 if (arguments.size==0)
      
      step = Rubyvis.log_floor(span.quo(m), 10)
      err = m.quo(span.quo(step))
      if (err <= 0.15)
      step = step*10
      elsif (err <= 0.35)
      step = step*5
      elsif (err <= 0.75)
      step = step*2
      end
      start = (min.quo(step)).ceil * step
      _end = (max.quo(step)).floor * step
      
      @tick_format= Rubyvis.Format.number.fraction_digits([0, -(Rubyvis.log(step, 10) + 0.01).floor].max).to_proc
      
      ticks = Rubyvis.range(start, _end + step, step)
      
      return reverse ? ticks.reverse() : ticks;
    end
    
    # Returns a Proc that formats the specified tick value using the appropriate precision, based on
    # the step interval between tick marks. If ticks() has not been called,
    # the argument is converted to a string, but no formatting is applied.
    #   scale.tick_format.call(value)
    #
    def tick_format
      @tick_format
    end
    
    # "Nices" this scale, extending the bounds of the input domain to
    # evenly-rounded values. Nicing is useful if the domain is computed
    # dynamically from data, and may be irregular. For example, given a domain of
    # [0.20147987687960267, 0.996679553296417], a call to <tt>nice()</tt> might
    # extend the domain to [0.2, 1].
    #
    # This method must be invoked each time after setting the domain.
    def nice
      return self if @d.size!=2
      start=@d.first
      _end=@d[@d.size-1]
      reverse=_end<start
      min=reverse ? _end : start
      max = reverse ? start : _end
      span=max-min
      
      return self if(!span or span.infinite?)
      
      step=10**((Math::log(span).quo(Math::log(10))).round-1)
      @d=[(min.quo(step)).floor*step, (max.quo(step)).ceil*step]
      @d.reverse if  reverse
      @l=@d.map {|v| @f.call(v)}
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