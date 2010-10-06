module Rubyvis
  module Format
    class Number
      def initialize
        @mini = 0
        @maxi = Infinity # default maximum integer digits
        @mins = 0.0 # mini, including group separators
        @minf = 0.0 # default minimum fraction digits
        @maxf = 0.0 # default maximum fraction digits
        @maxk = 1 # 10^maxf
        @padi = "0" # default integer pad
        @padf = "0" # default fraction pad
        @padg = true # whether group separator affects integer padding
        @decimal = "." # default decimal separator
        @group = "," # default group separator
        @np = "\u2212" # default negative prefix
        @ns = "" # default negative suffix
      end
      
      
      def to_proc
        that=self
        lambda {|*args|  args[0] ? that.format(args[0]) : nil }
      end
      #/** @private */
      def format(x) 
      # /* Round the fractional part, and split on decimal separator. */
      x = (x * @maxk).round / @maxk if (Infinity > @maxf)
      s = x.abs.to_s.split(".")
      
      #/* Pad, truncate and group the integral part. */
      i = s[0]
      
      i = i[i.size-@maxi, i.size] if (i.size > @maxi) 
      if (@padg and (i.size < @mini))
        i = Array.new(@mini - i.size + 1).join(@padi) + i.to_s
      end
      
      if (i.size > 3)
        i = i.gsub(/\B(?=(?:\d{3})+(?!\d))/, @group)
      end
      
      if (@padg=="" and (i.size < @mins))
        i = Array.new(mins - i.size + 1).join(@padi) + i.to_s
      end
      
      s[0] = x < 0 ? np + i + ns : i;
      
      #/* Pad the fractional part. */
      f = s[1].nil? ? "" : s[1]
      if (f.size < @minf)
        s[1] = f + Array.new(@minf - f.size + 1).join(@padf)
      end
      
      return s.join(@decimal)
      end

      
      
      def fraction_digits(*arguments)
        if (arguments.size>0)
          min=arguments[0]
          max=arguments[1]
          @minf = min.to_f
          @maxf = (arguments.size > 1) ? max.to_f : @minf
          @maxk = 10**@maxf
          return self
        end
        [minf, maxf]
      end
    end
  end
end
