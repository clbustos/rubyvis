module Rubyvis
  module SvgScene
    def self.panel(scenes)
      puts " -> panel: #{scenes.inspect}" if $DEBUG
      g=scenes._g
      #e=(g.nil?) ? nil : g.elements[1]
      e=(g.nil?) ? nil : g.get_element(1) 
      if g
        #e=g.elements[1]
        e=g.get_element(1)
      end
      scenes.each_with_index do |s,i|
        next unless s.visible

        if(!scenes.parent)
          if g and g.parent!=s.canvas
            #g=s.canvas.elements[1]
            g=s.canvas.get_element(1)
            #e=(@g.nil?) ? nil : @g.elements[1]
            e=(@g.nil?) ? nil : @g.get_element(1)
          end
          if(!g)
            g=s.canvas.add_element(self.create('svg'))
            g.set_attributes(
              {
                'font-size'=>"10px",
                'font-family'=>'sans-serif',
                'fill'=>'none',
                'stroke'=>'none',
                'stroke-width'=>1.5
              }
            )
            e=g.get_element(1)
            # g.attributes["font-size"]="10px"
            # g.attributes["font-family"]="sans-serif"
            # g.attributes["fill"]="none"
            # g.attributes["stroke"]="none"
            # g.attributes["stroke-width"]=1.5
            # e=g.elements[1]
          end
          scenes._g=g
          #p s
          g.set_attributes({
              'width'=>s.width+s.left+s.right,
              'height'=>s.height+s.top+s.bottom
          })
          #g.attributes['width']=s.width+s.left+s.right
          #g.attributes['height']=s.height+s.top+s.bottom
        end
        if s.overflow=='hidden'
          id=Rubyvis.id.to_s(36)
          c=self.expect(e,'g',{'clip-path'=>'url(#'+id+')'});
          g.add_element(c) if(!c.parent)
          scenes._g=g=c
          #e=c.elements[1]
          e=c.get_element(1)
          e=self.expect(e,'clipPath',{'id'=>id})
          #r=(e.elements[1]) ? e.elements[1] : e.add_element(self.create('rect'))
          r=(e.get_element(1)) ? e.get_element(1) : e.add_element(self.create('rect'))
          r.set_attributes({
              'x'=>s.left,
              'y'=>s.top,
              'width'=>s.width,
              'height'=>s.height
          })
          #r.attributes['x']=s.left
          #r.attributes['y']=s.top
          #r.attributes['width']=s.width
          #r.attributes['height']=s.height
          g.add_element(e) if !e.parent
          e=e.next_sibling_node

        end
        # fill
        e=self.fill(e,scenes, i)
        # transform
        k=self.scale
        t=s.transform
        x=s.left+t.x
        y=s.top+t.y
        SvgScene.scale=SvgScene.scale*t.k
        # children
        s.children.each_with_index {|child, i2|
          child._g=e=SvgScene.expect(e, "g", {
            "transform"=> "translate(" + x.to_s + "," + y.to_s + ")" + (t.k != 1 ? " scale(" + t.k.to_s + ")" : "")
          })
          SvgScene.update_all(child)
          g.add_element(e) if(!e.parent)
          e=e.next_sibling_node
        }
        # transform (pop)
        SvgScene.scale=k
        # stroke
        e=SvgScene.stroke(e,scenes,i)
        # clip
        if (s.overflow=='hidden')
          scenes._g=g=c.parent
          e=c.next_sibling_node
        end
      end
      return e
      
    end



    def self.fill(e,scenes,i)
      s=scenes[i]
      fill=s.fill_style
      if(fill.opacity>0 or s.events=='all')
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


    def self.stroke(e, scenes, i)
      s = scenes[i]
      stroke = s.stroke_style
      if (stroke.opacity>0 or s.events == "all")
        e = self.expect(e, "rect", {
          "shape-rendering"=> s.antialias ? nil : "crispEdges",
          "pointer-events"=> s.events == "all" ? "stroke" : s.events,
          "cursor"=> s.cursor,
          "x"=> s.left,
          "y"=> s.top,
          "width"=> [1E-10, s.width].max,
          "height"=>[1E-10, s.height].max,
          "fill"=>"none",
          "stroke"=> stroke.color,
          "stroke-opacity"=> stroke.opacity,
          "stroke-width"=> s.line_width / self.scale.to_f
        });
        e = self.append(e, scenes, i);
      end
      return e
    end
  end
end
