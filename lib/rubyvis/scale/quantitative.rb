module Rubyvis
  class Scale::Quantitative
    include Rubyvis::Scale
    attr_reader :l
    def initialize(*args)
      @d=[0,1] # domain
      @l=[0,1] # transformed domain
      @r=[0,1] # default range
      @i=[Rubyvis.identity] # default interpolator
      @type=:to_f # default type
      @n=false
      @f=Rubyvis.identity # default forward transformation
      @g=Rubyvis.identity
      @tick_format=lambda {|x| x.to_f}
      domain(*args)
    end
    def new_date(x=nil)
      x.nil? ? Time.new() : Time.at(x)
    end
  
    def scale(x)
      x=x.to_f
      j=Rubyvis.search(@d, x)
      j=-j-2 if (j<0)
      j=[0,[@i.size-1,j].min].max
      # p @l
      # puts "Primero #{j}: #{@f.call(x) - @l[j]}"
      # puts "Segundo #{(@l[j + 1] - @l[j])}"
      @i[j].call((@f.call(x) - @l[j]) .quo(@l[j + 1] - @l[j]));
    end
    def [](x)
      scale(x)
    end
    def transform(forward, inverse)
      @f=lambda {|x| @n ? -forward.call(-x) : forward.call(x); }
      @g=lambda {|y| @n ? -inverse.call(-y) : inverse.call(y); }
      @l=@d.map{|v| @f.call(v)}
      self
    end
    
    
    def domain(*arguments)
      array,min,max=arguments
      o=nil
      if (arguments.size>0)
        if array.is_a? Array 
          min = pv.identity if (arguments.size < 2)
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
    def ticks_floor(d,prec)
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
    
    def to_date(d)
      
      Time.utc(*d)
    end
    # TODO: FIX this func
    def ticks(*arguments) 
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
      # From here, ¡chaos!
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
      
      @tick_format = pv.Format.date(format);
      date = Time.at(min.to_f)
      dates = []
      date = ticks_floor(date,precision)
      # If we'd generate too many ticks, skip some!.
      n = span / (precision/1000.0)
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
          step = pv.logCeil(n / 15, 10);
          if (n / step < 2) 
            step =step.quo(5)
          elsif (n / step < 5)
            step = step.quo(2)
          end
          date.setFullYear((date.getFullYear().quo(step)).floor * step);
        end
      end
      
        while (true)
          date=increment.call(date)
          break if (date.to_f > max.to_f)
          dates.push(date)
        end
        return reverse ? dates.reverse() : dates;
      end
      
      # Normal case: numbers. 
      m = 10 if (arguments.size==0)
      
      step = pv.log_floor(span.quo(m), 10)
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
      @tick_format= pv.Format.number().fraction_digits([0, -(pv.log(step, 10) + 0.01).floor].max);
      ticks = pv.range(start, _end + step, step);
      return reverse ? ticks.reverse() : ticks;
    end
    def nice
      if (@d.size!=2)
        return self;
      end
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
    end
  end
end