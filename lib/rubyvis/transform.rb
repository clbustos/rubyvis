module Rubyvis
  def self.Transform
    Rubyvis::Transform
  end
  class Transform
    attr_accessor :k,:x,:y
    def initialize
      @k=1
      @x=0
      @y=0
    end
    def translate(x,y)
      v=Transform.new
      v.k=self.k
      v.x=self.k*x+self.x
      v.y=self.k*y+self.y
      v

    end
    def self.identity
      Transform.new
    end
  end

end
