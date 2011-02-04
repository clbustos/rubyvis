module Rubyvis
  module SvgScene
    def self.dot(scenes)
      #e = scenes._g.elements[1]
      e=scenes._g.get_element(1)
      scenes.each_with_index {|s,i|
      s = scenes[i];
      
      # visible */
      next if !s.visible
      fill = s.fill_style
      stroke = s.stroke_style
      next if (fill.opacity==0 and stroke.opacity==0)
      
      #/* points */
      radius = s.shape_radius
      path = nil
      case s.shape
      when 'cross'
        path = "M#{-radius},#{-radius}L#{radius},#{radius}M#{radius},#{ -radius}L#{ -radius},#{radius}"
      when "triangle"
        h = radius
        w = radius * 1.1547; # // 2 / Math.sqrt(3)
        path = "M0,#{h}L#{w},#{-h} #{-w},#{-h}Z"
      when  "diamond"
        radius=radius* Math::sqrt(2)
        path = "M0,#{-radius}L#{radius},0 0,#{radius} #{-radius},0Z";
      when  "square"
        path = "M#{-radius},#{-radius}L#{radius},#{-radius} #{radius},#{radius} #{-radius},#{radius}Z"
      when  "tick"
        path = "M0,0L0,#{-s.shapeSize}"
      when  "bar"
        path = "M0,#{s.shape_size / 2.0}L0,#{-(s.shapeSize / 2.0)}"

      end
      
      #/* Use <circle> for circles, <path> for everything else. */
      svg = {
      "shape-rendering"=> s.antialias ? nil : "crispEdges",
      "pointer-events"=> s.events,
      "cursor"=> s.cursor,
      "fill"=> fill.color,
      "fill-opacity"=> (fill.opacity==0) ? nil : fill.opacity,
      "stroke"=> stroke.color,
      "stroke-opacity"=> (stroke.opacity==0) ? nil : stroke.opacity,
      "stroke-width"=> (stroke.opacity!=0) ? s.line_width / self.scale : nil
      }
      
      if (path) 
          svg["transform"] = "translate(#{s.left},#{s.top})"
          if (s.shape_angle) 
            svg["transform"] += " rotate(#{180 * s.shape_angle / Math.PI})";
          end
        svg["d"] = path
        e = self.expect(e, "path", svg);
      else 
        svg["cx"] = s.left;
        svg["cy"] = s.top;
        svg["r"] = radius;
        e = self.expect(e, "circle", svg);
      end
      e = self.append(e, scenes, i);
      }
      return e
    end
  end
end

