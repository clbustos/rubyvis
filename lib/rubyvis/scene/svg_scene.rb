require 'rubyvis/scene/svg_panel'
require 'rubyvis/scene/svg_bar'

module Rubyvis
  def self.Scene
    Rubyvis::SvgScene
  end
  module SvgScene
    include REXML
    def self.svg
      "http://www.w3.org/2000/svg"
    end;
    def self.xmlns
      "http://www.w3.org/2000/xmlns"
    end
    def self.xlink
      "http://www.w3.org/1999/xlink"
    end
    def self.xhtml 
      "http://www.w3.org/1999/xhtml"
    end
    @scale=1
    def self.scale
      @scale
    end
    def self.scale=(v)
      @scale=v
    end
    def self.implicit
      svg={
      "shape-rendering"=> "auto",
      "pointer-events"=> "painted",
      "x"=> 0,
      "y"=> 0,
      "dy"=> 0,
      "text-anchor"=> "start",
      "transform"=> "translate(0,0)",
      "fill"=> "none",
      "fill-opacity"=> 1,
      "stroke"=> "none",
      "stroke-opacity"=> 1,
      "stroke-width"=> 1.5,
      "stroke-linejoin"=> "miter"
    }
    css={"font"=>"10px sans-serif"}
    
    {:svg=>svg,css=>css}
    end
    def self.update_all(scenes)
      scenes.each {|s|
        p s
        puts "***"
        
      }
      if (scenes.size>0 and scenes[0].reverse and scenes.type!='line' and scenes.type!='area')
        scenes=scenes.reverse
      end
      
      self.remove_siblings(self.send(scenes.type, scenes))
    end
    def self.remove_siblings(e)
      while(e)
        
      end
    end
    def self.create(type)
      Element.new "svg:#{type}"
    end
    
    def self.append(e,scenes,index)
      #e._scene=OpenStruct.new({:scenes=>scenes, :index=>index})
      #e=self.title
      if(!e.parent)
        scenes._g.add_element(e)
      end
      return e
    end
    
    def self.expect(e, type, attributes, style=nil) 
      
      if (e)
        e = e.elements[1] if (e.name == "a") 
        if (e.name != type) 
          n = self.create(type);
          e.parent.replace_child(e, n);
          e = n
        end
      else
        e = self.create(type)
      end
      attributes.each {|name,value|
        value = nil if (value == self.implicit[:svg][name])
        if (value.nil?) 
          e.delete_attribute(name) 
        else 
          e.attributes[name]=value
        end
      }
      if(style)
        style.each {|name,value|
          value=nil if value==self.implicit[:css][name]
          
          if (value.nil?)
            e.delete_attribute(name)
          else
            e.style[name] = value;
          end
        }
      end
      e
    end
    
  end
end