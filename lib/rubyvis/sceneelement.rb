module Rubyvis
  class SceneElement
    def initialize
      @scenes=Array.new
    end
    include Enumerable
    attr_accessor :visible
    attr_accessor :mark, :type, :child_index, :parent, :parent_index, :target, :defs, :data,  :antialias, :line_width, :fill_style, :overflow, :width, :height, :top, :bottom, :left, :right, :title, :reverse, :stroke_style, :transform, :canvas, :_g, :events, :cursor, :children, :id, :segmented, :interpolate, :tension, :name, :text_baseline, :text_align, :text, :font, :text_angle, :text_style, :text_margin, :text_decoration, :text_shadow
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
