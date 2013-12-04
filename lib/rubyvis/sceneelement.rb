module Rubyvis
  # Scene element
  # Store information about each scene.
  # On javascript, is an Array with custom properties.
  class SceneElement # :nodoc:
    def initialize
      @scenes=Array.new
    end
    include Enumerable
    attr_accessor :visible

    ## ACCESSOR 
    ## If you implement new accessor on a scene element
    ## you should add it here
    
    attr_accessor :_g
    attr_accessor :_grid
    attr_accessor :_id
    attr_accessor :_matrix
    attr_accessor :angle
    attr_accessor :antialias
    attr_accessor :background_style
    attr_accessor :bands
    attr_accessor :bottom
    attr_accessor :breadth
    attr_accessor :canvas
    attr_accessor :child_index
    attr_accessor :children
    attr_accessor :cols
    attr_accessor :cursor
    attr_accessor :data
    attr_accessor :defs
    attr_accessor :depth
    attr_accessor :directed
    attr_accessor :eccentricity
    attr_accessor :end_angle
    attr_accessor :events
    attr_accessor :fill_style
    attr_accessor :font
    attr_accessor :font_family
    attr_accessor :font_size
    attr_accessor :font_style
    attr_accessor :font_variant
    attr_accessor :font_weight
    attr_accessor :group
    attr_accessor :height
    attr_accessor :id
    attr_accessor :image
    attr_accessor :image_height
    attr_accessor :image_width
    attr_accessor :inner_radius
    attr_accessor :interpolate
    attr_accessor :layers
    attr_accessor :left
    attr_accessor :line_join
    attr_accessor :line_width
    attr_accessor :links
    attr_accessor :mark
    attr_accessor :mode
    attr_accessor :name
    attr_accessor :negative_style
    attr_accessor :nodes
    attr_accessor :offset
    attr_accessor :order
    attr_accessor :orient
    attr_accessor :outer_radius
    attr_accessor :overflow
    attr_accessor :padding_bottom
    attr_accessor :padding_left
    attr_accessor :padding_right
    attr_accessor :padding_top
    attr_accessor :parent
    attr_accessor :parent_index
    attr_accessor :positive_style
    attr_accessor :reverse
    attr_accessor :right
    attr_accessor :round
    attr_accessor :rows
    attr_accessor :segmented
    attr_accessor :shape
    attr_accessor :shape_angle
    attr_accessor :shape_radius
    attr_accessor :shape_size
    attr_accessor :spacing
    attr_accessor :start_angle
    attr_accessor :stroke_dasharray
    attr_accessor :stroke_style
    attr_accessor :target
    attr_accessor :tension
    attr_accessor :text
    attr_accessor :text_align
    attr_accessor :text_angle
    attr_accessor :text_baseline
    attr_accessor :text_decoration
    attr_accessor :text_margin
    attr_accessor :text_shadow
    attr_accessor :text_style
    attr_accessor :title
    attr_accessor :top
    attr_accessor :transform
    attr_accessor :type
    attr_accessor :url
    attr_accessor :width
    attr_accessor :view_box
    
    def []=(v,i)
      if v.is_a? Numeric
        @scenes[v]=i
      elsif self.respond_to?(v.to_s+"=")
        self.send(v.to_s+"=",i)
      end
    end
    def [](v)
      if v.is_a? Numeric
        @scenes[v]
      elsif v.nil?
        nil
      elsif self.respond_to? v
        self.send(v)
      end
    end
    def each
      @scenes.each do |v|
        yield v
      end
    end
    def push(v)
      @scenes.push(v)
    end
    def size
      @scenes.size
    end
    def inspect
      elements_id=@scenes.map{|e| '<'+ e.object_id.to_s(16)+'>'}.join(", ")
      "<SE #{object_id.to_s(16)} (#{type}), elements: #{self.size} (#{elements_id}), children: #{children ? children.size : '0'}, data: #{data ? data.to_s: ''}>"
    end
    def size=(v)
      if self.size==v
        return true
      elsif self.size<v
        (v-self.size).times {push(nil)}
      else
        self.slice!(0,v)
      end
    end
  end
end
