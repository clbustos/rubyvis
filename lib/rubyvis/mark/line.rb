module Rubyvis
  # Alias for Rubyvis::Line
  def self.Line
    Rubyvis::Line
  end
  # Provides methods pertinents to line like marks.  
  module LinePrototype  # :nodoc:
    include AreaPrototype
    def line_anchor(name)
      
      anchor=area_anchor(name).text_align(lambda {|d|
          {'left'=>'right', 'bottom'=>'center', 'top'=>'center', 'center'=>'center','right'=>'left'}[self.name()]
      }).text_baseline(lambda{|d|
        {'top'=>'bottom', 'right'=>'middle', 'left'=>'middle','center'=>'middle', 'bottom'=>'top'}[self.name()]
      })
      anchor
    end
  end
  
  # Represents a series of connected line segments, or <i>polyline</i>,
  # that can be stroked with a configurable color and thickness. Each
  # articulation point in the line corresponds to a datum; for <i>n</i> points,
  # <i>n</i>-1 connected line segments are drawn. The point is positioned using
  # the box model. Arbitrary paths are also possible, allowing radar plots and
  # other custom visualizations.
  #
  # <p>Like areas, lines can be stroked and filled with arbitrary colors. In most
  # cases, lines are only stroked, but the fill style can be used to construct
  # arbitrary polygons.
  class Line < Mark
    include AreaPrototype
    include LinePrototype
    @properties=Mark.properties.dup
    
      
    ##
    # :attr: line_width
    # The width of stroked lines, in pixels; used in conjunction with
    # +stroke_style+ to stroke the line.
    
    
    ##
    # :attr: stroke_style
    # The style of stroked lines; used in conjunction with <tt>lineWidth</tt> to
    # stroke the line. The default value of this property is a categorical color.
    
    
    ##
    # :attr: line_join
    # The type of corners where two lines meet. Accepted values are "bevel",
    # "round" and "miter". The default value is "miter".
    #
    # <p>For segmented lines, only "miter" joins and "linear" interpolation are
    # currently supported. Any other value, including nil, will disable joins,
    # producing disjoint line segments. Note that the miter joins must be computed
    # manually (at least in the current SVG renderer); since this calculation may
    # be expensive and unnecessary for small lines, specifying nil can improve
    # performance significantly.
    #
    # <p>This property is <i>fixed</i>. See Rubyvis.Mark    
    
    ##
    # :attr: fill_style
    # The line fill style; if non-nil, the interior of the line is closed and
    # filled with the specified color. The default value of this property is a
    # nil, meaning that lines are not filled by default.
    #
    # <p>This property is <i>fixed</i>. See Rubyvis.Mark    
    
    
    ##
    # :attr: segmented
    # Whether the line is segmented; whether variations in stroke style, line width and the other properties are treated as fixed. Rendering segmented lines is noticeably slower than non-segmented lines.
    # <p>This property is <i>fixed</i>. See Rubyvis.Mark    
    
    
    ##
    # :attr: interpolate
    # How to interpolate between values. Linear interpolation ("linear") is the
    # default, producing a straight line between points. For piecewise constant
    # functions (i.e., step functions), either "step-before" or "step-after" 
    # can be specified. To draw a clockwise circular arc between points, 
    # specify "polar"; to draw a counterclockwise circular arc between points,
    # specify "polar-reverse". To draw open uniform b-splines, specify "basis". # To draw cardinal splines, specify "cardinal"; see also Line.tension()
    #
    # <p>This property is <i>fixed</i>. See Rubyvis.Mark    
    
    
    ## 
    # :attr: eccentricity
    # The eccentricity of polar line segments; used in conjunction with
    # interpolate("polar"). The default value of 0 means that line segments are
    # drawn as circular arcs. A value of 1 draws a straight line. A value between 0
    # and 1 draws an elliptical arc with the given eccentricity.
    
    
    ##
    # :attr: tension
    # The tension of cardinal splines; used in conjunction with
    # interpolate("cardinal"). A value between 0 and 1 draws cardinal splines with
    # the given tension. In some sense, the tension can be interpreted as the
    # "length" of the tangent; a tension of 1 will yield all zero tangents (i.e.,
    # linear interpolation), and a tension of 0 yields a Catmull-Rom spline. The
    # default value is 0.7.
    #
    # <p>This property is <i>fixed</i>. See Rubyvis.Mark    
    
    attr_accessor_dsl :line_width, :line_join, [:stroke_style, lambda {|d| Rubyvis.color(d)}], [:fill_style, lambda {|d| Rubyvis.color(d)}], :segmented, :interpolate, :eccentricity, :tension
    # Type of line
    def type
      "line"
    end
    
    # Constructs a new line anchor with default properties. Lines support five
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
    # rendered to appear outside the line. Note that this behavior is different
    # from other mark anchors, which default to rendering text <i>inside</i> the
    # mark.
    #
    # <p>For consistency with the other mark types, the anchor positions are
    # defined in terms of their opposite edge. For example, the top anchor defines
    # the bottom property, such that a bar added to the top anchor grows upward.
    def anchor(name)
      line_anchor(name)
    end
    # Reuse Area's implementation for segmented bind & build.
    def bind(*args) # :nodoc:
      area_bind(*args)
    end
    # Reuse Area's implementation for segmented bind & build.
    
    def build_instance(*args) # :nodoc:
      area_build_instance(*args)
    end
    # Default properties for lines. By default, there is no fill and the stroke
    # style is a categorical color. The default interpolation is linear.

    def self.defaults
      a=Rubyvis::Colors.category10()
      Line.new.mark_extend(Mark.defaults).line_join('miter').line_width(1.5).stroke_style( lambda { a.scale(parent.index)}).interpolate('linear').eccentricity(0).tension(0.7)
    end
  end
end
