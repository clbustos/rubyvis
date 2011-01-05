module Rubyvis
  # Returns the Rubyvis::Color for the specified color format string. Colors
  # may have an associated opacity, or alpha channel. 
  # Color formats are specified by CSS Color Modular Level 3, 
  # using either in RGB or HSL color space. For example:<ul>
  #
  # <li>#f00 // #rgb
  # <li>#ff0000 // #rrggbb
  # <li>rgb(255, 0, 0)
  # <li>rgb(100%, 0%, 0%)
  # <li>hsl(0, 100%, 50%)
  # <li>rgba(0, 0, 255, 0.5)
  # <li>hsla(120, 100%, 50%, 1)
  # </ul>
  #
  # The SVG 1.0 color keywords names are also supported, such as "aliceblue"
  # and "yellowgreen". The "transparent" keyword is supported for fully-
  # transparent black.
  #
  # <p>If the <tt>format</tt> argument is already an instance of <tt>Color</tt>,
  # the argument is returned with no further processing.
  #
  # * see <a href="http://www.w3.org/TR/SVG/types.html#ColorKeywords">SVG color
  # keywords</a>
  # * see <a href="http://www.w3.org/TR/css3-color/">CSS3 color module</a>
  #/
  def self.color(format)
    return format.rgb if format.respond_to? :rgb
    if (format =~/([a-z]+)\((.*)\)/)
      color_type,color_data=$1,$2
      m2 = color_data.split(",")
      a = 1
      if ['hsla','rgba'].include? color_type
        a = m2[3].to_f
        return Color.transparent if (a==0)
      end

      if ['hsla','hsl'].include? color_type
        h=m2[0].to_f
        s=m2[1].to_f / 100.0
        l=m2[2].to_f / 100.0
        return Color::Hsl.new(h,s,l,a).rgb
      end
     
      if ['rgba','rgb'].include? color_type
        parse=lambda {|c|
          (c[c.size-1,1]=='%') ? (c.to_f*2.55).round : c.to_i
        }
        r=parse.call(m2[0])
        g=parse.call(m2[1])
        b=parse.call(m2[2])
        return Rubyvis.rgb(r,g,b,a)
      end
    end
    
    named = Rubyvis::Color::NAMES[format.to_sym]


    return Rubyvis.color(named) if (named)

    # Hexadecimal colors: #rgb and #rrggbb. */
    if (format[0,1]== "#")
      if (format.size == 4)
        r = format[1,1]; r += r
        g = format[2,1]; g +=g
        b = format[3,1]; b +=b
      elsif (format.size == 7)
        r = format[1,2]
        g = format[3,2]
        b = format[5,2]
      end
      return Rubyvis.rgb(r.to_i(16), g.to_i(16), b.to_i(16), 1)
    end

    # Otherwise, pass-through unsupported colors. */
    return Rubyvis::Color.new(format, 1);
  end
  # Constructs a new RGB color with the specified channel values.
  def self.rgb(r,g,b,a=1)
    Rubyvis::Color::Rgb.new(r,g,b,a)
  end
  def self.hsl(h,s,l,a=1)
    Rubyvis::Color::Hsl.new(h,s,l,a)
  end
  # Represents an abstract (possibly translucent) color. The color is
  # divided into two parts: the <tt>color</tt> attribute, an opaque color format
  # string, and the <tt>opacity</tt> attribute, a float in [0, 1]. The color
  # space is dependent on the implementing class; all colors support the
  # Color.rgb() method to convert to RGB color space for interpolation.
  class Color
    
    # Association between names and colors
    NAMES={
        :aliceblue=>"#f0f8ff",
        :antiquewhite=>"#faebd7",
        :aqua=>"#00ffff",
        :aquamarine=>"#7fffd4",
        :azure=>"#f0ffff",
        :beige=>"#f5f5dc",
        :bisque=>"#ffe4c4",
        :black=>"#000000",
        :blanchedalmond=>"#ffebcd",
        :blue=>"#0000ff",
        :blueviolet=>"#8a2be2",
        :brown=>"#a52a2a",
        :burlywood=>"#deb887",
        :cadetblue=>"#5f9ea0",
        :chartreuse=>"#7fff00",
        :chocolate=>"#d2691e",
        :coral=>"#ff7f50",
        :cornflowerblue=>"#6495ed",
        :cornsilk=>"#fff8dc",
        :crimson=>"#dc143c",
        :cyan=>"#00ffff",
        :darkblue=>"#00008b",
        :darkcyan=>"#008b8b",
        :darkgoldenrod=>"#b8860b",
        :darkgray=>"#a9a9a9",
        :darkgreen=>"#006400",
        :darkgrey=>"#a9a9a9",
        :darkkhaki=>"#bdb76b",
        :darkmagenta=>"#8b008b",
        :darkolivegreen=>"#556b2f",
        :darkorange=>"#ff8c00",
        :darkorchid=>"#9932cc",
        :darkred=>"#8b0000",
        :darksalmon=>"#e9967a",
        :darkseagreen=>"#8fbc8f",
        :darkslateblue=>"#483d8b",
        :darkslategray=>"#2f4f4f",
        :darkslategrey=>"#2f4f4f",
        :darkturquoise=>"#00ced1",
        :darkviolet=>"#9400d3",
        :deeppink=>"#ff1493",
        :deepskyblue=>"#00bfff",
        :dimgray=>"#696969",
        :dimgrey=>"#696969",
        :dodgerblue=>"#1e90ff",
        :firebrick=>"#b22222",
        :floralwhite=>"#fffaf0",
        :forestgreen=>"#228b22",
        :fuchsia=>"#ff00ff",
        :gainsboro=>"#dcdcdc",
        :ghostwhite=>"#f8f8ff",
        :gold=>"#ffd700",
        :goldenrod=>"#daa520",
        :gray=>"#808080",
        :green=>"#008000",
        :greenyellow=>"#adff2f",
        :grey=>"#808080",
        :honeydew=>"#f0fff0",
        :hotpink=>"#ff69b4",
        :indianred=>"#cd5c5c",
        :indigo=>"#4b0082",
        :ivory=>"#fffff0",
        :khaki=>"#f0e68c",
        :lavender=>"#e6e6fa",
        :lavenderblush=>"#fff0f5",
        :lawngreen=>"#7cfc00",
        :lemonchiffon=>"#fffacd",
        :lightblue=>"#add8e6",
        :lightcoral=>"#f08080",
        :lightcyan=>"#e0ffff",
        :lightgoldenrodyellow=>"#fafad2",
        :lightgray=>"#d3d3d3",
        :lightgreen=>"#90ee90",
        :lightgrey=>"#d3d3d3",
        :lightpink=>"#ffb6c1",
        :lightsalmon=>"#ffa07a",
        :lightseagreen=>"#20b2aa",
        :lightskyblue=>"#87cefa",
        :lightslategray=>"#778899",
        :lightslategrey=>"#778899",
        :lightsteelblue=>"#b0c4de",
        :lightyellow=>"#ffffe0",
        :lime=>"#00ff00",
        :limegreen=>"#32cd32",
        :linen=>"#faf0e6",
        :magenta=>"#ff00ff",
        :maroon=>"#800000",
        :mediumaquamarine=>"#66cdaa",
        :mediumblue=>"#0000cd",
        :mediumorchid=>"#ba55d3",
        :mediumpurple=>"#9370db",
        :mediumseagreen=>"#3cb371",
        :mediumslateblue=>"#7b68ee",
        :mediumspringgreen=>"#00fa9a",
        :mediumturquoise=>"#48d1cc",
        :mediumvioletred=>"#c71585",
        :midnightblue=>"#191970",
        :mintcream=>"#f5fffa",
        :mistyrose=>"#ffe4e1",
        :moccasin=>"#ffe4b5",
        :navajowhite=>"#ffdead",
        :navy=>"#000080",
        :oldlace=>"#fdf5e6",
        :olive=>"#808000",
        :olivedrab=>"#6b8e23",
        :orange=>"#ffa500",
        :orangered=>"#ff4500",
        :orchid=>"#da70d6",
        :palegoldenrod=>"#eee8aa",
        :palegreen=>"#98fb98",
        :paleturquoise=>"#afeeee",
        :palevioletred=>"#db7093",
        :papayawhip=>"#ffefd5",
        :peachpuff=>"#ffdab9",
        :peru=>"#cd853f",
        :pink=>"#ffc0cb",
        :plum=>"#dda0dd",
        :powderblue=>"#b0e0e6",
        :purple=>"#800080",
        :red=>"#ff0000",
        :rosybrown=>"#bc8f8f",
        :royalblue=>"#4169e1",
        :saddlebrown=>"#8b4513",
        :salmon=>"#fa8072",
        :sandybrown=>"#f4a460",
        :seagreen=>"#2e8b57",
        :seashell=>"#fff5ee",
        :sienna=>"#a0522d",
        :silver=>"#c0c0c0",
        :skyblue=>"#87ceeb",
        :slateblue=>"#6a5acd",
        :slategray=>"#708090",
        :slategrey=>"#708090",
        :snow=>"#fffafa",
        :springgreen=>"#00ff7f",
        :steelblue=>"#4682b4",
        :tan=>"#d2b48c",
        :teal=>"#008080",
        :thistle=>"#d8bfd8",
        :tomato=>"#ff6347",
        :turquoise=>"#40e0d0",
        :violet=>"#ee82ee",
        :wheat=>"#f5deb3",
        :white=>"#ffffff",
        :whitesmoke=>"#f5f5f5",
        :yellow=>"#ffff00",
        :yellowgreen=>"#9acd32",
      }
    
    
    # An opaque color format string, such as "#f00".
    attr_reader :color
    # The opacity, a float in [0, 1].
    attr_reader :opacity
    
    # Constructs a color with the specified color format string and opacity. This
    # constructor should not be invoked directly; use Rubyvis.color instead.
    def initialize(color,opacity)
      @color=color
      @opacity=opacity
    end
    # Returns a new color that is a brighter version of this color. The behavior of
    # this method may vary slightly depending on the underlying color space.
    # Although brighter and darker are inverse operations, the results of a series
    # of invocations of these two methods might be inconsistent because of rounding
    # errors.
    # * @param [k] {number} an optional scale factor; defaults to 1.
    def brighter(k)
      self.rgb.brighter(k)
    end
    
    # Returns a new color that is a brighter version of this color. The behavior of
    # this method may vary slightly depending on the underlying color space.
    # Although brighter and darker are inverse operations, the results of a series
    # of invocations of these two methods might be inconsistent because of rounding
    # errors.
    #
    # * @param [k] {number} an optional scale factor; defaults to 1.
    def darker(k)
      self.rgb.darker(k)
    end
    
    def self.transparent
      Rubyvis.rgb(0,0,0,0)
    end
    # Represents a color in RGB space.
    class Rgb < Color
      # The red channel, an integer in [0, 255].
      attr_reader :r
      # The blue channel, an integer in [0, 255].
      attr_reader :b
      # The green channel, an integer in [0, 255].
      attr_reader :g
      # The alpha channel, a float in [0, 1].
      attr_reader :a
      # Constructs a new RGB color with the specified channel values.
      def initialize(r,g,b,a)
        @r=r
        @b=b
        @g=g
        @a=a
        @opacity=a
        @color= @a > 0 ? "rgb(#{r.to_i},#{g.to_i},#{b.to_i})" : "none"
      end
      def ==(v)
        self.class==v.class and @r==v.r and @b==v.b and @g==v.g and @a==v.a
      end
      
      # Constructs a new RGB color with the same green, blue and alpha channels
      # as this color, with the specified red channel.
      def red(r1)
        Rubyvis.rgb(r1,g,b,a)
      end
      # Constructs a new RGB color with the same red, blue and alpha channels
      # as this color, with the specified green channel.
      def green(g1)
        Rubyvis.rgb(r,g1,b,a)
      end
      # Constructs a new RGB color with the same red, green and alpha channels
      # as this color, with the specified blue channel.
      def blue(b1)
        Rubyvis.rgb(r,g,b1,a)
      end
      # Constructs a new RGB color with the same red, green and blue channels as this
      # color, with the specified alpha channel.
      
      def alpha(a1)
        Rubyvis.rgb(r,g,b,a1)
      end
      # Returns the RGB color equivalent to this color. This method is abstract and  must be implemented by subclasses.
      def rgb
        self
      end
      # Returns a new color that is a brighter version of this color. This method
      # applies an arbitrary scale factor to each of the three RGB components of this
      # color to create a brighter version of this color. Although brighter and
      # darker are inverse operations, the results of a series of invocations of
      # these two methods might be inconsistent because of rounding errors.
      def brighter(k=1)
        k = 0.7**k
        i = 30
        r=self.r
        g=self.g
        b=self.b
        return Rubyvis.rgb(i, i, i, a) if (!r and !g and !b) 
        r = i if (r and (r < i)) 
        g = i if (g and (g < i)) 
        b = i if (b and (b < i))
        Rubyvis.rgb(
          [255, (r/k).floor].min,
          [255, (g/k).floor].min,
          [255, (b/k).floor].min,
        a)
      end
      # Returns a new color that is a darker version of this color. This method
      # applies an arbitrary scale factor to each of the three RGB components of this
      # color to create a darker version of this color. Although brighter and darker
      # are inverse operations, the results of a series of invocations of these two
      # methods might be inconsistent because of rounding errors.
      def darker(k=1)
        k = 0.7 ** k
        Rubyvis.rgb(
          [0, (k * r).floor].max,
          [0, (k * g).floor].max,
          [0, (k * b).floor].max,
          a)
      end
      
      def to_s
        @color
      end
    end
    # Represents a color in HSL space.
    class Hsl < Color
      # The hue, an integer in [0, 360].
      attr_accessor :h
      # The saturation, a float in [0, 1].
      attr_accessor :s
      # The lightness, a float in [0, 1].
      attr_accessor :l
      # The opacity, a float in [0, 1].
      attr_accessor :a
      
      def initialize(h,s,l,a)
        c="hsl(#{h},#{s * 100}%,#{l * 100}%)"
        super(c,a)
        @h=h
        @s=s
        @l=l
        @a=a
      end
      def ==(v)
        self.class==v.class and @h==v.h and @s==v.s and @l==v.l and @a==v.a
      end
      
      # Returns the RGB color equivalent to this HSL color.
      def rgb
        h = self.h
        s = self.s
        l = self.l
        # Some simple corrections for h, s and l. */
        h = h % 360
        h += 360 if (h < 0)
        s = [0, [s, 1].min].max
        l = [0, [l, 1].min].max
        
        # From FvD 13.37, CSS Color Module Level 3 
        m2 = (l <= 0.5) ? (l * (1 + s)) : (l + s - l * s)
        m1 = 2 * l - m2
        v=lambda {|h1|
          if (h1 > 360)
            h1 -= 360
          elsif (h1 < 0)
             h1 += 360
          end
          
          
          return m1 + (m2 - m1) * h1 / 60.0 if (h1 < 60.0)
          return m2 if (h1 < 180.0) 
          return m1 + (m2 - m1) * (240.0 - h1) / 60.0 if (h1 < 240.0)
          return m1
        }
        
        vv=lambda {|h1| (v.call(h1) * 255).round}
        Rubyvis.rgb(vv.call(h + 120), vv.call(h), vv.call(h - 120), a)
       
      end
    end

    
    
  end
end
