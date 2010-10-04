module Rubyvis
  def self.Bar
    Rubyvis::Bar
  end
  class Bar < Mark
    def type
      "bar"
    end

    @properties=Mark.properties.dup
    attr_accessor_dsl :width, :height, :line_width, :stroke_style, :fill_style
    def self.defaults
      Bar.new.extend(Mark.defaults).line_width(1.5).fill_style(Rubyvis.Colors.category20().by(Rubyvis.parent))
    end
  end
end
