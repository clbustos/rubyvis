module Rubyvis
  module SvgScene
    def self.image(scenes)
      #e=scenes._g.elements[1]
      e=scenes._g.get_element(1)
      scenes.each_with_index do |s,i|
        next unless s.visible
        e=self.fill(e,scenes,i)
        if s.image
          raise "Not implemented yet"
        else
          e = self.expect(e, "image", {
          "preserveAspectRatio"=> "none",
          "cursor"=> s.cursor,
          "x"=> s.left,
          "y"=> s.top,
          "width"=> s.width,
          "height"=> s.height
          })
          
          e.add_attribute("xlink:href", s.url);
        end
        e = self.append(e, scenes, i);
        
        #/* stroke */
        e = self.stroke(e, scenes, i);
      end
      e
    end
  end
end
