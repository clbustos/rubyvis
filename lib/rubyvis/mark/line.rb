module Rubyvis
  def self.Line
    Rubyvis::Line
  end
  module LinePrototype
    include AreaPrototype
    def line_anchor(name)
      anchor=area_anchor(name).text_align(lambda {|d|
          {'left'=>'right','bottom'=>'center', 'top'=>'center','center'=>'center','right'=>'left'}[self.name]
      }).text_baseline(lambda{|d|
        {'top'=>'bottom', 'right'=>'middle', 'left'=>'middle','center'=>'middle','bottom'=>'top'}[self.name]
      })
      return anchor
    end
  end
  class Line < Mark
    include AreaPrototype
    include LinePrototype
    @properties=Mark.properties.dup
    attr_accessor_dsl :line_width, :line_join, [:stroke_style, lambda {|d| Rubyvis.color(d)}], [:fill_style, lambda {|d| Rubyvis.color(d)}], :segmented, :interpolate, :eccentricity, :tension
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
    def self.defaults
      a=Rubyvis::Colors.category10()
      Line.new.extend(Mark.defaults).line_join('miter').line_width(1.5).stroke_style( lambda {return a.scale(self.parent.index)}).interpolate('linear').eccentricity(0).tension(7)
    end
  end
end
