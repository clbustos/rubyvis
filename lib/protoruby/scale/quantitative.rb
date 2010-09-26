module Protoruby
  class Scale::Quantitative
    include Protoruby::Scale
    attr_reader :l
      def initialize(*args)
        @d=[0,1] # domain
        @l=[0,1] # transformed domain
        @r=[0,1] # default range
        @i=[Protoruby.identity] # default interpolator
        @type=:to_f # default type
        @n=false
        @f=Protoruby.identity # default forward transformation
        @g=Protoruby.identity
        @tick_format=:to_s
        domain(*args)
      end
      def new_date(x=nil)
        if x.nil?
          Date.new
        else
          Date.new(x)
        end
      end

      def scale(x)
        j=Protoruby.search(@d,x)
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
        if (arguments.size>0)
          if array.is_a? Array 
            min = pv.identity if (arguments.size < 2)
            max = min if (arguments.size < 3)
            o = array.size && [array[0]].min
            @d = array.size ? [Protoruby.min(array, min), Protoruby.max(array, max)] : [];
          else 
            o = array;
            @d = arguments.map {|i| i.to_f}
          end
          if !@d.size 
            @d = [-Infinity, Infinity];
          elsif (@d.size == 1) 
            @d = [@d.first, @d.first]
          end
          @n = (@d.first<0 or @d.last<0)
          @l=@d.map{|v| @f.call(v)}
          @type = (o.is_a? Date) ? newDate : :to_f;
          return self
        end
        # TODO: Fix this.
        @d.map{|v| 
          case @type
          when :to_f
            v.to_f
          when :to_date
            Date.new(v)
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
            interpolator(@r[j], @r[j + 1]);
          end
          return self
        end
        @r
      end
      
      def invert(y)
        j=Protoruby.search(@r, y)
        j=-j-2 if j<0
        j = [0, [@i.size - 1, j].min].max
        
        @g.call(@l[j] + (y - @r[j]).quo(@r[j + 1] - @r[j]) * (@l[j + 1] - @l[j]));
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
          @tick_format= Protoruby.Format.date("%x") if (@type == newDate) 
          return [type(min)];
        end
        
        #/* Special case: dates. */
        if (@type == new_date) 
        #/* Floor the date d given the precision p. */
        lambda  do |d,p|
        case(p) 
        when 31536e6
          d.setMonth(0);
        when 2592e6
          d.setDate(1);
        when 6048e5
          if (p == 6048e5) 
            d.setDate(d.getDate() - d.getDay());
          end
        when 864e5
          d.setHours(0);
        when 36e5
          d.setMinutes(0);
        when 6e4
          d.setSeconds(0);
        when 1e3
          d.setMilliseconds(0);
        end
        end
        
        precision, format, increment, step = 1,1,1,1
        if (span >= 3 * 31536e6) 
        precision = 31536e6;
        format = "%Y";
        increment = lambda {|d| d.setFullYear(d.getFullYear() + step); };
        elsif (span >= 3 * 2592e6) 
        precision = 2592e6;
        format = "%m/%Y";
        increment = lambda {|d| d.setMonth(d.getMonth() + step); };
        elsif (span >= 3 * 6048e5) 
        precision = 6048e5;
        format = "%m/%d";
        increment = lambda {|d| d.setDate(d.getDate() + 7 * step); };
        elsif (span >= 3 * 864e5) 
        precision = 864e5;
        format = "%m/%d";
        increment = lambda {|d| d.setDate(d.getDate() + step); };
        elsif (span >= 3 * 36e5) 
        precision = 36e5;
        format = "%I:%M %p";
        increment = lambda {|d| d.setHours(d.getHours() + step); };
        elsif (span >= 3 * 6e4) 
        precision = 6e4;
        format = "%I:%M %p";
        increment = lambda {|d| d.setMinutes(d.getMinutes() + step); };
        elsif (span >= 3 * 1e3) 
        precision = 1e3;
        format = "%I:%M:%S";
        increment = lambda {|d|  d.setSeconds(d.getSeconds() + step); };
        else 
        precision = 1;
        format = "%S.%Qs";
        increment = lambda {|d|  d.setTime(d.getTime() + step); };
        end
        @tick_format = pv.Format.date(format);
        
        date = Date.new(min)
        dates = []
        #floor(date, precision);
        
        # If we'd generate too many ticks, skip some!.
        n = span.quo(precision)
        if (n > 10) 
        case (precision) 
        when 36e5
          step = (n > 20) ? 6 : 3;
          date.setHours(Math.floor(date.getHours() / step) * step);
        when 2592e6
          step = 3; # seasons
          date.setMonth(Math.floor(date.getMonth() / step) * step);
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
        increment(date);
        break if (date > max)
        dates.push(Date.new(date));
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
      def tick_format(t)
        t.send(@tick_format)
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