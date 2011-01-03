module Rubyvis
  # Returns a {@link pv.Vector} for the specified <i>x</i> and <i>y</i>
  # coordinate. This is a convenience factory method, equivalent to <tt>new
  # pv.Vector(x, y)</tt>.
  #
  # @see pv.Vector
  # @param {number} x the <i>x</i> coordinate.
  # @param {number} y the <i>y</i> coordinate.
  # @returns {pv.Vector} a vector for the specified coordinates.
  
  def self.vector(x,y) 
    Rubyvis::Vector.new(x,y)
  end
  class Vector
    attr_accessor :x,:y
    # Constructs a {@link pv.Vector} for the specified <i>x</i> and <i>y</i>
    # coordinate. This constructor should not be invoked directly; use
    # {@link pv.vector} instead.
    #
    # @class Represents a two-dimensional vector; a 2-tuple <i>&#x27e8;x,
    # y&#x27e9;</i>. The intent of this class is to simplify vector math. Note that
    # in performance-sensitive cases it may be more efficient to represent 2D
    # vectors as simple objects with <tt>x</tt> and <tt>y</tt> attributes, rather
    # than using instances of this class.
    #
    # @param {number} x the <i>x</i> coordinate.
    # @param {number} y the <i>y</i> coordinate.
    def initialize(x,y) 
      @x=x
      @y=y
    end
    def ==(v)
      @x==v.x and @y==v.y
    end
    # Returns a vector perpendicular to this vector: <i>&#x27e8;-y, x&#x27e9;</i>.
    #
    # @returns {pv.Vector} a perpendicular vector.
    #/
    def perp
      Rubyvis::Vector.new(-@y,@x)
    end
    # Returns a normalized copy of this vector: a vector with the same direction,
    # but unit length. If this vector has zero length this method returns a copy of
    # this vector.
    #
    # @returns {pv.Vector} a unit vector.
    def norm 
      l=length()
      times(l!=0 ? (1.0 / l) : 1.0)
    end
    
    # Returns the magnitude of this vector, defined as <i>sqrt(x * x + y * y)</i>.
    #
    # @returns {number} a length.
    def length
      Math.sqrt(@x**2 + @y**2)
    end

    # Returns a scaled copy of this vector: <i>&#x27e8;x * k, y * k&#x27e9;</i>.
    # To perform the equivalent divide operation, use <i>1 / k</i>.
    #
    # @param {number} k the scale factor.
    # @returns {pv.Vector} a scaled vector.
    def times(k)
      Rubyvis::Vector.new(@x * k, @y * k)
    end
    # Returns this vector plus the vector <i>v</i>: <i>&#x27e8;x + v.x, y +
    # v.y&#x27e9;</i>. If only one argument is specified, it is interpreted as the
    # vector <i>v</i>.
    #
    # @param {number} x the <i>x</i> coordinate to add.
    # @param {number} y the <i>y</i> coordinate to add.
    # @returns {pv.Vector} a new vector.
    def plus(x,y=nil)
      
      return (y.nil?) ? Rubyvis::Vector.new(@x + x.x, @y + x.y) : Rubyvis::Vector.new(@x + x, @y + y)
    end
    
    # Returns this vector minus the vector <i>v</i>: <i>&#x27e8;x - v.x, y -
    # v.y&#x27e9;</i>. If only one argument is specified, it is interpreted as the
    # vector <i>v</i>.
    #
    # @param {number} x the <i>x</i> coordinate to subtract.
    # @param {number} y the <i>y</i> coordinate to subtract.
    # @returns {pv.Vector} a new vector.
    
    def minus(x,y=nil)
      
      return (y.nil?) ? Rubyvis::Vector.new(@x - x.x, @y - x.y) : Rubyvis::Vector.new(@x - x, @y - y)
    end

    # Returns the dot product of this vector and the vector <i>v</i>: <i>x * v.x +
    # y * v.y</i>. If only one argument is specified, it is interpreted as the
    # vector <i>v</i>.
    #
    # @param {number} x the <i>x</i> coordinate to dot.
    # @param {number} y the <i>y</i> coordinate to dot.
    # @returns {number} a dot product.
    def dot(x, y=nil) 
      (y.nil?) ? @x * x.x + @y * x.y : @x * x + @y * y
    end
  end
end

