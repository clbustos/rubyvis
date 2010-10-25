module Rubyvis
  def self.Scale
    Rubyvis::Scale
  end
  module Scale
    def self.quantitative(*args)
      Quantitative.new(*args)
    end
    def self.linear(*args)
      Linear.new(*args)
    end
    def self.ordinal(*args)
      Ordinal.new(*args)
    end
    def self.log(*args)
      Log.new(*args)
    end
    def self.interpolator(start,_end)
      if start.is_a? Numeric
        return lambda {|t| t*(_end-start)+start}
      end
      start=Rubyvis.color(start).rgb()
      _end = Rubyvis.color(_end).rgb()
      return lambda {|t|
        a=start.a*(1-t)+_end.a*t
        a=0 if a<1e-5
        return (start.a == 0) ? Rubyvis.rgb(_end.r, _end.g, _end.b, a) : ((_end.a == 0) ? Rubyvis.rgb(start.r, start.g, start.b, a) : Rubyvis.rgb(
        (start.r * (1 - t) + _end.r * t).round,
        (start.g * (1 - t) + _end.g * t).round,
        (start.b * (1 - t) + _end.b * t).round, a))
      }
    end
  end
end
require 'rubyvis/scale/quantitative.rb'
require 'rubyvis/scale/linear.rb'
require 'rubyvis/scale/ordinal.rb'
require 'rubyvis/scale/log.rb'
