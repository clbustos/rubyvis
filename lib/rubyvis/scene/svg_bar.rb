module Rubyvis
  module SvgScene
    def self.bar(scenes)
      Rubyvis::SvgScene::Bar.new(scenes)
    end
    class Bar
      attr_accessor :scenes
      def initialize(scenes)
        @scenes=scenes
        @e=scenes._g.elements[0]
        compute
      end
      def compute
        scenes.each_with_index(s,i) do
          next unless x.visible
          fill=s.fill_style
          stroke=s.stroke_style
          next if(!fill.opacity and !stroke.opacity)
          @e=SvgScene.expect(@e,'rect', {
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
        "stroke-width"=> stroke.opacity ? s.line_width / this.scale.to_f : nil
      })
          @e=SvgScene.append(e,scenes,i)
        end
      end
    end
  end
end
