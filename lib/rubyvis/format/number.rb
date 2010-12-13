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
        x = (x * @maxk).round.quo(@maxk) if (Infinity > @maxf)
        x = (x.to_f-x.to_i==0) ? x.to_i : x.to_f
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
        
        s[0] = x < 0 ? @np + i + @ns : i
        
        #/* Pad the fractional part. */
        f = s[1].nil? ? "" : s[1]
        if (f.size < @minf)
          s[1] = f + Array.new(@minf - f.size + 1).join(@padf)
        end
        s.join(@decimal)
      end

      # Sets or gets the minimum and maximum number of fraction digits. The
      # controls the number of decimal digits to display after the decimal
      # separator for the fractional part of the number. 
      # If the number of digits is smaller than the minimum, the digits 
      # are padded; if the number of digits is
      # larger, the fractional part is rounded, showing only the higher-order
      # digits. The default range is [0, 0].
      #
      # If only one argument is specified to this method, this value is used as
      # both the minimum and maximum number. If no arguments are specified, a
      # two-element array is returned containing the minimum and the maximum.
      #
      # @function
      # @name Rubyvis.Format.number.prototype.fractionDigits
      # @param {number} [min] the minimum fraction digits.
      # @param {number} [max] the maximum fraction digits.
      # @returns {Rubyvis.Format.number} <tt>this</tt>, or the current fraction digits.
      
      def fraction_digits(min=nil,max=nil)
        if (!min.nil?)
          max||=min
          @minf = min
          @maxf = max
          @maxk = 10**@maxf
          return self
        end
        [@minf, @maxf]
      end
      
      
      def integer_digits(min=nil,max=nil)
        if (!min.nil?)
          max||=min
          @mini=min
          @maxi=max
          @mins=@mini+(@mini/3.0).floor*@group.size 
          return self
        end
        [@mini, @maxi]
      end
    end
  end
end
