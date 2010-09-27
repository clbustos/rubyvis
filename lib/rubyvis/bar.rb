module Rubyvis
  class Bar < Mark
    @properties={}
    property(:width).property(:height).property(:line_width).property(:stroke_style).property(:fill_style)
    def type
      "bar"
    end
    def defaults
      Bar.new._extend(Mark.new.defaults).line_width(1.5).fill_style(pv.Colors.category20().by(pv.parent))
    end
  end
end