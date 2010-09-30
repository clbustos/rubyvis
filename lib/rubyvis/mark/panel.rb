module Rubyvis
  def self.Panel
    Rubyvis::Panel
  end    
  class Panel < Bar
    def type
      "panel"
    end

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