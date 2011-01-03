module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Stack 
    def self.Stack
      Rubyvis::Layout::Stack
    end
    
    # Implements a layout for stacked visualizations, ranging from simple
    # stacked bar charts to more elaborate "streamgraphs" composed of stacked
    # areas. Stack layouts uses length as a visual encoding, as opposed to
    # position, as the layers do not share an aligned axis.
    #
    # <p>Marks can be stacked vertically or horizontally. For example,
    #
    #   vis.add(Rubyvis::Layout::Stack)
    #     .layers([[1, 1.2, 1.7, 1.5, 1.7],
    #              [.5, 1, .8, 1.1, 1.3],
    #              [.2, .5, .8, .9, 1]])
    #     .x(lambda { index * 35})
    #     .y(lambda {|d| d * 40})
    #   .layer.add(Rubyvis::Area)
    #
    # specifies a vertically-stacked area chart, using the default "bottom-left"
    # orientation with "zero" offset. This visualization can be easily changed into
    # a streamgraph using the "wiggle" offset, which attempts to minimize change in
    # slope weighted by layer thickness. See the offset property for more
    # supported streamgraph algorithms.
    #
    # <p>In the simplest case, the layer data can be specified as a two-dimensional
    # array of numbers. The <tt>x</tt> and <tt>y</tt> psuedo-properties are used to
    # define the thickness of each layer at the given position, respectively; in
    # the above example of the "bottom-left" orientation, the <tt>x</tt> and
    # <tt>y</tt> psuedo-properties are equivalent to the <tt>left</tt> and
    # <tt>height</tt> properties that you might use if you implemented a stacked
    # area by hand.
    #
    # <p>The advantage of using the stack layout is that the baseline, i.e., the
    # <tt>bottom</tt> property is computed automatically using the specified offset
    # algorithm. In addition, the order of layers can be computed using a built-in
    # algorithm via the <tt>order</tt> property.
    #
    # <p>With the exception of the "expand" <tt>offset</tt>, the stack layout does
    # not perform any automatic scaling of data; the values returned from
    # <tt>x</tt> and <tt>y</tt> specify pixel sizes. To simplify scaling math, use
    # this layout in conjunction with Rubyvis::Scale.linea} or similar.
    #
    # <p>In other cases, the <tt>values</tt> psuedo-property can be used to define
    # the data more flexibly. As with a typical panel &amp; area, the
    # <tt>layers</tt> property corresponds to the data in the enclosing panel,
    # while the <tt>values</tt> psuedo-property corresponds to the data for the
    # area within the panel. For example, given an array of data values:
    #
    #   crimea = [
    #   { date: "4/1854", wounds: 0, other: 110, disease: 110 },
    #   { date: "5/1854", wounds: 0, other: 95, disease: 105 },
    #   { date: "6/1854", wounds: 0, other: 40, disease: 95 },
    #   ...
    #
    # and a corresponding array of series names:
    #
    #   causes = [:wounds, :other, :disease]
    #
    # Separate layers can be defined for each cause like so:
    #
    #   vis.add(pv.Layout.Stack)
    #     .layers(causes)
    #     .values(crimea)
    #     .x(lambda {|d| x.scale(d[:date]})
    #     .y(lambda {|d,dp| y.scale(d[dp])})
    #   .layer.add(pv.Area)
    #
    # As with the panel &amp; area case, the datum that is passed to the
    # psuedo-properties <tt>x</tt> and <tt>y</tt> are the values (an element in
    # <tt>crimea</tt>); the second argument is the layer data (a string in
    # <tt>causes</tt>). Additional arguments specify the data of enclosing panels, if any.
    class Stack < Rubyvis::Layout
      @properties=Layout.properties.dup
      attr_accessor_dsl :orient,:offset, :order, :layers
      attr_accessor :_x, :_y, :_values, :prop

      def self.defaults
        Stack.new.mark_extend(Layout.defaults).
          orient("bottom-left").
          offset("zero").
          layers([[]])
      end
      
      # Constructs a new, empty stack layout. Layouts are not typically constructed
      # directly; instead, they are added to an existing panel via
      # Rubyvis::Mark.add
      def initialize
        super
        @none=lambda {nil}
        @prop = {"t"=> @none, "l"=> @none, "r"=> @none, "b"=> @none, "w"=> @none, "h"=> @none}
        @values=nil
        @_x=lambda {0}
        @_y=lambda {0}
        @_values=Rubyvis.identity
      end
      def x(f)
        @_x=Rubyvis.functor(f)
        return self
      end
      def y(f)
        @_y=Rubyvis.functor(f)
        return self
      end
      def values(f=nil)
        if f.nil?
          return @values
        else
          @_values=Rubyvis.functor(f)
          return self
        end
      end
      
      
      def proxy(name)
        that=self
        return lambda {
          a=that.prop[name].js_call(self, self.parent.index, self.index);
          puts "proxy(#{name}): #{a}" if $DEBUG
          a
        }
      end
      
      def build_implied(s)
        # puts "Build stack" if $DEBUG
        layout_build_implied(s)
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
          values[i] = self._values.js_apply(o.parent, stack)
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
        case s.order
        when "inside-out"
          
          max  = dy.map {|v| Rubyvis.max_index(v) }          
          _map  = Rubyvis.range(n).sort {|a,b| max[a] <=> max[b]}
          
          sums = dy.map {|v| Rubyvis.sum(v)}
          top = 0
          bottom = 0
          tops = []
          bottoms = []
          
          n.times {|i|
            j = _map[i]
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
          _index = Rubyvis.range(n - 1, -1, -1)
        else
          _index = Rubyvis.range(n)
        end
        
        #/* offset */
        case (s.offset) 
        when "silohouette"
          m.times {|j|
            o = 0;
            n.times {|i| 
              o += dy[i][j]
            }
            y[_index[0]][j] = (h - o) / 2.0;
          }
        
        when "wiggle"
          o = 0;
          n.times {|i|  o += dy[i][0] }
          
          y[_index[0]][0] = o = (h - o) / 2.0
          
          (1...m).each  {|j|
            s1 = 0
            s2 = 0
            dx = x[j] - x[j - 1]
            n.times {|i| s1 += dy[i][j]}
            n.times {|i|
              
              s3 = (dy[_index[i]][j] - dy[_index[i]][j - 1]) / (2.0 * dx)
              i.times {|k|
                s3 += (dy[_index[k]][j] - dy[_index[k]][j - 1]) / dx.to_f
              }
              s2 += s3 * dy[_index[i]][j]
            }
            o -= (s1!=0) ? s2 / s1.to_f * dx : 0
            y[_index[0]][j] = o
            
          }
        when "expand"
          m.times {|j|
            y[_index[0]][j] = 0
            
            k = 0
            n.times {|i| k += dy[i][j]}
            if (k!=0) 
              k = h / k.to_f
              n.times {|i| dy[i][j] *= k}
            else 
              k = h / n.to_f
              n.times {|i| dy[i][j] = k}
            end
          }
        else
          m.times {|j| y[_index[0]][j] = 0}
        end
        
        # Propagate the offset to the other series. */
        m.times {|j|
        o = y[_index[0]][j]
          (1...n).each {|i|
            
            o += dy[_index[i - 1]][j]
            y[_index[i]][j] = o
          }
        }
        
        # /* Find the property definitions for dynamic substitution. */
        
        i = orient.index("-")
        pdy = horizontal ? "h" : "w"
        px = i < 0 ? (horizontal ? "l" : "b") : orient[i + 1,1]
        py = orient[0,1]
        
        
        @values=values
        @prop.each {|k,v|
          @prop[k]=@none
        }
        # puts "stack: x:#{px}, y:#{py}, dy:#{pdy}" if $DEBUG
        @prop[px] =lambda {|i1,j| x[j]}
        @prop[py] =lambda {|i1,j| y[i1][j]}
        @prop[pdy]=lambda {|i1,j| dy[i1][j]}  
      end
      
      def layer
        that=self
        value = Rubyvis::Mark.new().data(lambda {  that.values[self.parent.index] }).top(proxy("t")).left(proxy("l")).right(proxy("r")).
          bottom(proxy("b")).
        width(proxy("w")).
        height(proxy("h"))
        
        class << value # :nodoc:
          def that=(v)
            @that = v
          end
          def add(type)
            that  = @that
            that.add( Rubyvis.Panel ).data(lambda { that.layers() }).add(type).mark_extend( self )
          end
        end
        
        value.that=self
        return value
      end
    end
  end
end
