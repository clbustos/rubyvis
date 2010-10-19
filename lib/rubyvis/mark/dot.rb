module Rubyvis
  def self.Dot
    Rubyvis::Dot
  end
  class Dot < Mark
    def type
      "dot"
    end

    @properties=Mark.properties.dup
    
    attr_accessor_dsl :shape, :shape_angle, :shape_radius, :shape_size, :line_width, [:stroke_style, lambda {|d| pv.color(d)}], [:fill_style, lambda {|d| pv.color(d)}]
    
    def self.defaults()
      a=Rubyvis::Colors.category10
      Dot.new().extend(Mark.defaults).shape("circle"). line_width(1.5). stroke_style(lambda {a.scale(self.parent.index)})
    end
    
    def anchor(name)
      
      
      mark_anchor(name).left(lambda {
        s=scene.target[self.index]
        case self.name
          when 'bottom' then s.left;
          when 'top' then s.left;
          when 'center' then s.left;
          when 'left' then nil;
          else
            s.left+s.shape_radius
        end
      }).right(lambda {
        s=scene.target[self.index]
        self.name()=='left' ? s.right+s.shape_radius : nil
      }).top(lambda {
        s=scene.target[self.index]
        case self.name
          when 'left' then  s.top;
          when 'right' then s.top;
          when 'center' then s.top;
          when 'top' then nil;
          else
            s.top+s.shape_radius
        end
      }).bottom(lambda {
        s=scene.target[self.index]
        self.name()=='top' ? s.bottom+s.shape_radius : nil
      }).text_align(lambda {
        case self.name
          when 'left' then  'right';
          when 'bottom' then 'center';
          when 'top' then 'center';
          when 'center' then 'center';
          else
            'left'
        end
      }).text_baseline( lambda {
        case self.name
          when 'right' then  'middle';
          when 'left' then 'middle';
          when 'center' then 'middle';
          when 'bottom' then 'top';
          else
            'bottom'
        end
      
      })
    end
    def build_implied(s)
      r = s.shape_radius
      z = s.shape_size
      if (r.nil?) 
        if (z.nil?) 
          s.shape_size = 20.25;
          s.shape_radius = 4.5;
        else
          s.shape_radius = Math.sqrt(z)
        end
      elsif (z.nil?) 
        s.shape_size = r * r;
      end
      mark_build_implied(s)
    end
  end
end
