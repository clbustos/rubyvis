module Rubyvis
  class Property
    attr_accessor :name, :id, :value, :_type
    def initialize(opts=Hash.new)
      @id=opts[:id]
      @name=opts[:name]
      @value=opts[:value]
      @_type=opts[:_type]
    end
  end
end