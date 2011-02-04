module Rubyvis
  module SvgScene
    def self.label(scenes)
      #e=scenes._g.elements[1]
      e=scenes._g.get_element(1)
      scenes.each_with_index do |s,i|
        next unless s.visible
        fill=s.text_style
        next if(fill.opacity==0 or s.text.nil?)
        x=0
        y=0
        dy=0
        anchor='start'
        case s.text_baseline
          when 'middle'
            dy=".35em"
          when "top"
            dy = ".71em"
            y = s.text_margin
          when "bottom"
            y = "-" + s.text_margin.to_s
        end
        
        case s.text_align
          when 'right'
            anchor = "end"
            x = "-" + s.text_margin.to_s
          when "center"
            anchor = "middle"
          when "left"
            x = s.text_margin
        end
        e=SvgScene.expect(e,'text', {
          "pointer-events"=> s.events,
          "cursor"=> s.cursor,
          "x"=> x,
          "y"=> y,
          "dy"=> dy,
          "transform"=> "translate(#{s.left},#{s.top})" + (s.text_angle!=0 ? " rotate(" + (180 * s.text_angle / Math::PI).to_s + ")" : "") + (self.scale != 1 ? " scale(" + 1 / self.scale + ")" : ""),
          "fill"=> fill.color,
          "fill-opacity"=> fill.opacity==0 ? nil : fill.opacity,
          "text-anchor"=> anchor
        }, {
        "font"=> s.font, "text-shadow"=> s.text_shadow, "text-decoration"=> s.text_decoration})
        
        e.text=s.text.frozen? ? s.text.dup : s.text


        e=SvgScene.append(e,scenes,i)

      end
      e
    end
  end
end
