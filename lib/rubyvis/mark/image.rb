module Rubyvis
  def self.Image
    Rubyvis::Image
  end
  class Image < Bar
    def type
      "image"
    end
    @properties=Bar.properties.dup
    attr_accessor :_image
    def initialize(opts=Hash.new)
      super(opts)
      @_image=nil
    end
    ##
    # :attr: url
    # The URL of the image to display. The set of supported image types is
    # browser-dependent; PNG and JPEG are recommended.
    
    ##
    # :attr: image_width
    # The width of the image in pixels. For static images, this property is
    # computed implicitly from the loaded image resources. For dynamic images, this
    # property can be used to specify the width of the pixel buffer; otherwise, the
    # value is derived from the <tt>width</tt> property.
    
    ##
    # :attr: image_height
    # The height of the image in pixels. For static images, this property is
    # computed implicitly from the loaded image resources. For dynamic images, this
    # property can be used to specify the height of the pixel buffer; otherwise, the
    # value is derived from the <tt>height</tt> property.
    
    attr_accessor_dsl :url, :image_width, :image_height
    
    
    # Default properties for images. By default, there is no stroke or fill style.
    def self.defaults
      Image.new.mark_extend(Bar.defaults).fill_style(nil)
    end
    
    # @TODO: NOT IMPLEMENTED YET
    # Specifies the dynamic image function. By default, no image function is
    # specified and the <tt>url</tt> property is used to load a static image
    # resource. If an image function is specified, it will be invoked for each
    # pixel in the image, based on the related <tt>imageWidth</tt> and
    # <tt>imageHeight</tt> properties.
    #
    # <p>For example, given a two-dimensional array <tt>heatmap</tt>, containing
    # numbers in the range [0, 1] in row-major order, a simple monochrome heatmap
    # image can be specified as:
    #
    #   vis.add(pv.Image)
    #     .image_width(heatmap[0].length)
    #     .image_height(heatmap.length)
    #     .image(pv.ramp("white", "black").by(lambda {|x,y| heatmap[y][x]}))
    #
    # For fastest performance, use an ordinal scale which caches the fixed color
    # palette, or return an object literal with <tt>r</tt>, <tt>g</tt>, <tt>b</tt>
    # and <tt>a</tt> attributes. A {@link pv.Color} or string can also be returned,
    # though this typically results in slower performance.
    
    def dynamic_image(f)
      #f,dummy=arguments
      @_image = lambda {|*args|
        c=f.js_apply(self,args)
        c.nil? ? pv.Color.transparent : (c.is_a?(String) ? Rubyvis.color(c) : c )
      }
      self
    end
    
    
    # Scan the proto chain for an image function.
    def bind
      mark_bind
      bind=self.binds
      mark=self
      begin
        binds.image = mark._image
      end while(!binds.image and (mark==mark.proto))
    end
    
    
    def build_implied(s)
      mark_build_implied(s)
      return if !s.visible
      # Compute the implied image dimensions. */
      s.image_width = s.width   if s.image_width.nil?
      s.image_height = s.height if s.image_height.nil?
      # Compute the pixel values. */
      if (s.url.nil? and self.binds.image)
        raise "not implemented yet"
      end
    end
  end
end
