module Rubyvis
  module SvgScene
    def self.rule(scenes)
      e=scenes._g.elements[1]
      scenes.each_with_index do |s,i|
        next unless s.visible
        stroke=s.stroke_style
        next if(!stroke.opacity)
        e=SvgScene.expect(e,'line', {
          "shape-rendering"=> s.antialias ? nil : "crispEdges",
          "pointer-events"=> s.events,
          "cursor"=> s.cursor,
          "x1"=> s.left,
          "y1"=> s.top,
          'x2'=> s.left+s.width,
          'y2'=>s.top+s.height,
          "stroke"=> stroke.color,
          "stroke-opacity"=> stroke.opacity,
          "stroke-width"=> s.line_width/self.scale.to_f
        })

        e=SvgScene.append(e,scenes,i)

      end
      e
    end
  end
end
