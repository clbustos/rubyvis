module Rubyvis
  def self.Area
    Rubyvis::Area
  end
  
  class Area < Mark
    @properties=Mark.properties
    attr_accessor_dsl :width, :height, :line_width, :stroke_style, :fill_style, :segmented, :interpolate, :tension
    def type
      'area'
    end
    def defaults
      sd=super
      return sd.merge({:line_width=>1.5, :fill_style=>pv.Colors.category20.by(pv.parent), :interpolate=>'linear', :tension=>0.7})
    end
    def build_implied(s)
      s.heigth=0 if s.height.nil?
      s.width=0 if s.width.nil?
      super(s)
    end
    def self.anchor(name)
      Mark.anchor(name).interpolate(lambda {
          self.scene.target[self.index].interpolate
      }).eccentricity(lambda {
      self.scene.target[self.index].eccentricity
      }).tension(lambda {
      self.scene.target[self.index].tension
      })
    end
    def anchor
      (self.class).anchor(name)
    end
  end
end