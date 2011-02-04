module Rubyvis
  module SvgScene
    def self.bar(scenes)
      #e=scenes._g.elements[1]
      e=scenes._g.get_element(1)
      scenes.each_with_index do |s,i|
        next unless s.visible
        fill=s.fill_style
        stroke=s.stroke_style
        next if(fill.opacity==0 and stroke.opacity==0)
        e=SvgScene.expect(e, 'rect', {
          "shape-rendering"=> s.antialias ? nil : "crispEdges",
          "pointer-events"=> s.events,
          "cursor"=> s.cursor,
          "x"=> s.left,
          "y"=> s.top,
          "width"=> [1E-10, s.width].max,
          "height"=> [1E-10, s.height].max,
          "fill"=> fill.color,
          "fill-opacity"=> (fill.opacity==0) ? nil : fill.opacity,
          "stroke"=> stroke.color,
          "stroke-opacity"=> (stroke.opacity==0) ? nil : stroke.opacity,
          "stroke-width"=> stroke.opacity ? s.line_width / SvgScene.scale.to_f : nil
        })

        e=SvgScene.append(e,scenes,i)

      end
      e
    end
  end
end
