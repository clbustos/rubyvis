module Rubyvis
  class Layout
    def self.Treemap
      Rubyvis::Layout::Treemap
    end
  
    # Implements a space-filling rectangular layout, with the hierarchy
    # represented via containment. Treemaps represent nodes as boxes, with child
    # nodes placed within parent boxes. The size of each box is proportional 
    # to the size of the node in the tree. This particular algorithm is taken from Bruls,
    # D.M., C. Huizing, and J.J. van Wijk, <a
    # href="http://www.win.tue.nl/~vanwijk/stm.pdf">"Squarified Treemaps"</a> in
    # <i>Data Visualization 2000, Proceedings of the Joint Eurographics and IEEE
    # TCVG Sumposium on Visualization</i>, 2000, pp. 33-42.
    #
    # <p>The meaning of the exported mark prototypes changes slightly in the
    # space-filling implementation:<ul>
    #
    # <li><tt>node</tt> - for rendering nodes; typically a {@link pv.Bar}. The node
    # data is populated with <tt>dx</tt> and <tt>dy</tt> attributes, in addition to
    # the standard <tt>x</tt> and <tt>y</tt> position attributes.
    #
    # <p><li><tt>leaf</tt> - for rendering leaf nodes only, with no fill or stroke
    # style by default; typically a {@link pv.Panel} or another layout!
    #
    # <p><li><tt>link</tt> - unsupported; undefined. Links are encoded implicitly
    # in the arrangement of the space-filling nodes.
    #
    # <p><li><tt>label</tt> - for rendering node labels; typically a
    # {@link pv.Label}.
    #
    # </ul>For more details on how to use this layout, see
    # {@link pv.Layout.Hierarchy}.
    #
    class Treemap < Hierarchy
      @properties=Hierarchy.properties.dup

      def initialize
        self.node.
        stroke_style("#fff").
        fill_style("rgba(31, 119, 180, .25)").
        width(lambda {|n| n.dx}).
        height(lambda {|n| n.dy })
      
      self.node_label.
        visible(lambda {|n| !n.first_child }).
        left(lambda {|n| n.x + (n.dx / 2.0) }).
        top(lambda {|n| n.y + (n.dy / 2.0) }).
        text_align("center").
        text_angle(lambda {|n| n.dx > n.dy ? 0 : -Math::PI / 2.0 })
      end
      
      def leaf
        m=Rubyvis::Mark.new.
        extend(self.node).
        fill_style(nil).
        stroke_style(nil).
        visible(lambda {|n| !n.first_child }))
        m.parent = self
        
      end
      remove_method :link
      
      ##
      # :attr: round
      # Whether node sizes should be rounded to integer values. This has a similar
      # effect to setting <tt>antialias(false)</tt> for node values, but allows the
      # treemap algorithm to accumulate error related to pixel rounding.
      #
      # @type boolean
      
      
      
      ##
      # :attr: padding_left
      # The left inset between parent add child in pixels. Defaults to 0.
      #
      # @type number
      # @see #padding
      
      
      
      ##
      # :attr: padding_rigth
      # The right inset between parent add child in pixels. Defaults to 0.
      #
      # @type number
      # @name pv.Layout.Treemap.prototype.paddingRight
      # @see #padding
      
      
      ##
      # :attr: padding_top
      # The top inset between parent and child in pixels. Defaults to 0.
      #
      # @type number
      # @name pv.Layout.Treemap.prototype.paddingTop
      # @see #padding
      
      
      ##
      # :attr: padding_bottom      
      # The bottom inset between parent and child in pixels. Defaults to 0.
      #
      # @type number
      # @name pv.Layout.Treemap.prototype.paddingBottom
      # @see #padding
      
      
      ##
      # :attr: mode      
      # The treemap algorithm. The default value is "squarify". The "slice-and-dice"
      # algorithm may also be used, which alternates between horizontal and vertical
      # slices for different depths. In addition, the "slice" and "dice" algorithms
      # may be specified explicitly to control whether horizontal or vertical slices
      # are used, which may be useful for nested treemap layouts.
      #
      # @type string
      # @name pv.Layout.Treemap.prototype.mode
      # @see <a
      # href="ftp://ftp.cs.umd.edu/pub/hcil/Reports-Abstracts-Bibliography/2001-06html/2001-06.pdf"
      # >"Ordered Treemap Layouts"</a> by B. Shneiderman &amp; M. Wattenberg, IEEE
      # InfoVis 2001.
      
      
      ##
      # :attr: order      
      # The sibling node order. A <tt>null</tt> value means to use the sibling order
      # specified by the nodes property as-is; "reverse" will reverse the given
      # order. The default value "ascending" will sort siblings in ascending order of
      # size, while "descending" will do the reverse. For sorting based on data
      # attributes other than size, use the default <tt>null</tt> for the order
      # property, and sort the nodes beforehand using the {@link pv.Dom} operator.
      #
      # @type string
      # @name pv.Layout.Treemap.prototype.order
      

      
      
      attr_accessor_dsl :round, :padding_left, :padding_right, :padding_top, :padding_bottom, :mode, :order
      
      # Default propertiess for treemap layouts. The default mode is "squarify" and the default order is "ascending".
      def defaults
        Rubyvis::Layout::Treemap.new.extend(Rubyvis::Layout::Hierarchy.default).
        mode("squarify"). # squarify, slice-and-dice, slice, dice
        order('ascending') # ascending, descending, reverse, nil
      end
      
      # Alias for setting the left, right, top and bottom padding properties
      # simultaneously.
      def padding(n)
        padding_left(n).padding_right(n).padding_top(n).padding_bottom(n)
      end
      def _size(d)
        if @_size.nil?
          d.node_value.to_f
        else
          @_size.call(d)
        end
      end
      ##
      # Specifies the sizing function. By default, the size function uses the
      # <tt>nodeValue</tt> attribute of nodes as a numeric value: <tt>function(d)
      # Number(d.nodeValue)</tt>.
      #
      # <p>The sizing function is invoked for each leaf node in the tree, per the
      # <tt>nodes</tt> property. For example, if the tree data structure represents a
      # file system, with files as leaf nodes, and each file has a <tt>bytes</tt>
      # attribute, you can specify a size function as:
      #
      # <pre>    .size(function(d) d.bytes)</pre>
      #
      # @param {function} f the new sizing function.
      # @returns {pv.Layout.Treemap} this.
      
      def size(f)
        @_size=pv.functor(f)
      end
      def build_implied(s)
        return nil if super(s)
        that=self
        nodes = s.nodes
        root = nodes[0]
        stack = Mark.stack
        left = s.padding_left
        right = s.padding_right
        top = s.padding_top
        bottom = s.padding_bottom
        size=lamba {|n| n.size}
        # /** @ignore */ size = function(n) { return n.size; }
        round = s.round ? lambda {|a| a.round } : lambda {|a| a}
        mode = s.mode
        
        stack.unshift(nil)
        root.visit_after(lambda {|n,i|
          n.depth = i
          n.x = n.y = n.dx = n.dy = 0
          n.size = n.first_child
          ? Rubyvis.sum(n.child_nodes, lambda {|n| n.size })
            : that._size.js_apply(that, (stack[0] = n, stack))
        })
        stack.shift()
        
        #/* Sort. */
        case s.order
        when 'ascending'
          root.sort(lambda {|a,b| a.size-b.size})
        when 'descending'
          root.sort(lambda {|a,b| b.size-a.size})
        when 'reverse'
          root.reverse
        end
        
        # /* Recursively compute the layout. */
        root.x = 0;
        root.y = 0;
        root.dx = s.width;
        root.dy = s.height
        
        root.visit_before(lambda {|n,i| that.build_implied_layout(n,i)})
      end
      def build_implied_slice(row, sum, horizontal, x, y, w, h) 
        d=0
        row.each_with_index {|n,i|
          if (horizontal)
            n.x = x + d
            n.y = y
            d += n.dx = (w * n.size / sum.to_f).round
            n.dy = h
          else
            n.x = x
            n.y = y + d
            n.dx = w
            d += n.dy = (h * n.size / sum.to_f).round
          end
        }
        
        if (row.last)  # correct on-axis rounding error
          if (horizontal) 
              n.dx += w - d
          else
            n.dy += h - d
          end
        end
      end
      def build_implied_ratio(row,l)
        
        rmax = -Infinity
        rmin = Infinity
        s = 0
        rmin=0
        rmax=0
        row.each_with_index {|v,i|
          r = row[i].size
          rmin = r if (r < rmin) 
          rmax = r if (r > rmax) 
          s += r
        }
        s = s * s
        l = l * l
        
        [l * rmax / s, s / (l * rmin)].max
      end
      
      
      def build_implied_position(row)
        horizontal = w == l
        sum = Rubyvis.sum(row, size)
        
        r = l ? round(sum / l.to_f) : 0
        
        build_implied_slice(row, sum, horizontal, x, y, horizontal ? w : r, horizontal ? r : h)
        if (horizontal) 
          y += r
          h -= r
        else 
          x += r
          w -= r
        end
        l = [w, h].min
        horizontal
      end
      
      
      def build_implied_layout(n,i)
        x = n.x + left
        y = n.y + top
        w = n.dx - left - right
        h = n.dy - top - bottom

        #/* Assume squarify by default. */
        if (mode != "squarify")
          build_implied_slice(n.child_nodes, n.size,
          mode == "slice" ? true
          : mode == "dice" ? false
          : (i & 1)!=0, x, y, w, h);
          return nil;
        end

        row = []
        mink = Infinity
        l = [w, h].min
        k = w * h / n.size
        # Abort if the size is nonpositive.
        return nil if n.size<=0
        
        # Scale the sizes to fill the current subregion.
        n.visit_before(lambda {|n| n.size *= k })

        # /** @private Position the specified nodes along one dimension. */
        # children = n.child_nodes.slice(); # // copy
        children = n.child_nodes.dup
        
        while (children.size>0) 
          child = children[children.size - 1]
          if (child.size==0) 
            children.pop();
            next
          end
          
          row.push(child)
        
          k = build_implied_ratio(row, l)
          if (k <= mink)
            children.pop()
            mink = k
          else 
            row.pop()
            build_implied_position(row)
            row.length = 0
            mink = Infinity
          end
        end

        # /* correct off-axis rounding error */
        if (position(row)) 
          row.each {|r|
            r.dy+=h
          }
        else
          row.each {|r|
            r.dx+=w
          }
        end
      end
    end
  end
end
