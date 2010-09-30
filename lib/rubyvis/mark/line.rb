module Rubyvis
  def self.Line
    Rubyvis::Line
  end
  
  class Line < Mark
    @properties=Mark.properties
    attr_accessor_dsl :line_width, :line_join, :stroke_style, :fill_style, :segmented, :interporale, :eccentricity, :tension
    def defaults
      sd=super
      return sd.merge({:line_join=>'miter', :line_width=>1.5, :stroke_style=>RubyVis::Color.category10().by(pv.parent), :interpolate=>'linear', :eccentricity=>0, :tension=>7})
    end
  end
end