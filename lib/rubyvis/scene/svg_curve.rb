module Rubyvis::SvgScene
  class PathBasis #:nodoc:
    def initialize(p0,p1,p2,p3)
      @p0=p0
      @p1=p1
      @p2=p2
      @p3=p3
    end
    attr_accessor :p0,:p1,:p2,:p3
    
    #
    # Matrix to transform basis (b-spline) control points to bezier control
    # points. Derived from FvD 11.2.8.
    #
    
    def basis
      [
      [ 1/6.0, 2/3.0, 1/6.0,   0 ],
      [   0, 2/3.0, 1/3.0,   0 ],
      [   0, 1/3.0, 2/3.0,   0 ],
      [   0, 1/6.0, 2/3.0, 1/6.0 ]
      ]
    end
    # Returns the point that is the weighted sum of the specified control points,
    # using the specified weights. This method requires that there are four
    # weights and four control points.    
    def weight(w)
      OpenStruct.new({
      :x=> w[0] * p0.left + w[1] * p1.left + w[2] * p2.left + w[3] * p3.left,
      :y=> w[0] * p0.top  + w[1] * p1.top  + w[2] * p2.top  + w[3] * p3.top
      })
    end
    def convert
      b1 = weight(basis[1])
      b2 = weight(basis[2])
      b3 = weight(basis[3])
      "C#{b1.x},#{b1.y},#{b2.x},#{b2.y },#{b3.x},#{b3.y}"
    end
    def to_s
      convert
    end
    def segment
      b0 = weight(basis[0])
      b1 = weight(basis[1])
      b2 = weight(basis[2])
      b3 = weight(basis[3])
      "M#{b0.x},#{b0.y}C#{b1.x},#{b1.y},#{b2.x},#{b2.y},#{b3.x},#{b3.y}"
    end
  end
  # Converts the specified b-spline curve segment to a bezier curve
  # compatible with SVG "C".
  # * @param p0 the first control point.
  # * @param p1 the second control point.
  # * @param p2 the third control point.
  # * @param p3 the fourth control point.
  def self.path_basis(p0,p1,p2,p3)
    PathBasis.new(p0,p1,p2,p3)
  end
  

  # Interpolates the given points using the basis spline interpolation.
  # Returns an SVG path without the leading M instruction to allow path
  # appending.
  
  def self.curve_basis(points) 
    return "" if (points.size <= 2)
    path = ""
    p0 = points[0]
    p1 = p0
    p2 = p0
    p3 = points[1]
    
    path += self.path_basis(p0, p1, p2, p3).to_s
    2.upto(points.size-1) {|i|
      p0 = p1
      p1 = p2
      p2 = p3
      p3 = points[i]
      path += self.path_basis(p0, p1, p2, p3).to_s
    }
    #  Cycle through to get the last point.
    path += self.path_basis(p1, p2, p3, p3).to_s
    path += self.path_basis(p2, p3, p3, p3).to_s
    path;
  end

  # Interpolates the given points using the basis spline interpolation.
  # If points.length == tangents.length then a regular Hermite interpolation is
  # performed, if points.length == tangents.length + 2 then the first and last
  # segments are filled in with cubic bazier segments.  Returns an array of path
  # strings.
  
  def self.curve_basis_segments(points) 
    return "" if (points.size <= 2)
    paths = []
    p0 = points[0]
    p1 = p0
    p2 = p0
    p3 = points[1]
    firstPath = self.path_basis(p0, p1, p2, p3).segment
    p0 = p1;
    p1 = p2;
    p2 = p3;
    p3 = points[2];
    paths.push(firstPath + self.path_basis(p0, p1, p2, p3).to_s) # merge first & second path
    3.upto(points.size-1) {|i|
      p0 = p1;
      p1 = p2;
      p2 = p3;
      p3 = points[i];
      paths.push(path_basis(p0, p1, p2, p3).segment);
    }
    
    # merge last & second-to-last path
    paths.push(path_basis(p1, p2, p3, p3).segment + path_basis(p2, p3, p3, p3).to_s)
    paths
  end

  # Interpolates the given points with respective tangents using the cubic
  # Hermite spline interpolation. If points.length == tangents.length then a regular
  # Hermite interpolation is performed, if points.length == tangents.length + 2 then
  # the first and last segments are filled in with cubic bazier segments.
  # Returns an SVG path without the leading M instruction to allow path appending.
  #
  # * @param points the array of points.
  # * @param tangents the array of tangent vectors.
  #/
  
  def self.curve_hermite(points, tangents)
    return "" if (tangents.size < 1 or (points.size != tangents.size and points.size != tangents.size + 2)) 
    quad = points.size != tangents.size
    path = ""
    p0 = points[0]
    p = points[1]
    t0 = tangents[0]
    t = t0
    pi = 1

    if (quad) 
        path += "Q#{(p.left - t0.x * 2 / 3)},#{(p.top - t0.y * 2 / 3)},#{p.left},#{p.top}"
        p0 = points[1];
        pi = 2;
    end

    if (tangents.length > 1) 
      t = tangents[1]
      p = points[pi]
      pi+=1
      path += "C#{(p0.left + t0.x)},#{(p0.top + t0.y) },#{(p.left - t.x) },#{(p.top - t.y)},#{p.left},#{p.top}"
      
      2.upto(tangents.size-1) {|i|
        p = points[pi];
        t = tangents[i];
        path += "S#{(p.left - t.x)},#{(p.top - t.y)},#{p.left},#{p.top}"
        pi+=1
      }
    end

    if (quad) 
    lp = points[pi];
    path += "Q#{(p.left + t.x * 2 / 3)},#{(p.top + t.y * 2 / 3)},#{lp.left},#{lp.top}"
    end

    path;
  end
  # Interpolates the given points with respective tangents using the
  # cubic Hermite spline interpolation. Returns an array of path strings.
  #
  # * @param points the array of points.
  # * @param tangents the array of tangent vectors.
  def self.curve_hermite_segments(points, tangents)
    return [] if (tangents.size < 1 or  (points.size != tangents.size and points.size != tangents.size + 2)) 
    quad = points.size != tangents.size
    paths = []
    p0 = points[0]
    p = p0
    t0 = tangents[0]
    t = t0
    pi = 1
    
    if (quad) 
    p = points[1]
    paths.push("M#{p0.left},#{p0.top }Q#{(p.left - t.x * 2 / 3.0 )},#{(p.top - t.y * 2 / 3)},#{p.left},#{p.top}")
    pi = 2
    end
    
    1.upto(tangents.size-1) {|i|
    p0 = p;
    t0 = t;
    p = points[pi]
    t = tangents[i]
    paths.push("M#{p0.left },#{p0.top
      }C#{(p0.left + t0.x) },#{(p0.top + t0.y)
      },#{(p.left - t.x) },#{(p.top - t.y)
      },#{p.left },#{p.top}")
    pi+=1
    }
    
    if (quad) 
    lp = points[pi];
    paths.push("M#{p.left },#{p.top
        }Q#{(p.left + t.x * 2 / 3) },#{(p.top + t.y * 2 / 3) },#{lp.left },#{lp.top}")
    end
    
    paths
  end

  # Computes the tangents for the given points needed for cardinal
  # spline interpolation. Returns an array of tangent vectors. Note: that for n
  # points only the n-2 well defined tangents are returned.
  #
  # * @param points the array of points.
  # * @param tension the tension of hte cardinal spline.
  def self.cardinal_tangents(points, tension) 
    tangents = []
    a = (1 - tension) / 2.0
    p0 = points[0]
    p1 = points[1]
    p2 = points[2]
    3.upto(points.size-1) {|i|
      tangents.push(OpenStruct.new({:x=> a * (p2.left - p0.left), :y=> a * (p2.top - p0.top)}))
      p0 = p1;
      p1 = p2;
      p2 = points[i];
    }
  
    tangents.push(OpenStruct.new({:x=> a * (p2.left - p0.left), :y=> a * (p2.top - p0.top)}))
    return tangents;
  end

  
  # Interpolates the given points using cardinal spline interpolation.
  # Returns an SVG path without the leading M instruction to allow path
  # appending.
  #
  # * @param points the array of points.
  # * @param tension the tension of hte cardinal spline.
  def self.curve_cardinal(points, tension)
    return "" if (points.size <= 2) 
    self.curve_hermite(points, self.cardinal_tangents(points, tension))
  end
  # Interpolates the given points using cardinal spline interpolation.
  # Returns an array of path strings.
  #
  # @param points the array of points.
  # @param tension the tension of hte cardinal spline.
  def self.curve_cardinal_segments(points, tension) 
    return "" if (points.size <= 2) 
    self.curve_hermite_segments(points, self.cardinal_tangents(points, tension))
  end

  # Interpolates the given points using Fritsch-Carlson Monotone cubic
  # Hermite interpolation. Returns an array of tangent vectors.
  #
  # *@param points the array of points.
  def self.monotone_tangents(points) 
    tangents = []
    d = []
    m = []
    dx = []
    #k=0
    
    #/* Compute the slopes of the secant lines between successive points. */
    
    
    0.upto(points.size-2) do |k| 
    
#    while(k < points.size-1) do 
      d[k] = (points[k+1].top - points[k].top) / (points[k+1].left - points[k].left).to_f
      k+=1
    end
    
    #/* Initialize the tangents at every point as the average of the secants. */
    m[0] = d[0]
    dx[0] = points[1].left - points[0].left
    
    
    1.upto(points.size-2) {|k|
      m[k] = (d[k-1]+d[k]) / 2.0
      dx[k] = (points[k+1].left - points[k-1].left) / 2.0
    }
    
    k=points.size-1
    
    m[k] = d[k-1];
    dx[k] = (points[k].left - points[k-1].left);
    
    # /* Step 3. Very important, step 3. Yep. Wouldn't miss it. */
    (points.size-1).times {|kk|
      if d[kk] == 0 
        m[ kk ] = 0;
        m[kk + 1] = 0;
      end
    }
    
    # /* Step 4 + 5. Out of 5 or more steps. */
    
    
    (points.size-1).times {|kk|
      next if ((m[kk].abs < 1e-5) or (m[kk+1].abs < 1e-5))
      akk = m[kk] / d[kk].to_f
      bkk = m[kk + 1] / d[kk].to_f
      s = akk * akk + bkk * bkk; # monotone constant (?)
      if (s > 9) 
        tkk = 3.0 / Math.sqrt(s)
        m[kk] = tkk * akk * d[kk]
        m[kk + 1] = tkk * bkk * d[kk]
      end
    }
    len=nil;
    points.size.times {|i|
      len = 1 + m[i] * m[i]; #// pv.vector(1, m[i]).norm().times(dx[i]/3)
      tangents.push(OpenStruct.new({:x=> dx[i] / 3.0 / len, :y=> m[i] * dx[i] / 3.0 / len}))
    }
    
    tangents;
  end

  # Interpolates the given points using Fritsch-Carlson Monotone cubic
  # Hermite interpolation. Returns an SVG path without the leading M instruction
  # to allow path appending.
  #
  # * @param points the array of points.
  def self.curve_monotone(points) 
     return "" if (points.length <= 2)
     return self.curve_hermite(points, self.monotone_tangents(points))
  end

  # Interpolates the given points using Fritsch-Carlson Monotone cubic
  # Hermite interpolation.
  # Returns an array of path strings.
  #
  # * @param points the array of points.
  #/
  def self.curve_monotone_segments(points) 
    return "" if (points.size <= 2)
     self.curve_hermite_segments(points, self.monotone_tangents(points))
  end

end
