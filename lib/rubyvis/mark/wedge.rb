module Rubyvis
  # Alias for Rubyvis::Wedge
  def self.Wedge
    Rubyvis::Wedge
  end
  class Wedge < Mark
    def type
      "wedge"
    end
    @properties=Mark.properties.dup
    
    attr_accessor_dsl :start_angle, :end_angle, :angle, :inner_radius, :outer_radius, :line_width, [:stroke_style, lambda {|d| Rubyvis.color(d)}], [:fill_style, lambda {|d| Rubyvis.color(d)}]
    
    def self.defaults
      a=Rubyvis.Colors.category20()
      Wedge.new.mark_extend(Mark.defaults).start_angle(lambda  {s=self.sibling; s ? s.end_angle: -Math::PI.quo(2) } ).inner_radius( 0 ).line_width( 1.5 ).stroke_style( nil ).fill_style( lambda {a.scale(self.index)})
    end
    def mid_radius
      (inner_radius+outer_radius) / 2.0
    end
    def mid_angle
      (start_angle+end_angle) / 2.0
    end
    
    def anchor(name)
      that=self
      partial=lambda {|s| s.inner_radius!=0 ? true : s.angle < 2*Math::PI}
      mid_radius=lambda {|s| (s.inner_radius+s.outer_radius) / 2.0}
      mid_angle=lambda {|s| (s.start_angle+s.end_angle) / 2.0 }
      
      mark_anchor(name).left(lambda {
        s = self.scene.target[self.index];
        if (partial.call(s))
          case (self.name()) 
          when "outer"
            s.left + s.outer_radius * Math.cos(mid_angle.call(s))
          when "inner"
            s.left + s.inner_radius * Math.cos(mid_angle.call(s))
          when "start"
            s.left + mid_radius.call(s) * Math.cos(s.start_angle)
          when "center"
            s.left + mid_radius.call(s) * Math.cos(mid_angle.call(s))
          when "end"
            s.left + mid_radius.call(s) * Math.cos(s.end_angle)
          else
            s.left
          end
        else
          s.left
        end        
      }).top(lambda {
        s = self.scene.target[self.index];
        if (partial.call(s))
          case (self.name()) 
          when "outer"
            s.top + s.outer_radius * Math.sin(mid_angle.call(s))
          when "inner"
            s.top + s.inner_radius * Math.sin(mid_angle.call(s))
          when "start"
            s.top + mid_radius.call(s) * Math.sin(s.start_angle)
          when "center"
            s.top + mid_radius.call(s) * Math.sin(mid_angle.call(s))
          when "end"
            s.top + mid_radius.call(s) * Math.sin(s.end_angle)
          else
            s.top
          end
        else
          s.top
        end
          
      }).text_align(lambda {
      s = self.scene.target[self.index];
        if (partial.call(s))
          case (self.name()) 
          when 'outer'
            that.upright(mid_angle.call(s)) ? 'right':'left'
          when 'inner'
            that.upright(mid_angle.call(s)) ? 'left':'right'
          else 
            'center'
          end
        else
          'center'
        end
      }).text_baseline(lambda {
      s = self.scene.target[self.index];
        if (partial.call(s))
          case (self.name()) 
          when 'start'
            that.upright(s.start_angle) ? 'top':'bottom'
          when 'end'
            that.upright(s.end_angle) ? 'bottom':'top'
          else
            'middle'
          end
        else
          'middle'
        end
      }).text_angle(lambda {
        s = self.scene.target[self.index];
        a=0
        if (partial.call(s))
          case (self.name()) 
          when 'center'
            a=mid_angle.call(s)
          when 'inner'
            a=mid_angle.call(s)
          when 'outer'
            a=mid_angle.call(s)
          when 'start'
            a=s.start_angle
          when 'end'
            a=s.end_angle
          end
        end
        that.upright(a) ? a: (a+Math::PI) 
      })
      
    end
    
    def self.upright(angle)
      angle=angle % (2*Math::PI)
      angle=(angle<0) ? (2*Math::PI+angle) : angle
      (angle < Math::PI/2.0) or (angle>=3*Math::PI / 2.0)  
      
    end
    def upright(angle)
      angle=angle % (2*Math::PI)
      angle=(angle<0) ? (2*Math::PI+angle) : angle
      (angle < Math::PI/2.0) or (angle>=3*Math::PI / 2.0)  
    end
    
    def build_implied(s)
      
      if s.angle.nil?
        s.angle = s.end_angle - s.start_angle 
      elsif s.end_angle.nil?
        s.end_angle = s.start_angle + s.angle
      end
      
      mark_build_implied(s)
    end
  end
end
