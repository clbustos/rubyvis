module Rubyvis
  def self.Line
    Rubyvis::Line
  end
  module LinePrototype
    include AreaPrototype  
    def line_anchor(name)
      area_anchor(name).text_align(lambda {|d|
         {'left'=>'right','bottom'=>'center', 'top'=>'center','center'=>'center','right'=>'left'}[d]
      }).text_baseline(lambda{|d|
         {'top'=>'bottom','right'=>'middle', 'left'=>'middle','center'=>'middle','bottom'=>'top'}[d]
      })
    end
  end
  class Line < Mark
    include AreaPrototype
    include LinePrototype
    @properties=Mark.properties.dup
    attr_accessor_dsl :line_width, :line_join, :stroke_style, :fill_style, :segmented, :interpolate, :eccentricity, :tension
    def type
      "line"
    end
    def anchor(name)
      line_anchor(name)
    end
    def bind(*args)
      area_bind(*args)
    end
    def build_instance(*args)
      area_build_instance(*args)
    end
    def defaults
      Line.new.extend(Rubyvis::Mark).line_join('miter').line_width(1.5).stroke_style(RubyVis::Color.category10().by(pv.parent)).interpolate('linear').eccentricity(0).tension(7)
    end
  end
end