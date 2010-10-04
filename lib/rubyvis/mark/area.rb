module Rubyvis
  def self.Area
    Rubyvis::Area
  end
  module AreaPrototype
    def fixed
      {
        #  :line_width=> true,
        :line_join=> true,
        # :stroke_style=> true,
        # :fill_style=> true,
        :segmented=> true,
        :interpolate=> true,
        :tension=> true
      }
    end
    def area_build_instance(s)

      binds = self.binds

      # Handle fixed properties on secondary instances. */
      if (self.index)
        fixed = @binds.fixed;
        #/* Determine which properties are fixed. */
        if (!fixed)
          binds.fixed=[]
          fixed = binds.fixed
          filter=lambda {|prop|
            if prop.fixed
              fixed.push(prop)
              return false
            else
              return true
            end
          }
          #      p binds.required
          binds.required = binds.required.find_all(&filter)
          #      p binds.required
          if (!self.scene[0].segmented)
            binds.optional = binds.optional.find_all(&filter)
          end
        end

        #    p binds.required


        #/* Copy fixed property values from the first instance. */
        fixed.each {|prop|
          name=prop.name
          s[name]=self.scene[0][name]
        }
        #    p binds.fixed
        #/* Evaluate all properties on the first instance. */
      else
        binds.required = binds._required;
        binds.optional = binds._optional;
        binds.fixed = nil;

      end
      # pp binds
      mark_build_instance(s)
    end



    def area_bind
      mark_bind()
      binds = self.binds

      required = binds.required
      optional = binds.optional
      optional.size.times {|i|
        prop = optional[i]

        prop.fixed = fixed.include? prop.name
        if (prop.name == "segmented")
          required.push(prop)
        end
      }
      optional.delete_if {|v| v.name=='segmented'}
      # Cache the original arrays so they can be restored on build. */
      @binds._required = required;
      @binds._optional = optional;
    end


    def area_anchor(name)
      scene=nil
      anchor=mark_anchor(name)
      anchor.interpolate(lambda {
        self.scene.target[self.index].interpolate
      }).eccentricity(lambda {
        self.scene.target[self.index].eccentricity
      }).tension(lambda {
        self.scene.target[self.index].tension
      })
    end
  end
  class Area < Mark
    include AreaPrototype
    @properties=Mark.properties.dup
    attr_accessor_dsl :width, :height, :line_width, :stroke_style, :fill_style, :segmented, :interpolate, :tension
    def type
      'area'
    end
    def bind
      area_bind
    end
    def build_instance(s)
      area_build_instance(s)
    end
    def self.defaults
      Area.new.extend(Mark.defaults).line_width(1.5).fill_style(pv.Colors.category20.by(pv.parent)).interpolate('linear').tension(0.7)
    end
    def anchor(name)
      area_anchor(name)
    end
    def build_implied(s)
      s.heigth=0 if s.height.nil?
      s.width=0 if s.width.nil?
      super(s)
    end
  end
end
