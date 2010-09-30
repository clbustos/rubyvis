module Rubyvis
  def self.Label
    Rubyvis::Label
  end
  
  class Label < Mark
    @properties=Mark.properties
    attr_accessor_dsl :text, :font, :text_angle, :text_style, :text_align, :text_baseline, :text_margin, :text_decoration, :text_shadow
    def type
      'label'
    end
    def defaults
      sd=super
      return sd.merge({:events=>'none', :text=>lambda{|x| puts "->#{x}"; x}, :font=>"10px sans-serif", :text_angle=>0, :text_style=>pv.color('black'), :text_align=>'left', :text_baseline=>'bottom', :text_margin=>3})
    end
  end
end