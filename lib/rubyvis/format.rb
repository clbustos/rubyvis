module Rubyvis
  def self.Format
    Rubyvis::Format
  end

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
require 'rubyvis/format/number'
require 'rubyvis/format/date'
