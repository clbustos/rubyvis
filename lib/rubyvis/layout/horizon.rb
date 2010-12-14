module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Horizon
    def self.Horizon
      Rubyvis::Layout::Horizon
    end
    
    # Implements a horizon layout, which is a variation of a single-series
    # area chart where the area is folded into multiple bands. Color is used to
    # encode band, allowing the size of the chart to be reduced significantly
    # without impeding readability. This layout algorithm is based on the work of
    # J. Heer, N. Kong and M. Agrawala in <a
    # href="http://hci.stanford.edu/publications/2009/heer-horizon-chi09.pdf">"Sizing
    # the Horizon: The Effects of Chart Size and Layering on the Graphical
    # Perception of Time Series Visualizations"</a>, CHI 2009.
    #
    # <p>This layout exports a single <tt>band</tt> mark prototype, which is
    # intended to be used with an area mark. The band mark is contained in a panel
    # which is replicated per band (and for negative/positive bands). For example,
    # to create a simple horizon graph given an array of numbers:
    #
    #   vis.add(Rubyvis::Layout::Horizon)
    #     .bands(n)
    #   .band.add(Rubyvis::Area)
    #     .data(data)
    #     .left(lambda { index * 35})
    #     .height(lambda {|d| d * 40})
    #
    # The layout can be further customized by changing the number of bands, and
    # toggling whether the negative bands are mirrored or offset. (See the
    # above-referenced paper for guidance.)
    #
    # <p>The <tt>fill_style</tt> of the area can be overridden, though typically it
    # is easier to customize the layout's behavior through the custom
    # <tt>background_style</tt>, <tt>positive_style</tt> and <tt>negative_style</tt>
    # properties. By default, the background is white, positive bands are blue, and
    # negative bands are red. For the most accurate presentation, use fully-opaque
    # colors of equal intensity for the negative and positive bands.
    class Horizon < Layout
      @properties=Layout.properties.dup      
      # The band prototype. This prototype is intended to be used with an Area
      # mark to render the horizon bands.
      attr_accessor :band
      def initialize
        super
        @_bands=nil # cached bands
        @_mode=nil # cached mode
        @_size=nil # cached height
        @_fill=nil # cached background style
        @_red=nil # cached negative color (ramp)
        @_blue=nil # cached positive color (ramp)
        @bands=_bands
        @band=_band
      end
      def build_implied(s)
        layout_build_implied(s) 
        @_bands=s.bands
        @_mode=s.mode
        @_size=((mode == "color" ? 0.5 : 1) * s.height).round
        @_fill=s.background_style
        @_red=Rubyvis.ramp(@_fill, s.negative_style).domain(0,@_bands)
        @_blue=Rubyvis.ramp(@_fill, s.positive_style).domain(0,@_bands)
        
      end
      def _bands
        Rubyvis::Panel.new().
        data(lambda {Rubyvis.range(@_bands * 2)}).
        overflow("hidden").
        height(lambda {@_size}).
        top(lambda {|i| @_mode=='color' ? (i & 1) * @_size : 0 }).
        fill_style(lambda {|i| i ? nil : @_fill})
      end
      
      def _band
        m=Rubyvis::Mark.new().
        top(lambda  {|d,i|
            @_mode == ("mirror" and (i & 1)!=0) ? (i + 1 >> 1) * @_size : nil
        }).
        bottom(lambda {|d,i|
            @_mode == "mirror" ? ((i & 1)!=0 ? nil : (i + 1 >> 1) * -@_size)
              : ((i & 1 or -1) * (i + 1 >> 1) * @_size)
        }).
        fill_style(lambda {|d,i|
          return ((i & 1)!=0 ? @_red : @_blue)[(i >> 1) + 1]
        })
        
        class << m # :nodoc:
          def that=(v)
            @that = v
          end
          def add(type)
            bands=@_bands
            that  = @that
            that.add( Rubyvis.Panel ).mark_extend(bands). add(type). mark_extend(self)
          end
        end
        
        m.that=self
        m
      end
      
      ##
      # :attr: mode
      # The horizon mode: offset, mirror, or color. The default is "offset".
      
      ##
      # :attr: bands
      # The number of bands. Must be at least one. The default value is two.
      #
      
      ##
      # :attr: positive_style
      # The positive band color; if non-null, the interior of positive bands are
      # filled with the specified color. The default value of this property is blue.
      # For accurate blending, this color should be fully opaque.
      #
      
      ##
      # :attr: negative_style
      # The negative band color; if non-null, the interior of negative bands are
      # filled with the specified color. The default value of this property is red.
      # For accurate blending, this color should be fully opaque.
      #
      
      ##
      # :attr: background_style
      # The background color. The panel background is filled with the specified
      # color, and the negative and positive bands are filled with an interpolated
      # color between this color and the respective band color. The default value of
      # this property is white. For accurate blending, this color should be fully
      # opaque.
      #
      
      attr_accessor_dsl :bands, :mode, :background_style, [:background_style, lambda {|d| Rubyvis.color(d)}], [:positive_style, lambda {|d| Rubyvis.color(d)}], [:negative_style, lambda {|d| Rubyvis.color(d)}]

      # Default properties for horizon layouts. By default, there are two bands, the
      # mode is "offset", the background style is "white", the positive style is
      # blue, negative style is red.
      def self.defaults
        Horizon.new.mark_extend(Layout.defaults).
          bands(2).
          mode('offset').
          background_style('white').
          positive_style('#1f77b4').
          negative_style('#d62728')
      end
    end
  end
end

