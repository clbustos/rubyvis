module Rubyvis
  # Alias for Rubyvis::Bar
  def self.Bar
    Rubyvis::Bar
  end
  
  # Represents a bar: an axis-aligned rectangle that can be stroked and
  # filled. Bars are used for many chart types, including bar charts, histograms
  # and Gantt charts. Bars can also be used as decorations, for example to draw a
  # frame border around a panel; in fact, a panel is a special type (a subclass)
  # of bar.
  #
  # Bars can be positioned in several ways. Most commonly, one of the four
  # corners is fixed using two margins, and then the width and height properties
  # determine the extent of the bar relative to this fixed location. For example,
  # using the bottom and left properties fixes the bottom-left corner; the width
  # then extends to the right, while the height extends to the top. As an
  # alternative to the four corners, a bar can be positioned exclusively using
  # margins; this is convenient as an inset from the containing panel, for
  # example. See Mark for details on the prioritization of redundant
  # positioning properties.
  class Bar < Mark
    
    def type # :nodoc:
      "bar"
    end

    @properties=Mark.properties.dup
    
    
    ##
    # :attr: width
    # The width of the bar, in pixels. If the left position is specified, the bar
    # extends rightward from the left edge; if the right position is specified, the
    # bar extends leftward from the right edge.
    
    ##
    # :attr: height
    # The height of the bar, in pixels. If the bottom position is specified, the
    # bar extends upward from the bottom edge; if the top position is specified,
    # the bar extends downward from the top edge.
    
    ##
    # :attr: line_width    
    # The width of stroked lines, in pixels; used in conjunction with
    # stroke_style to stroke the bar's border.
    
    ##
    # :attr: stroke_style
    # The style of stroked lines; used in conjunction with line_width to
    # stroke the bar's border. The default value of this property is nil, meaning bars are not stroked by default.
    
    ##
    # :attr: fill_style
    # The bar fill style; if non-nil, the interior of the bar is filled with the
    # specified color. The default value of this property is a categorical color.
    
    attr_accessor_dsl :width, :height, :line_width, [:stroke_style, lambda {|d| Rubyvis.color(d)}], [:fill_style, lambda {|d| Rubyvis.color(d)}]
    
    # Default properties for bars. By default, there is no stroke and the fill
    # style is a categorical color.
    def self.defaults
      a=Rubyvis.Colors.category20()
      Bar.new.mark_extend(Mark.defaults).line_width(1.5).fill_style( lambda {
          a.scale(self.parent.index)
      })
    end
  end
end
