module Protoruby
  module Format
    class Number
      def initialize
        @maxi = Infinity # default maximum integer digits
        @mins = 0 # mini, including group separators
        @minf = 0 # default minimum fraction digits
        @maxf = 0 # default maximum fraction digits
        @maxk = 1 # 10^maxf
        @padi = "0" # default integer pad
        @padf = "0" # default fraction pad
        @padg = true # whether group separator affects integer padding
        @decimal = "." # default decimal separator
        @group = "," # default group separator
        @np = "\u2212" # default negative prefix
        @ns = "" # default negative suffix
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