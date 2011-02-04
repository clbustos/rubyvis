require 'rubyvis/scene/svg_panel'
require 'rubyvis/scene/svg_bar'
require 'rubyvis/scene/svg_rule'
require 'rubyvis/scene/svg_label'
require 'rubyvis/scene/svg_line'
require 'rubyvis/scene/svg_dot'
require 'rubyvis/scene/svg_area'
require 'rubyvis/scene/svg_wedge'
require 'rubyvis/scene/svg_image'
require 'rubyvis/scene/svg_curve'

class REXML::Element #:nodoc:
  attr_accessor :_scene
  # 1 number based
  def get_element(i)
    elements[i]
  end
  def set_attributes(h)
    h.each do |k,v|
      attributes[k]=v
    end
  end
  #private :attributes
  #private :elements
end

module Nokogiri
  module XML
    class Node
  attr_accessor :_scene
  def add_element(c)
    add_child(c)
  end
  
  def set_attributes(h)
    h.each do |k,v|
      set_attribute(k,v.to_s)
    end
  end
  def get_element(i)
    elements[i-1]
  end
  #private :elements
  #private :attributes
  def next_sibling_node
    next_sibling
  end
  def delete_attribute(name)
    remove_attribute(name)
  end
  def text
    content
  end
  def text=(v)
    self.content=v
  end
  end
end
end

module Rubyvis
  module SvgScene # :nodoc:
    #include REXML
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
    IMPLICIT={:svg=>{
        "shape-rendering"=> "auto",
        "pointer-events"=> "painted",
        "x"=> 0,
        "y"=> 0,
        "dy"=> 0,
        "text-anchor"=> "start",
        "transform"=> "translate(0,0)",
        #"fill"=> "none",
        "fill-opacity"=> 1,
        "stroke"=> "none",
        "stroke-opacity"=> 1,
        "stroke-width"=> 1.5,
        "stroke-linejoin"=> "miter"
      },:css=>{"font"=>"10px sans-serif"}
    }
    
    def self.update_all(scenes)
      puts "update_all: #{scenes.inspect}" if $DEBUG
      if (scenes.size>0 and scenes[0].reverse and scenes.type!='line' and scenes.type!='area')
        scenes=scenes.reverse
      end
      self.remove_siblings(self.send(scenes.type, scenes))
    end
    def self.remove_siblings(e)
      while(e)
        n=e.next_sibling_node
        e.remove
        e=n
      end
    end
    def self.create(type)
      if Rubyvis.xml_engine==:nokogiri
        el=Rubyvis.nokogiri_document.create_element("#{type}")
        if type=='svg'
          el.add_namespace(nil, self.svg)
          el.add_namespace('xlink', self.xlink)
        end
      else
        el=REXML::Element.new "#{type}"
        if type=='svg'
          el.add_namespace(self.svg)
          #el.add_namespace("xmlns:xmlns", self.xmlns)
          el.add_namespace("xmlns:xlink", self.xlink)
        end
      end
      el
    end

    def self.append(e,scenes,index)
      e._scene=OpenStruct.new({:scenes=>scenes, :index=>index})
      e=self.title(e, scenes[index])
      if(!e.parent)
        scenes._g.add_element(e)
      end
      e.next_sibling_node
    end
    
    # Applies a title tooltip to the specified element <tt>e</tt>, using the
    # <tt>title</tt> property of the specified scene node <tt>s</tt>. Note that
    # this implementation does not create an SVG <tt>title</tt> element as a child
    # of <tt>e</tt>; although this is the recommended standard, it is only
    # supported in Opera. Instead, an anchor element is created around the element
    # <tt>e</tt>, and the <tt>xlink:title</tt> attribute is set accordingly.
    #
    # @param e an SVG element.
    # @param s a scene node.
    
    def self.title(e,s)
      a = e.parent
      a=nil if (a and (a.tag_name != "a"))
      if (s.title) 
        if (!a) 
          a = self.create("a")
          e.parent.replace_child(a, e) if (e.parent)
          a.add_element(e)
        end
        #a.add_attribute('xlink:title',s.title)
        a.set_attributes('xlink:title' => s.title)

        return a;
      end
      a.parent_node.replace_child(e, a) if (a) 
      e
    end
    
    def self.expect(e, type, attributes, style=nil)

      if (e)
        #e = e.elements[1] if (e.name == "a")
        e=e.get_element(1) if (e.name == 'a')
        if (e.name != type)
          n = self.create(type);
          e.parent.replace_child(e, n);
          e = n
        end
      else
        e = self.create(type)
      end
      attributes.each {|name,value|
        value = nil if (value == IMPLICIT[:svg][name])
        if (value.nil?)
          e.delete_attribute(name)
        else
          e.set_attributes(name=>value)
          #e.attributes[name]=value
        end
      }
      
      if(style)
        base_style=e.attributes['style']
        base_style||=""
        array_styles={}
        base_style.split(";").each {|v|
          v=~/\s*(.+)\s*:\s*(.+)/
          array_styles[$1]=$2
        }
        style.each {|name,value|
          value=nil if value==IMPLICIT[:css][name]
          if (value.nil?)
            array_styles.delete(name)
          else
            array_styles[name]=value
          end
        }
        if array_styles.size>0
          #e.attributes["style"]=array_styles.map {|k,v| "#{k}:#{v}"}.join(";")
          e.set_attributes('style'=> array_styles.map {|k,v| "#{k}:#{v}"}.join(";"))
        end
      end
      e
    end

  end
end
