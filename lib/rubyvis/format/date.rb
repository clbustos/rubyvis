require 'date'
module Rubyvis
  module Format
    class Date
      attr_reader :pattern
      def initialize(pattern)
        @pattern=pattern
        #@pad=Rubyvis::Format.pad
      end
      def format(d)
        d.strftime(pattern)
      end
      def format_lambda
        pat=pattern
        lambda {|d| 
          d.strftime(pat)
        }
      end
      def parse(s)
        time=::DateTime.strptime(s, pattern)
        Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec, 0)
      end
    end
  end
end
