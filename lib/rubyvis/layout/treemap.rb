module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Treemap
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
    # style by default; typically a Rubyvis::Panel or another layout!
    #
    # <p><li><tt>link</tt> - unsupported; undefined. Links are encoded implicitly
    # in the arrangement of the space-filling nodes.
    #
    # <p><li><tt>label</tt> - for rendering node labels; typically a
    # Rubyvis::Label.
    #
    # </ul>For more details on how to use this layout, see
    # Rubyvis::Layout::Hierarchy.
    #
    class Treemap < Hierarchy
      @properties=Hierarchy.properties.dup
      def initialize
        super
        @size=lambda {|d| d.node_value.to_f}
        
        @node.stroke_style("#fff").
          fill_style("rgba(31, 119, 180, .25)").
          width(lambda {|n| n.dx}).
          height(lambda {|n| n.dy })
        
        @node_label.
          visible(lambda {|n| !n.first_child }).
          left(lambda {|n| n.x + (n.dx / 2.0) }).
          top(lambda {|n| n.y + (n.dy / 2.0) }).
          text_align("center").
          text_angle(lambda {|n| n.dx > n.dy ? 0 : -Math::PI / 2.0 })
      end
      
      def leaf
        m=Rubyvis::Mark.new.
        mark_extend(self.node).
        fill_style(nil).
        stroke_style(nil).
        visible(lambda {|n| !n.first_child })
        m.parent = self
        m
      end
      def link
        nil
      end
      
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
      def self.defaults
        Rubyvis::Layout::Treemap.new.mark_extend(Rubyvis::Layout::Hierarchy.defaults).
        mode("squarify"). # squarify, slice-and-dice, slice, dice
        order('ascending') # ascending, descending, reverse, nil
      end
      
      # Alias for setting the left, right, top and bottom padding properties
      # simultaneously.
      def padding(n)
        padding_left(n).padding_right(n).padding_top(n).padding_bottom(n)
      end
      def _size(d)
        @size.call(d)
      end
     
      ##
      # Specifies the sizing function. By default, the size function uses the
      # +node_value+ attribute of nodes as a numeric value: 
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
        @size=Rubyvis.functor(f)
        self
      end
      
      
      def build_implied(s)
        return nil if hierarchy_build_implied(s)
        
        that=self
        nodes = s.nodes
        root = nodes[0]
        stack = Mark.stack
        
        left = s.padding_left
        right = s.padding_right
        top = s.padding_top
        bottom = s.padding_bottom
        left||=0
        right||=0
        top||=0
        bottom||=0
        size=lambda {|n| n.size}
        round = s.round ? 
          lambda {|a| a.round } : 
          lambda {|a| a.to_f}
        mode = s.mode
        
        slice=lambda { |row, sum, horizontal, x, y, w, h|
          # puts "slice:#{sum},#{horizontal},#{x},#{y},#{w},#{h}"
          d=0
          row.size.times {|i|
            n=row[i]
            # puts "i:#{i},d:#{d}"
            if horizontal
              n.x = x + d
              n.y = y
              d += n.dx = round.call(w * n.size / sum.to_f)
              n.dy = h
            else
              n.x = x
              n.y = y + d
              n.dx = w
              d += n.dy = round.call(h * n.size / sum.to_f)
            end
            # puts "n.x:#{n.x}, n.y:#{n.y}, n.dx:#{n.dx}, n.dy:#{n.dy}"
          }
          
         
          if (row.last)  # correct on-axis rounding error
            n=row.last
            if (horizontal) 
              n.dx += w - d
            else 
              n.dy += h - d
            end
          end
        }
        
        ratio=lambda {|row, l|
          rmax = -Infinity
          rmin = Infinity
          s = 0
          row.each_with_index {|v,i|
            r = v.size
            rmin = r if (r < rmin)
            rmax = r if (r > rmax)
            s += r
          }
          s = s * s
          l = l * l
          [l * rmax / s.to_f, s.to_f / (l * rmin)].max
        }
        
        layout=lambda {|n,i| 
          x = n.x + left
          y = n.y + top
          w = n.dx - left - right
          h = n.dy - top - bottom
          
          # puts "Layout: '#{n.node_name}', #{n.x}, #{n.y}, #{n.dx}, #{n.dy}"
          #/* Assume squarify by default. */
          if (mode != "squarify")
            slice.call(n.child_nodes, n.size, ( mode == "slice" ? true : mode == "dice" ? false : (i & 1)!=0), x, y, w, h)
          else
            row = []
            mink = Infinity
            l = [w,h].min
            k = w * h / n.size.to_f
            #/* Abort if the size is nonpositive. */
            
            if (n.size > 0) 
              #/* Scale the sizes to fill the current subregion. */
              n.visit_before {|n1,i1| n1.size *= k }
              
              #/** @private Position the specified nodes along one dimension. */
              position=lambda {|row1| 
                horizontal = w == l
                sum = Rubyvis.sum(row1, size)
                r = l>0 ? round.call(sum / l.to_f) : 0
                slice.call(row1, sum, horizontal, x, y, horizontal ? w : r, horizontal ? r : h)
                if horizontal 
                  y += r
                  h -= r
                else
                  x += r
                  w -= r
                end
                l = [w, h].min
                horizontal
              }
              
              children = n.child_nodes.dup # copy
              while (children.size>0) do
                child = children[children.size - 1]
                if (child.size==0) 
                  children.pop
                  next
                end
                row.push(child)
                
                k = ratio.call(row, l)
                
                if (k <= mink) 
                  children.pop
                  mink = k
                else 
                  row.pop
                  position.call(row)
                  row.clear
                  mink = Infinity
                end
              end
              
              #/* correct off-axis rounding error */
              
              if (position.call(row))
                row.each {|v|
                  v.dy+=h
                }
              else
                row.each {|v|
                  v.dx+=w
                }
              end              
            end
          end
        }
        
               
        stack.unshift(nil)
        root.visit_after {|nn,i|
          nn.depth = i
          nn.x = nn.y = nn.dx = nn.dy = 0
          if nn.first_child
            nn.size=Rubyvis.sum(nn.child_nodes, lambda {|v| v.size})
          else
            stack[0]=nn
            nn.size=that._size(stack[0])
          end
        }
        stack.shift()
        
        #/* Sort. */
        
        case s.order
          when 'ascending'
            root.sort(lambda {|a,b| a.size<=>b.size})
          when 'descending'
            root.sort(lambda {|a,b| b.size<=>a.size})
          when 'reverse'
            root.reverse
        end
        # /* Recursively compute the layout. */
        root.x = 0;
        root.y = 0;
        root.dx = s.width
        root.dy = s.height
        root.visit_before {|n,i| layout.call(n,i)}
      end
      
    end
  end
end
