module Rubyvis
  # Alias for Rubyvis::Area
  def self.Area
    Rubyvis::Area
  end
  # Provides methods pertinents to area like-marks.
  module AreaPrototype  # :nodoc:
    def fixed
      {
        :line_width=> true,
        :line_join=> true,
        :stroke_style=> true,
        :fill_style=> true,
        :segmented=> true,
        :interpolate=> true,
        :tension=> true
      }
    end
    def area_build_instance(s)
      binds = self.binds
      # Handle fixed properties on secondary instances. */
      if (self.index!=0)
        fixed = @binds.fixed
        #/* Determine which properties are fixed. */
        if (!fixed)
          binds.fixed=[]
          fixed = binds.fixed
          filter=lambda {|prop|
            if prop.fixed
              fixed.push(prop)
              false
            else
              true
            end
          }
          #      p binds.required
          binds.required = binds.required.find_all(&filter)
          #      p binds.required
          if (!self.scene[0].segmented)
            binds.optional = binds.optional.find_all(&filter)
          end
          
        end
        
        #    p binds.required


        #/* Copy fixed property values from the first instance. */
        fixed.each {|prop|
          name=prop.name
          s[name]=self.scene[0][name]
        }
        
        
        #    p binds.fixed
        #/* Evaluate all properties on the first instance. */
      else
        binds.required = binds._required
        binds.optional = binds._optional
        binds.fixed = nil
      end
      # pp binds
      mark_build_instance(s)
    end



    def area_bind
      mark_bind
      
      binds = self.binds
      required = binds.required
      optional = binds.optional
      
      optional.size.times {|i|
        prop = optional[i]
        prop.fixed = fixed.keys.include? prop.name
        
        if (prop.name == "segmented")
          required.push(prop)
        end
      }
      optional.delete_if {|v| v.name=='segmented'}
      # Cache the original arrays so they can be restored on build. */
      @binds._required = required
      @binds._optional = optional
    end


    def area_anchor(name)
      #scene=nil
      anchor=mark_anchor(name)
      anchor.interpolate(lambda {
        self.scene.target[self.index].interpolate
      }).eccentricity(lambda {
        self.scene.target[self.index].eccentricity
      }).tension(lambda {
        self.scene.target[self.index].tension
      })
      anchor
    end
  end
  
  # Represents an area mark: the solid area between two series of
  # connected line segments. Unsurprisingly, areas are used most frequently for
  # area charts.
  #
  # <p>Just as a line represents a polyline, the <tt>Area</tt> mark type
  # represents a <i>polygon</i>. However, an area is not an arbitrary polygon;
  # vertices are paired either horizontally or vertically into parallel
  # <i>spans</i>, and each span corresponds to an associated datum. Either the
  # width or the height must be specified, but not both; this determines whether
  # the area is horizontally-oriented or vertically-oriented.  Like lines, areas
  # can be stroked and filled with arbitrary colors.

  class Area < Mark
    include AreaPrototype
    @properties=Mark.properties.dup
    
    
  ##
  # :attr: width
  # The width of a given span, in pixels; used for horizontal spans. If the width
  # is specified, the height property should be 0 (the default). Either the top
  # or bottom property should be used to space the spans vertically, typically as
  # a multiple of the index.
  
  
  ##
  # :attr: height  
  # The height of a given span, in pixels; used for vertical spans. If the height
  # is specified, the width property should be 0 (the default). Either the left
  # or right property should be used to space the spans horizontally, typically
  # as a multiple of the index.
  
  
  ##
  # :attr: line_width  
  # The width of stroked lines, in pixels; used in conjunction with
  # <tt>strokeStyle</tt> to stroke the perimeter of the area. Unlike the
  # {@link Line} mark type, the entire perimeter is stroked, rather than just one
  # edge. The default value of this property is 1.5, but since the default stroke
  # style is null, area marks are not stroked by default.
  #
  # <p>This property is <i>fixed</i> for non-segmented areas. See
  # {@link pv.Mark}.
  
  
  ##
  # :attr: stroke_style
  # The style of stroked lines; used in conjunction with <tt>lineWidth</tt> to
  # stroke the perimeter of the area. Unlike the {@link Line} mark type, the
  # entire perimeter is stroked, rather than just one edge. The default value of
  # this property is null, meaning areas are not stroked by default.
  #
  # <p>This property is <i>fixed</i> for non-segmented areas. See
  # {@link pv.Mark}.
  #
  
  
  ##
  # :attr: fill_style  
  # The area fill style; if non-null, the interior of the polygon forming the
  # area is filled with the specified color. The default value of this property
  # is a categorical color.
  #
  # <p>This property is <i>fixed</i> for non-segmented areas. See
  # {@link pv.Mark}.
  
  
  ##
  # :attr: segmented  
  # Whether the area is segmented; whether variations in fill style, stroke
  # style, and the other properties are treated as fixed. Rendering segmented
  # areas is noticeably slower than non-segmented areas.
  #
  # <p>This property is <i>fixed</i>. See {@link pv.Mark}.
  
  
  ##
  # :attr: interpolate  
  # How to interpolate between values. Linear interpolation ("linear") is the
  # default, producing a straight line between points. For piecewise constant
  # functions (i.e., step functions), either "step-before" or "step-after" can
  # be specified. To draw open uniform b-splines, specify "basis".
  # To draw cardinal splines, specify "cardinal"; see also Line.tension()
  #
  # <p>This property is <i>fixed</i>. See {@link pv.Mark}.
  
  
  ##
  # :attr: tension  
  # The tension of cardinal splines; used in conjunction with
  # interpolate("cardinal"). A value between 0 and 1 draws cardinal splines with
  # the given tension. In some sense, the tension can be interpreted as the
  # "length" of the tangent; a tension of 1 will yield all zero tangents (i.e.,
  # linear interpolation), and a tension of 0 yields a Catmull-Rom spline. The
  # default value is 0.7.
  #
  # <p>This property is <i>fixed</i>. See {@link pv.Mark}.
    
    
    
    attr_accessor_dsl :width, :height, :line_width, [:stroke_style, lambda {|d| Rubyvis.color(d)}], [:fill_style, lambda {|d| Rubyvis.color(d)}], :segmented, :interpolate, :tension
    def type
      'area'
    end
    def bind
      area_bind
    end
    def build_instance(s)
      area_build_instance(s)
    end
    def self.defaults
      a= Rubyvis::Colors.category20
      Area.new.mark_extend(Mark.defaults).line_width(1.5).fill_style(lambda {a.scale(self.parent.index)}).interpolate('linear').tension(0.7)
    end
    def anchor(name)
      area_anchor(name)
    end
    def build_implied(s)
      s.heigth=0 if s.height.nil?
      s.width=0 if s.width.nil?
      mark_build_implied(s)
    end
  end
end
