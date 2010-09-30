module Rubyvis
  def self.Rule
    Rubyvis::Rule
  end
  class Rule < Mark
    @properties=Mark.properties
    attr_accessor_dsl :width, :height, :line_width, :stroke_style
    def defaults
      sd=super
      return sd.merge({:line_width=>1,:stroke_style=>'black',:antialias=>false})
    end
    def anchor(name)
      # Copiar de linea
      Rubyvis::Line.new.anchor(name)
    end
    
    def svg_render_pre
      "<line shape-rendering='#{shape_rendering}' x1=>'>"
    end
    def svg_render_post
      "</line>"
    end
  end
end