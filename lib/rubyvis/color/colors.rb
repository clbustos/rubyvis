module Rubyvis
  #
  # :section: colors/Ramp.js
  
  
  # Returns a linear color ramp from the specified <tt>start</tt> color to the
  # specified <tt>end</tt> color. The color arguments may be specified either as
  # <tt>string</tt>s or as Rubyvis::Color. This is equivalent to:
  #
  # <pre>    pv.Scale.linear().domain(0, 1).range(...)</pre>  
  def self.ramp(*arguments)
    #start, _end, dummy = arguments
    scale = Rubyvis.Scale.linear
    scale.range(*arguments)
    scale
  end
  
  # :section: colors/Colors.js
  
  # Alias for Rubyvis::Colors
  def self.Colors
    Rubyvis::Colors
  end
  
  # Returns a new categorical color encoding using the specified colors.  The
  # arguments to this method are an array of colors; see Rubyvis.color(). For
  # example, to create a categorical color encoding using the <tt>species</tt>
  # attribute:
  #
  # <pre>Rubyvis.colors("red", "green", "blue").by(lambda{|d| d.species})</pre>
  #
  # The result of this expression can be used as a fill- or stroke-style
  # property. This assumes that the data's <tt>species</tt> attribute is a
  # string.
  #
  def self.colors(*args)
    scale=Rubyvis::Scale.ordinal
    scale.range(*args)
    scale
  end
  
  # A collection of standard color palettes for categorical encoding.
  module Colors
    
    # Returns a new 10-color scheme. The arguments to this constructor are
    # optional, and equivalent to calling Rubyvis::Scale::Ordinal.domain. The
    # following colors are used:
    #
    # <div style="background:#1f77b4;">#1f77b4</div>
    # <div style="background:#ff7f0e;">#ff7f0e</div>
    # <div style="background:#2ca02c;">#2ca02c</div>
    # <div style="background:#d62728;">#d62728</div>
    # <div style="background:#9467bd;">#9467bd</div>
    # <div style="background:#8c564b;">#8c564b</div>
    # <div style="background:#e377c2;">#e377c2</div>
    # <div style="background:#7f7f7f;">#7f7f7f</div>
    # <div style="background:#bcbd22;">#bcbd22</div>
    # <div style="background:#17becf;">#17becf</div>
    def self.category10(*arguments)
      scale = Rubyvis.colors(
      "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
      "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")
      scale.domain(*arguments) if arguments.size>0
      scale
    end
    
    # Returns a new alternative 19-color scheme. The arguments to this constructor
    # are optional, and equivalent to calling
    # Rubyvis::Scale::Ordinal.domain. The following colors are used:
    #
    # <div style="background:#9c9ede;">#9c9ede</div>
    # <div style="background:#7375b5;">#7375b5</div>
    # <div style="background:#4a5584;">#4a5584</div>
    # <div style="background:#cedb9c;">#cedb9c</div>
    # <div style="background:#b5cf6b;">#b5cf6b</div>
    # <div style="background:#8ca252;">#8ca252</div>
    # <div style="background:#637939;">#637939</div>
    # <div style="background:#e7cb94;">#e7cb94</div>
    # <div style="background:#e7ba52;">#e7ba52</div>
    # <div style="background:#bd9e39;">#bd9e39</div>
    # <div style="background:#8c6d31;">#8c6d31</div>
    # <div style="background:#e7969c;">#e7969c</div>
    # <div style="background:#d6616b;">#d6616b</div>
    # <div style="background:#ad494a;">#ad494a</div>
    # <div style="background:#843c39;">#843c39</div>
    # <div style="background:#de9ed6;">#de9ed6</div>
    # <div style="background:#ce6dbd;">#ce6dbd</div>
    # <div style="background:#a55194;">#a55194</div>
    # <div style="background:#7b4173;">#7b4173</div>
    def self.category19(*arguments)
      scale = Rubyvis.colors(
      "#9c9ede", "#7375b5", "#4a5584", "#cedb9c", "#b5cf6b",
      "#8ca252", "#637939", "#e7cb94", "#e7ba52", "#bd9e39",
      "#8c6d31", "#e7969c", "#d6616b", "#ad494a", "#843c39",
      "#de9ed6", "#ce6dbd", "#a55194", "#7b4173")
      scale.domain(*arguments) if arguments.size>0
      scale
    end
    

    # Returns a new 20-color scheme. The arguments to this constructor are
    # optional, and equivalent to calling Rubyvis::Scale::Ordinal.domain. The
    # following colors are used:
    #
    # <div style="background:#1f77b4;">#1f77b4</div>
    # <div style="background:#aec7e8;">#aec7e8</div>
    # <div style="background:#ff7f0e;">#ff7f0e</div>
    # <div style="background:#ffbb78;">#ffbb78</div>
    # <div style="background:#2ca02c;">#2ca02c</div>
    # <div style="background:#98df8a;">#98df8a</div>
    # <div style="background:#d62728;">#d62728</div>
    # <div style="background:#ff9896;">#ff9896</div>
    # <div style="background:#9467bd;">#9467bd</div>
    # <div style="background:#c5b0d5;">#c5b0d5</div>
    # <div style="background:#8c564b;">#8c564b</div>
    # <div style="background:#c49c94;">#c49c94</div>
    # <div style="background:#e377c2;">#e377c2</div>
    # <div style="background:#f7b6d2;">#f7b6d2</div>
    # <div style="background:#7f7f7f;">#7f7f7f</div>
    # <div style="background:#c7c7c7;">#c7c7c7</div>
    # <div style="background:#bcbd22;">#bcbd22</div>
    # <div style="background:#dbdb8d;">#dbdb8d</div>
    # <div style="background:#17becf;">#17becf</div>
    # <div style="background:#9edae5;">#9edae5</div>

    def self.category20(*arguments)
      scale = Rubyvis.colors(
      "#1f77b4", "#aec7e8", "#ff7f0e", "#ffbb78", "#2ca02c",
      "#98df8a", "#d62728", "#ff9896", "#9467bd", "#c5b0d5",
      "#8c564b", "#c49c94", "#e377c2", "#f7b6d2", "#7f7f7f",
      "#c7c7c7", "#bcbd22", "#dbdb8d", "#17becf", "#9edae5")
      scale.domain(*arguments) if arguments.size>0
      scale
    end
  end
end
