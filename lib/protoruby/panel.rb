module Protoruby
  def self.Panel
    Protoruby::Panel
  end    
  class Panel < Bar
    @properties={}
    attr_accessor :children, :root
    def initialize
      @children=[]
      @root=self
    end
    property(:transform).
    property(:overflow).
    property(:canvas)
    def type
      "panel"
    end
    def defaults
      Panel.new
      ._extend(Bar.new.default)
      .fill_style(nil)
      .overflow("visible")
    end
    def anchor(name)
      a=super(name)
      a.parent=self
      a
    end
    def add(type)
      child=type.new
      child.parent=self
      child.root=root
      child.child_index=children.lenght
      children.push(child)
      child
    end
  end
end