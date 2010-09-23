module Protoruby
  module Format
    def self.re(s)
      s.gsub(/[\\\^\$\*\+\?\[\]\(\)\.\{\}]/, "\\$&")
    end
    def self.number
      Format::Number.new
    end
  end
end
require 'protoruby/format/number'