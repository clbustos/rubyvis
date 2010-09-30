module Rubyvis
  def self.Anchor(target)
    Rubyvis::Anchor.new(target)
  end
  
  class Anchor < Mark
    @properties=Mark.properties
    attr_accessor_dsl :name, :text_baseline, :text_align
    def type
      'area'
    end
    def initialize(target)
      super()
      self.target=target
      self.parent=target.parent
    end
    def _extend(proto)
      self.proto=proto
      return self
    end
  end
end