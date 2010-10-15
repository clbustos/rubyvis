module Rubyvis
  class Layout
  def self.Stack
    Rubyvis::Layout::Stack
  end
  class Stack < Rubyvis::Layout
    @properties=Mark.properties.dup    
    
    attr_accessor :_x, :_y, :_values
    attr_accessor_dsl :orient,:offset, :order, :layers
    def self.defaults
      Stack.new.extend(Layout.defaults).orient("bottom-left").offset("zero").layers([[]])
    end
    def initialize
      super
      @none=lambda {return nil}
      @prop = {:t=> @none, :l=> @none, :r=> @none, :b=> @none, :w=> @none, :h=> @none}
      @values=nil
      @_x=lambda {return 0}
      @_y=lambda {return 0}
      @_values=pv.identity
    end
    def x(f)
      @_x=pv.functor(f)
      return self
    end
    def y(f)
      @_y=pv.functor(f)
      return self
    end
    def values(f)
      @_values=pv.functor(f)
      return self
    end
    
    
    def proxy(name) 
      return lambda { @prop[name].call(self.parent.index, self.index)}
    end
    def build_implied(s)
      panel_build_implied(s)
      data = s.layers
      n = data.size
      m = nil
      orient = s.orient
      if orient =~/^(top|bottom)\b/
        horizontal=true
      else
        horizontal=false
      end
      h = self.parent.send(horizontal ? "height" : "width")
      x = []
      y = []
      dy = []
      
     #
     # Iterate over the data, evaluating the values, x and y functions. The
     # context in which the x and y psuedo-properties are evaluated is a
     # pseudo-mark that is a grandchild of this layout.
     #
     stack = Rubyvis::Mark.stack
    
    o = OpenStruct.new({:parent=> OpenStruct.new({:parent=> self})})
    stack.unshift(nil)
    values = []
    n.times {|i|
      dy[i] = []
      y[i] = []
      o.parent.index = i
      stack[0] = data[i]
      values[i] = self._values.js_apply(o.parent, stack);
      m = values[i].size if (i==0) 
      stack.unshift(nil)
      m.times {|j|
        stack[0] = values[i][j]
        o.index = j
        x[j] = self._x.js_apply(o, stack) if i==0
        dy[i][j] = self._y.js_apply(o, stack)
      }
      stack.shift()
    }
    stack.shift()

    # order
    _index=nil
    case (s.order) 
      when "inside-out" 
        
        max  = dy.map {|v| pv.max.index(v) }
        map  = pv.range(n).sort {|a,b| return max[a] - max[b]}
        sums = dy.map {|v| pv.sum(v)}
        top = 0
        bottom = 0
        tops = []
        bottoms = []
        n.times {|i|
          j = map[i]
          if (top < bottom) 
            top += sums[j];
            tops.push(j);
          else
            bottom += sums[j];
            bottoms.push(j);
          end
        }
        _index = bottoms.reverse+tops
        
      when "reverse"
        _index = pv.range(n - 1, -1, -1)
      else
        _index = pv.range(n)
    end
    
    #/* offset */
    case (s.offset) 
      when "silohouette"
        m.times {|j|
          o = 0;
          n.times {|i| 
            o += dy[i][j]
          }
          y[index[0]][j] = (h - o) / 2.0;
        }
      
      when "wiggle"
        o = 0;
        n.times {|i|  o += dy[i][0] }
        
        y[index[0]][0] = o = (h - o) / 2.0
        
        (1...m).each  {|j|
          s1 = 0
          s2 = 0
          dx = x[j] - x[j - 1]
          n.times {|i| s1 += dy[i][j]}
          n.times {|i|
            
            s3 = (dy[index[i]][j] - dy[index[i]][j - 1]) / (2.0 * dx)
            i.times {|k|
              s3 += (dy[index[k]][j] - dy[index[k]][j - 1]) / dx.to_f
            }
            s2 += s3 * dy[index[i]][j]
          }
          o -= (s1!=0) ? s2 / s1.to_f * dx : 0
          y[index[0]][j] = o
          
        }
      when "expand"
        m.times {|j|
          y[index[0]][j] = 0
          
          k = 0
          n.times {|i|k += dy[i][j]}
          if (k!=0) 
            k = h / k.to_f
            n.times {|i| dy[i][j] *= k}
          else 
            k = h / n.to_f
            n.times { dy[i][j] = k}
          end
        }
      else
        m.times {|j| y[index[0]][j] = 0}
    end

     # Propagate the offset to the other series. */
     m.times {|j|
      o = y[index[0]][j]
      (1...n).each {|i|
        
        o += dy[index[i - 1]][j]
        y[index[i]][j] = o
      }
    }

    # /* Find the property definitions for dynamic substitution. */
    
    i = orient.index("-")
    pdy = horizontal ? "h" : "w"
    px = i < 0 ? (horizontal ? "l" : "b") : orient[i + 1,1]
    py = orient[0,1]
    @prop.each {|k,v|
      @prop[k]=@none
    }
    @prop[px] =lambda {|i,j| x[j]}
    @prop[py] =lambda {|i,j| y[i][j]}
    @prop[pdy]=lambda {|i,j| dy[i][j]}  
    end
    def layer
      pv.Mark.new().data(lambda { values[self.parent.index] })
      .top(proxy("t"))
      .left(proxy("l"))
      .right(proxy("r"))
      .bottom(proxy("b"))
      .width(proxy("w"))
      .height(proxy("h"))
    end
    def layer_add(type)
      that=self
      self.add(pv.Panel).data(lambda {that.layers()}).add(type).extend(self)
    end
  end
  end
end
