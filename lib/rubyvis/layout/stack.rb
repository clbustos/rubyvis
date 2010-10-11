module Rubyvis
  class Stack < Rubyvis::Layout
    def initialize
      @none=lambda {return nil}
      @prop = {:t=> none, :l=> none, :r=> none, :b=> none, :w=> none, :h=> none}
      @values=nil
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
    stack = pv.Mark.stack
    
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
    case (s.offset) {
      when "silohouette"
        for (var j = 0; j < m; j++) {
          var o = 0;
          for (var i = 0; i < n; i++) o += dy[i][j];
          y[index[0]][j] = (h - o) / 2;
        }
        break;
      
      when "wiggle"
        var o = 0;
        for (var i = 0; i < n; i++) o += dy[i][0];
        y[index[0]][0] = o = (h - o) / 2;
        for (var j = 1; j < m; j++) {
          var s1 = 0, s2 = 0, dx = x[j] - x[j - 1];
          for (var i = 0; i < n; i++) s1 += dy[i][j];
          for (var i = 0; i < n; i++) {
            var s3 = (dy[index[i]][j] - dy[index[i]][j - 1]) / (2 * dx);
            for (var k = 0; k < i; k++) {
              s3 += (dy[index[k]][j] - dy[index[k]][j - 1]) / dx;
            }
            s2 += s3 * dy[index[i]][j];
          }
          y[index[0]][j] = o -= s1 ? s2 / s1 * dx : 0;
        }
        break;
      
      when "expand"
        for (var j = 0; j < m; j++) {
          y[index[0]][j] = 0;
          var k = 0;
          for (var i = 0; i < n; i++) k += dy[i][j];
          if (k) {
            k = h / k;
            for (var i = 0; i < n; i++) dy[i][j] *= k;
          } else {
            k = h / n;
            for (var i = 0; i < n; i++) dy[i][j] = k;
          }
        }
        break;
      else
        for (var j = 0; j < m; j++) y[index[0]][j] = 0;
    end

    
    
    
    
    
    
    
    
      
    end
  end
end
