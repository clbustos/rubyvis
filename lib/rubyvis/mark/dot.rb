module Rubyvis
  # Alias por Rubyvis::Dot
  def self.Dot
    Rubyvis::Dot
  end
  # Represents a dot; a dot is simply a sized glyph centered at a given
  # point that can also be stroked and filled. The <tt>size</tt> property is
  # proportional to the area of the rendered glyph to encourage meaningful visual
  # encodings. Dots can visually encode up to eight dimensions of data, though
  # this may be unwise due to integrality. See Mark for details on the
  # prioritization of redundant positioning properties.  
  class Dot < Mark
    # Type of mark
    def type
      "dot"
    end

    @properties=Mark.properties.dup
    
    ##
    # :attr: shape_size
    # The size of the shape, in square pixels. Square pixels are used such that the
    # area of the shape is linearly proportional to the value of the
    # <tt>shape_size</tt> property, facilitating representative encodings. This is
    # an alternative to using shape_radius
    #
    
    ##
    # :attr: shape_radius 
    # The radius of the shape, in pixels. This is an alternative to using
    # shape_size
    #
    
    ##
    # :attr: shape
    # The shape name. Several shapes are supported:<ul>
    #
    # <li>cross
    # <li>triangle
    # <li>diamond
    # <li>square
    # <li>circle
    # <li>tick
    # <li>bar
    #
    # </ul>These shapes can be further changed using the angle() property;
    # for instance, a cross can be turned into a plus by rotating. Similarly, the
    # tick, which is vertical by default, can be rotated horizontally. Note that
    # some shapes (cross and tick) do not have interior areas, and thus do not
    # support fill style meaningfully.
    #
    # <p>Note: it may be more natural to use the Rule mark for
    # horizontal and vertical ticks. The tick shape is only necessary if angled
    # ticks are needed.
    
    ##
    # :attr: shape_angle
    # The shape rotation angle, in radians. Used to rotate shapes, such as to turn
    # a cross into a plus.
    
    ##
    # :attr: line_width
    # The width of stroked lines, in pixels; used in conjunction with
    # +stroke_style+ to stroke the dot's shape.
    
    ##
    # :attr: stroke_style
    # The style of stroked lines; used in conjunction with +line_width+ to
    # stroke the dot's shape. The default value of this property is a categorical color. See Rubyvis.color()
    
    ##
    # :attr: fill_style
    # The fill style; if non-nil, the interior of the dot is filled with the
    # specified color. The default value of this property is nil, meaning dots are
    # not filled by default. See Rubyvis.color()
    
    attr_accessor_dsl :shape, :shape_angle, :shape_radius, :shape_size, :line_width, [:stroke_style, lambda {|d| Rubyvis.color(d)}], [:fill_style, lambda {|d| Rubyvis.color(d)}]
    # Default properties for dots. By default, there is no fill and the stroke
    # style is a categorical color. The default shape is "circle" with radius 4.5.
    def self.defaults()
      a=Rubyvis::Colors.category10
      Dot.new().mark_extend(Mark.defaults).shape("circle"). line_width(1.5). stroke_style(lambda {a.scale(self.parent.index)})
    end
    # Constructs a new dot anchor with default properties. Dots support five
    # different anchors:<ul>
    #
    # <li>top
    # <li>left
    # <li>center
    # <li>bottom
    # <li>right
    #
    # </ul>In addition to positioning properties (left, right, top bottom), the
    # anchors support text rendering properties (text-align, text-baseline). Text is
    # rendered to appear outside the dot. Note that this behavior is different from
    # other mark anchors, which default to rendering text <i>inside</i> the mark.
    #
    # <p>For consistency with the other mark types, the anchor positions are
    # defined in terms of their opposite edge. For example, the top anchor defines
    # the bottom property, such that a bar added to the top anchor grows upward.
    def anchor(name)
      mark_anchor(name).left(lambda {
        s=scene.target[self.index]
        case self.name
          when 'bottom' then s.left;
          when 'top' then s.left;
          when 'center' then s.left;
          when 'left' then nil;
          else
            s.left+s.shape_radius
        end
      }).right(lambda {
        s=scene.target[self.index]
        self.name()=='left' ? s.right+s.shape_radius : nil
      }).top(lambda {
        s=scene.target[self.index]
        case self.name
          when 'left' then  s.top;
          when 'right' then s.top;
          when 'center' then s.top;
          when 'top' then nil;
          else
            s.top+s.shape_radius
        end
      }).bottom(lambda {
        s=scene.target[self.index]
        self.name()=='top' ? s.bottom+s.shape_radius : nil
      }).text_align(lambda {
        case self.name
          when 'left' then  'right';
          when 'bottom' then 'center';
          when 'top' then 'center';
          when 'center' then 'center';
          else
            'left'
        end
      }).text_baseline( lambda {
        case self.name
          when 'right' then  'middle';
          when 'left' then 'middle';
          when 'center' then 'middle';
          when 'bottom' then 'top';
          else
            'bottom'
        end
      
      })
    end
    
    
    # @private Sets radius based on size or vice versa. 
    def build_implied(s) # :nodoc:
      r = s.shape_radius
      z = s.shape_size
      if (r.nil?) 
        if (z.nil?) 
          s.shape_size = 20.25;
          s.shape_radius = 4.5;
        else
          s.shape_radius = Math.sqrt(z)
        end
      elsif (z.nil?) 
        s.shape_size = r * r;
      end
      mark_build_implied(s)
    end
  end
end
