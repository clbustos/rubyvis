module Rubyvis
  # Alias for Rubyvis::Rule
  def self.Rule
    Rubyvis::Rule
  end
  class Rule < Mark
    include LinePrototype
    @properties=Mark.properties.dup
    attr_accessor_dsl :width, :height, :line_width, [:stroke_style, lambda {|d| Rubyvis.color(d)}]
    def self.defaults
      Rule.new.mark_extend(Mark.defaults).line_width(1).stroke_style('black').antialias(false)
    end
    
    def type
      'rule'
    end

    def anchor(name)
      line_anchor(name)
    end
    def build_implied(s)
      l=s.left
      r=s.right
      #t=s.top
      #b=s.bottom
      
      if((!s.width.nil?) or ((l.nil?) and (r.nil?)) or ((!r.nil?) and (!l.nil?)))
        s.height=0
      else
        s.width=0
      end
      mark_build_implied(s)
    end
  end
end
