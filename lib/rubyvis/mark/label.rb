module Rubyvis
  # Alias for Rubyvis::Label
  def self.Label
    Rubyvis::Label
  end
  # Represents a text label, allowing textual annotation of other marks or
  # arbitrary text within the visualization. The character data must be plain
  # text (unicode), though the text can be styled using the {@link #font}
  # property. If rich text is needed, external HTML elements can be overlaid on
  # the canvas by hand.
  #
  # <p>Labels are positioned using the box model, similarly to {@link Dot}. Thus,
  # a label has no width or height, but merely a text anchor location. The text
  # is positioned relative to this anchor location based on the
  # text_align, text_baseline and text_margin properties.
  # Furthermore, the text may be rotated using text_angle
  class Label < Mark
    @properties=Mark.properties.dup
    
    ##
    # :attr: text
    # The character data to render; a string. The default value of the text
    # property is the identity function, meaning the label's associated datum will
    # be rendered using its to_s()
    
    ##
    # :attr: font
    # The font format, per the CSS Level 2 specification. The default font is "10px
    # sans-serif", for consistency with the HTML 5 canvas element specification.
    # Note that since text is not wrapped, any line-height property will be
    # ignored. The other font-style, font-variant, font-weight, font-size and
    # font-family properties are supported.
    #
    # @see {CSS2 fonts}[http://www.w3.org/TR/CSS2/fonts.html#font-shorthand]
    
    ##
    # :attr: text_angle
    # The rotation angle, in radians. Text is rotated clockwise relative to the
    # anchor location. For example, with the default left alignment, an angle of
    # Math.PI / 2 causes text to proceed downwards. The default angle is zero.
    
    ##
    # :attr: text_style
    # The text color. The name "text_style" is used for consistency with "fill_style"
    # and "stroke_style", although it might be better to rename this property (and
    # perhaps use the same name as "stroke_style"). The default color is black.
    # See Rubyvis.color()
    
    ##
    # :attr: text_align
    # The horizontal text alignment. One of:<ul>
    #
    # <li>left
    # <li>center
    # <li>right
    #
    # </ul>The default horizontal alignment is left.
    
    
    ##
    # :attr: text_baseline
    # The vertical text alignment. One of:<ul>
    #
    # <li>top
    # <li>middle
    # <li>bottom
    #
    # </ul>The default vertical alignment is bottom.
    
    
    ##
    # :attr: text_margin
    # The text margin; may be specified in pixels, or in font-dependent units (such
    # as ".1ex"). The margin can be used to pad text away from its anchor location,
    # in a direction dependent on the horizontal and vertical alignment
    # properties. For example, if the text is left- and middle-aligned, the margin
    # shifts the text to the right. The default margin is 3 pixels.
    
    
    ##
    # :attr: text_shadow
    # A list of shadow effects to be applied to text, per the CSS Text Level 3
    # text-shadow property. An example specification is "0.1em 0.1em 0.1em
    # rgba(0,0,0,.5)"; the first length is the horizontal offset, the second the
    # vertical offset, and the third the blur radius.
    #
    # See {CSS3 text}[http://www.w3.org/TR/css3-text/#text-shadow]
    
    ##
    # :attr: text_decoration
    # A list of decoration to be applied to text, per the CSS Text Level 3
    # text-decoration property. An example specification is "underline".
    #
    # See {CSS3 text}[http://www.w3.org/TR/css3-text/#text-decoration]
    
    
    attr_accessor_dsl :text, :font, :text_angle, [:text_style, lambda {|d| Rubyvis.color(d)}], :text_align, :text_baseline, :text_margin, :text_decoration, :text_shadow, :font_family, :font_style, :font_variant, :font_weight, :font_size
    # Mark type
    def type
      'label'
    end
    # Default properties for labels. See the individual properties for the default values.
    def self.defaults
      Label.new.mark_extend(Mark.defaults).events('none').text(Rubyvis.identity).font("10px sans-serif" ).text_angle( 0 ).text_style( 'black' ).text_align( 'left' ).text_baseline( 'bottom' ).text_margin(3)
    end
  end
end
