module Rubyvis
  module SvgScene
    def self.panel(scenes)
      Rubyvis::SvgScene::Panel.new(scenes)
    end
    class Panel
      attr_accessor :scenes
      def initialize(scenes)
        @scenes=scenes
        @g=scenes._g
        @e=(@g.nil? ) ? nil: @g.elements[1]
        compute
      end
      def fill(e,scenes,i)
        s=scenes[i]
        fill=s.fill_style
        if(fill.opacity or s.events=='all')
        e=SvgScene.expect(e,'rect', {
          "shape-rendering"=> s.antialias ? nil : "crispEdges",
          "pointer-events"=> s.events,
          "cursor"=> s.cursor,
          "x"=> s.left,
          "y"=> s.top,
          "width"=> s.width,
          "height"=> s.height,
          "fill"=> fill.color,
          "fill-opacity"=> fill.opacity,
          "stroke"=> nil
          })
          
        
        e=SvgScene.append(e,scenes, i)
        end
        e
      end
      def compute
        scenes.each_with_index do |s,i|
          next unless s.visible
          if(!scenes.parent)
            if @g and @g.parent_node!=s.canvas
              @g=s.canvas.elements[1]
              @e=(@g.nil?) ? nil : @g.elements[1]
            end
            if(!@g)
              @g=s.canvas.add_element(SvgScene.create('svg'))
              @g.attributes["font-size"]="10px"
              @g.attributes["font-family"]="sans-serif"
              @g.attributes["fill"]="none"
              @g.attributes["stroke"]="none"
              @g.attributes["stroke-width"]=1.5
              @e=@g.elements[1]
            end
            scenes._g=@g
            p s
            @g.attributes['width']=s.width+s.left+s.right
            @g.attributes['height']=s.height+s.top+s.bottom
          end
          if s.overflow=='hidden'
            puts "OMITTED"
            # omitted
          end
          @e=self.fill(@e,scenes, i)
          k=SvgScene.scale
          t=s.transform
          
          x=s.left+t.x
          y=s.top+t.y
          
          
          SvgScene.scale=SvgScene.scale*t.k
          s.children.each_with_index {|child, i|
            child._g=e=self.expect(e, "g", {
          "transform"=> "translate(" + x + "," + y + ")" + (t.k != 1 ? " scale(" + t.k + ")" : "")
            })
            SvgScene.update_all(child)
            @g.add_element(@e) if(!@e.parent)
            @e=nil
          }
          SvgScene.scale=k
          @e=self.stroke(@e,scenes,i)
          
          return @e
        end
      end
    end
  end
end
