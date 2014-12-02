module Rubyvis
  module SvgScene
    def self.line(scenes)
      #e=scenes._g.elements[1]
      e=scenes._g.get_element(1)
      return e if (scenes.size < 2)
      s = scenes[0]
      # segmented */
      return self.line_segment(scenes) if (s.segmented)

      #/* visible */
      return e if (!s.visible)
      fill = s.fill_style
      stroke = s.stroke_style

      return e if (fill.opacity==0.0 and  stroke.opacity==0.0)
      #/* points */

      d = "M#{s.left},#{s.top}"

      if (scenes.size > 2 and (['basis', 'cardinal', 'monotone'].include? s.interpolate))
        case (s.interpolate)
          when "basis"
            d = d+ curve_basis(scenes)
          when "cardinal"
            d = d+curve_cardinal(scenes, s.tension)
          when "monotone"
            d = d+curve_monotone(scenes)
        end

      else
        (1...scenes.size).each {|i|
          d+= path_segment(scenes[i-1],scenes[i])
        }
      end

      e = SvgScene.expect(e, "path", {
        "shape-rendering"=> s.antialias ? nil : "crispEdges",
        "pointer-events"=> s.events,
        "cursor"=> s.cursor,
        "d"=> d,
        "fill"=> fill.color,
        "fill-opacity"=> (fill.opacity==0.0) ? nil : fill.opacity,
        "stroke"=> stroke.color,
        "stroke-opacity"=> (stroke.opacity==0.0) ? nil : stroke.opacity,
        "stroke-width"=> (stroke.opacity>0) ? s.line_width / self.scale : nil,
        "stroke-linejoin"=> s.line_join
      });
      return SvgScene.append(e, scenes, 0);
    end

    def self.line_segment(scenes)

      #e=scenes._g.elements[1]
      e=scenes._g.get_element(1)
      s = scenes[0];
      paths=nil
      case s.interpolate
        when "basis"
          paths = curve_basis_segments(scenes)
        when "cardinal"
          paths=curve_cardinal_segments(scenes, s.tension)
        when "monotone"
          paths = curve_monotone_segments(scenes)
      end

      (0...(scenes.size-1)).each {|i|

        s1 = scenes[i]
        s2 = scenes[i + 1];
        #p "#{s1.top} #{s1.left} #{s1.line_width} #{s1.interpolate} #{s1.line_join}"
        # visible 
        next if (!s1.visible or !s2.visible)

        stroke = s1.stroke_style
        fill = Rubyvis::Color.transparent

        next if stroke.opacity==0.0

        # interpolate
        d=nil
        if ((s1.interpolate == "linear") and (s1.line_join == "miter"))
          fill = stroke
          stroke = Rubyvis::Color.transparent
          s0=((i-1) < 0) ? nil : scenes[i-1]
          s3=((i+2) >= scenes.size) ? nil : scenes[i+2]
          
          d = path_join(s0, s1, s2, s3)
        elsif(paths)
          d = paths[i]
        else
          d = "M#{s1.left},#{s1.top}#{path_segment(s1, s2)}"
        end

        e = SvgScene.expect(e, "path", {
          "shape-rendering"=> s1.antialias ? nil : "crispEdges",
          "pointer-events"=> s1.events,
          "cursor"=> s1.cursor,
          "d"=> d,
          "fill"=> fill.color,
          "fill-opacity"=> (fill.opacity==0.0) ? nil : fill.opacity,
          "stroke"=> stroke.color,
          "stroke-opacity"=> (stroke.opacity==0.0) ? nil : stroke.opacity,
          "stroke-width"=> stroke.opacity>0 ? s1.line_width / self.scale : nil,
          "stroke-linejoin"=> s1.line_join
        });
        e = SvgScene.append(e, scenes, i);
      }
      e
    end

    # Returns the path segment for the specified points. */

    def self.path_segment(s1, s2) 
      l = 1; # sweep-flag
      l = 0 if s1.interpolate=='polar-reverse'
      
      if s1.interpolate=='polar' or s1.interpolate=='polar-reverse'
        dx = s2.left - s1.left
        dy = s2.top - s1.top
        e = 1 - s1.eccentricity
        r = Math.sqrt(dx * dx + dy * dy) / (2 * e)
        if !((e<=0) or (e>1))
          return "A#{r},#{r} 0 0,#{l} #{s2.left},#{s2.top}"
        end
      end
      
      if s1.interpolate=="step-before"
        return "V#{s2.top}H#{s2.left}"
      elsif s1.interpolate=="step-after"
        return "H#{s2.left}V#{s2.top}"
      end
      
      return "L#{s2.left},#{s2.top}"
    end

    #/** @private Line-line intersection, per Akenine-Moller 16.16.1. */
    def self.line_intersect(o1, d1, o2, d2)
      return o1.plus(d1.times(o2.minus(o1).dot(d2.perp()) / d1.dot(d2.perp())));
    end

    #/** @private Returns the miter join path for the specified points. */
    def self.path_join(s0, s1, s2, s3)
      #
      # P1-P2 is the current line segment. V is a vector that is perpendicular to
      # the line segment, and has length lineWidth / 2. ABCD forms the initial
      # bounding box of the line segment (i.e., the line segment if we were to do
      # no joins).
      #

      p1 = Rubyvis.vector(s1.left, s1.top)

      p2 = Rubyvis.vector(s2.left, s2.top)

      _p = p2.minus(p1)

      v = _p.perp().norm()
      
      w = v.times(s1.line_width / (2.0 * self.scale))

      a = p1.plus(w)
      b = p2.plus(w)
      c = p2.minus(w)
      d = p1.minus(w)
      #/*
      # * Start join. P0 is the previous line segment's start point. We define the
      # * cutting plane as the average of the vector perpendicular to P0-P1, and
      # * the vector perpendicular to P1-P2. This insures that the cross-section of
      # * the line on the cutting plane is equal if the line-width is unchanged.
      # * Note that we don't implement miter limits, so these can get wild.
      # */
      if (s0 and s0.visible)
        v1 = p1.minus(s0.left, s0.top).perp().norm().plus(v)
        d = line_intersect(p1, v1, d, _p)
        a = line_intersect(p1, v1, a, _p)
      end

      #/* Similarly, for end join. */
      if (s3 and s3.visible)
        v2 = Rubyvis.vector(s3.left, s3.top).minus(p2).perp().norm().plus(v);
        c = line_intersect(p2, v2, c, _p);
        b = line_intersect(p2, v2, b, _p);
      end

      d="M#{a.x},#{a.y}L#{b.x},#{b.y} #{c.x},#{c.y} #{d.x},#{d.y}"
      d
    end
  end
end
