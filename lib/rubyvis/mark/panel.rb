module Rubyvis
  # Alias for Rubyvis::Panel
  def self.Panel
    Rubyvis::Panel
  end
  class Panel < Bar
    def type
      "panel"
    end

    @properties=Bar.properties.dup
    attr_accessor_dsl :transform, :overflow, :canvas
    attr_accessor :children, :root
    def initialize
      @children=[]
      @root=self
      super
      
    end
    def children_inspect(level=0)
      out=[]
      @children.each do |c|
        out << ("  "*level)+"- #{c.type} (#{c.object_id}) proto:#{c.proto.object_id} target:#{c.target.object_id}"
        if c.respond_to? :children and c.children
          out << c.children_inspect(level+1)
        end
      end
      out

    end

    def self.defaults
      Panel.new.mark_extend(Bar.defaults).fill_style(nil).overflow('visible')
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
    def anchor(name)
      anchor=mark_anchor(name)
      anchor.parent=self
      anchor
    end
    def build_instance(s)
      super(s)
      return if !s.visible
      s.children=[] if !s.children
      scale=self.scale * s.transform.k
      n=self.children.size
      Mark.index=-1
      n.times {|i|
        child=children[i]
        child.scene=s.children[i]
        child.scale=scale
        child.build
      }
      n.times {|i|
        child=children[i]
        s.children[i]=child.scene
        child.scene=nil
        child.scale=nil
      }
      s.children=s.children[0,n]

    end

    def to_svg
      if Rubyvis.xml_engine==:nokogiri
        @_canvas.sort.map {|v|
          v[1].get_element(1).to_xml(:indent => 5, :encoding => 'UTF-8')
        }.join
      else
        @_canvas.sort.map {|v|
          bar = REXML::Formatters::Default.new
          out = String.new
          bar.write(v[1].elements[1], out)
        }.join
      end
    end
    def build_implied(s)
      panel_build_implied(s)
    end
    def panel_build_implied(s)
      if(!self.parent)
        c=s.canvas
        if(c)
          if(c._panel!=self)
            c._panel=self
            c.delete_if? {true}
          end
          if s.width.nil?
            w=Rubyvis.css(c,'width')
            s.width=w - s.left - s.right
          end
          if s.height.nil?
            w=Rubyvis.css(c,'height')
            s.height=h - s.top - s.bottom
          end

        else
          @_canvas||={}
          cache=@_canvas
          if(!(c=cache[self.index]))
          
          if Rubyvis.xml_engine==:nokogiri
            document=Nokogiri::XML::Document.new
            document.root=document.create_element('document')
            Rubyvis.nokogiri_document(document)
          else
            document=REXML::Document.new
            document.add_element("document")            
          end
            cache[self.index]=document.root
            c=cache[self.index]
            
            #c=cache[self.index]=Rubyvis.document.add_element('span')
          end
        end
        s.canvas=c
      end
      s.transform=Rubyvis.Transform.identity if (s.transform.nil?)
      mark_build_implied(s)
    end

  end
end
