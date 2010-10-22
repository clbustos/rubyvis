module Rubyvis
  def self.Label
    Rubyvis::Label
  end

  class Label < Mark
    @properties=Mark.properties.dup
    attr_accessor_dsl :text, :font, :text_angle, [:text_style, lambda {|d| pv.color(d)}], :text_align, :text_baseline, :text_margin, :text_decoration, :text_shadow
    def type
      'label'
    end
    def self.defaults
      Label.new.extend(Mark.defaults).events('none').text(pv.identity).font("10px sans-serif" ).text_angle( 0 ).text_style( 'black' ).text_align( 'left' ).text_baseline( 'bottom' ).text_margin(3)
    end
  end
end
