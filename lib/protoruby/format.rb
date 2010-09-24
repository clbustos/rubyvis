module Protoruby
  module Format
    def self.re(s)
      s.gsub(/[\\\^\$\*\+\?\[\]\(\)\.\{\}]/, "\\$&")
    end
    def self.number
      Format::Number.new
    end
    def self.date(pattern)
      Format::Date.new(pattern)
    end
  end
end
require 'protoruby/format/number'
require 'protoruby/format/date'