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
      def parse(s)
        ::Time.strptime(s, pattern)
      end
    end
  end
end