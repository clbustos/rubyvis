module Rubyvis
  def self.Anchor(target)
    Rubyvis::Anchor.new(target)
  end
  
  class Anchor < Mark
    @properties=Mark.properties.dup
    attr_accessor_dsl :name, :text_align, :text_baseline
    
    def initialize(target)
      super()
      self.target=target
      self.parent=target.parent
    end
    def extend(proto)
      @proto=proto
      return self
    end
  end
end