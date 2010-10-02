module Rubyvis
  def self.Area
    Rubyvis::Area
  end
  module AreaPrototype
    def area_anchor(name)
      scene=nil
      self.anchor(name).interpolate(lambda {
          self.scene.target[self.index].interpolate
      }).eccentricity(lambda {
      self.scene.target[self.index].eccentricity
      }).tension(lambda {
      self.scene.target[self.index].tension
      })
    end
  end
  class Area < Mark
    include AreaPrototype
    @properties=Mark.properties.dup
    attr_accessor_dsl :width, :height, :line_width, :stroke_style, :fill_style, :segmented, :interpolate, :tension
    def type
      'area'
    end
    def self.defaults
      Area.new.extend(Mark.defaults).line_width(1.5).fill_style(pv.Colors.category20.by(pv.parent)).interpolate('linear').tension(0.7)
    end
    def anchor(name)
      area_anchor(name)
    end
    def build_implied(s)
      s.heigth=0 if s.height.nil?
      s.width=0 if s.width.nil?
      super(s)
    end
  end
end