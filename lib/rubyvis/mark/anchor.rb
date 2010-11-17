module Rubyvis
  # Alias por Rubyvis::Anchor.new(target)
  def self.Anchor(target)
    Rubyvis::Anchor.new(target)
  end
  # Represents an anchor on a given mark. An anchor is itself a mark, but
  # without a visual representation. It serves only to provide useful default
  # properties that can be inherited by other marks. Each type of mark can define
  # any number of named anchors for convenience. If the concrete mark type does
  # not define an anchor implementation specifically, one will be inherited from
  # the mark's parent class.
  #
  # For example, the bar mark provides anchors for its four sides: left,
  # right, top and bottom. Adding a label to the top anchor of a bar,
  #
  #   bar.anchor("top").add(Rubyvis::Label)
  #
  # will render a text label on the top edge of the bar; the top anchor defines
  # the appropriate position properties (top and left), as well as text-rendering
  # properties for convenience (text_align and text_baseline).
  #
  # <p>Note that anchors do not <i>inherit</i> from their targets; the positional
  # properties are copied from the scene graph, which guarantees that the anchors
  # are positioned correctly, even if the positional properties are not defined
  # deterministically. (In addition, it also improves performance by avoiding
  # re-evaluating expensive properties.) If you want the anchor to inherit from
  # the target, use Mark#extend before adding. For example:
  #
  #   bar.anchor("top").extend(bar).add(Rubyvis::Label)
  #
  # The anchor defines it's own positional properties, but other properties (such
  # as the title property, say) can be inherited using the above idiom. Also note
  # that you can override positional properties in the anchor for custom
  # behavior.
  class Anchor < Mark
    # List of properties common to all Anchors
    @properties=Mark.properties.dup
    
    ##
    # :attr: name
    # The anchor name. The set of supported anchor names is dependent on the
    # concrete mark type; see the mark type for details. For example, bars support
    # left, right, top and bottom anchors.
    #
    # While anchor names are typically constants, the anchor name is a true
    # property, which means you can specify a function to compute the anchor name
    # dynamically. For instance, if you wanted to alternate top and bottom anchors, saying
    #
    #   m.anchor(lambda {(index % 2) ? "top" : "bottom"}).add(Rubyvis::Dot)
    #
    # would have the desired effect.
    
    #
    attr_accessor_dsl [:name, lambda {|d| d.to_s}]
    
    # Create a new Anchor. Use Mark.add instead.
    
    def initialize(target)
      
      self.target=target
      self.parent=target.parent
      super()
    end
    
    # Sets the prototype of this anchor to the specified mark. Any properties not
    # defined on this mark may be inherited from the specified prototype mark, or
    # its prototype, and so on. The prototype mark need not be the same type of
    # mark as this mark. (Note that for inheritance to be useful, properties with
    # the same name on different mark types should have equivalent meaning.)
    #
    # <p>This method differs slightly from the normal mark behavior in that the
    # anchor's target is preserved.
    #
    # @param {Rubyvis::Mark} proto the new prototype.
    # @returns {Rubyvis::Anchor} this anchor.
    # @see Rubyvis.Mark#add
    
    def mark_extend(proto)
      @proto=proto
      self
    end
  end
end
