module Rubyvis
  def self.Bar
    Rubyvis::Bar
  end
  class Bar < Mark
    def type
      "bar"
    end

    @properties=Mark.properties
    attr_accessor_dsl :width, :height, :line_width, :stroke_style, :fill_style
    def defaults
      sd=super
      return sd.merge({:line_width=>1.5, :fill_style=>Rubyvis.Colors.category20().by(Rubyvis.parent)})
    end
    def svg_render_pre
      "<rect fill='#{pr_svg(:fill_style)}' height='#{pr_svg(:height)}' width='#{pr_svg(:width)}' x='#{pr_svg(:left)}' y='#{pr_svg(:top)}'>"
    end
    def svg_render_post
      "</rect>"
    end
  end
end