module Rubyvis
  def self.Panel
    Rubyvis::Panel
  end    
  class Panel < Bar
    def type
      "panel"
    end

    @stack=[]
    @properties=Bar.properties
    attr_accessor_dsl :transform, :overflow, :canvas
    attr_accessor :children, :root
    def initialize
      super
      @children=[]
      @root=self
    end
    def defaults
      sd=super
      return sd.merge({:fill_style=>nil, :overflow=>'visible', :canvas=>Rubyvis.document.add_element("canvas")})
    end
    def add(type)
      child=type.new
      child.parent=self
      child.root=root
      child.child_index=children.size
      children.push(child)
      child
    end
    def svg_render_pre
      "<svg height='#{height}' width='#{width}' stroke-width='#{line_width}' stroke='#{stroke_style ? stroke_style : 'none'}' fill='#{fill_style ? fill_style: 'none'}' font-family='sans-serif' font-size='10px'><g>"
    end
    def svg_render_post
      "</g></svg>"
    end
    def naive_render
      out=svg_render_pre
      if respond_to? :children
        children.each do |c|
          out+=c.naive_render
        end
      end
      out+=svg_render_post
      out

    end
    attr_reader :_canvas
    def bind
      super
      children.each {|c|
        c.bind()
      }
    end
    def build_instance(s)
      super(s)
      return if !s.visible
      s.children=[] if !s.children
      scale=self.scale*s.transform.k
      n=self.children.size
      Mark.index=-1
      n.times {|i|
        child=children[i]
        child.scene=s.children[i]
        child.scale=scale
        child.build()
      }
      n.times {|i|
        child=children[i]
        s.children[i]=child.scene
        child.scene=nil
        child.scale=nil
      }
      s.children=s.children[0,n]
    end
    def build_implied(s)
      if(!self.parent)
        c=s.canvas
        if(c)
          if s.width.nil?
            w=Rubyvis.css(c,'width')
            s.width=w-s.left-s.right
          end
          if s.height.nil?
            w=Rubyvis.css(c,'height')
            s.height=h-s.top-s.bottom
          end
        else
          @_canvas||={}
          cache=@_canvas
          if(!(c=cache[self.index]))
            c=cache[this.index]=Rubyvis.add_element('span')
          end
        end
        s.canvas=c
      end
      
      s.transform=Rubyvis.Transform.identity if (s.transform.nil?)
      super(s)
      
    end
    
  end
end