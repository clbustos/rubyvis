module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Indent
    def self.Pack
      Rubyvis::Layout::Pack
    end

    # Implements a hierarchical layout using circle-packing. The meaning of
    # the exported mark prototypes changes slightly in the space-filling
    # implementation:<ul>
    #
    # <li><tt>node</tt> - for rendering nodes; typically a Rubyvis::Dot.
    #
    # <p><li><tt>link</tt> - unsupported; undefined. Links are encoded implicitly
    # in the arrangement of the space-filling nodes.
    #
    # <p><li><tt>label</tt> - for rendering node labels; typically a
    # Rubyvis::Label.
    #
    # </ul>The pack layout support dynamic sizing for leaf nodes, if a
    # {@link #size} psuedo-property is specified. The default size function returns
    # 1, causing all leaf nodes to be sized equally, and all internal nodes to be
    # sized by the number of leaf nodes they have as descendants.
    #
    # <p>The size function can be used in conjunction with the order property,
    # which allows the nodes to the sorted by the computed size. Note: for sorting
    # based on other data attributes, simply use the default <tt>null</tt> for the
    # order property, and sort the nodes beforehand using the {@link pv.Dom}
    # operator.
    #
    # <p>For more details on how to use this layout, see
    # Rubyvis::Layout::Hierarchy.
    #
    # @extends pv.Layout.Hierarchy
    # @see <a href="http://portal.acm.org/citation.cfm?id=1124772.1124851"
    # >"Visualization of large hierarchical data by circle packing"</a> by W. Wang,
    # H. Wang, G. Dai, and H. Wang, ACM CHI 2006.
    #/
    class Pack < Hierarchy
      @properties=Hierarchy.properties.dup
      def initialize
        super
        @node.
        shape_radius(lambda {|n| n.radius }).
        stroke_style("rgb(31, 119, 180)").
        fill_style("rgba(31, 119, 180, 0.25)")


        @node_label.text_align("center")

        @link=nil

        @radius = lambda { 1 }
      end


      ##
      # :attr: spacing
      # The spacing parameter; defaults to 1, which provides a little bit of padding
      # between sibling nodes and the enclosing circle. Larger values increase the
      # spacing, by making the sibling nodes smaller; a value of zero makes the leaf
      # nodes as large as possible, with no padding on enclosing circles.
      #
      # @type number

      ##
      # :attr: order
      # The sibling node order. The default order is <tt>null</tt>, which means to
      # use the sibling order specified by the nodes property as-is. A value of
      # "ascending" will sort siblings in ascending order of size, while "descending"
      # will do the reverse. For sorting based on data attributes other than size,
      # use the default <tt>null</tt> for the order property, and sort the nodes
      # beforehand using the {@link pv.Dom} operator.
      #
      # @see pv.Dom.Node#sort


      attr_accessor_dsl :spacing, :order

      ##
      # Default properties for circle-packing layouts. The default spacing parameter
      # is 1 and the default order is "ascending".
      #
      def self.defaults
        Rubyvis::Layout::Pack.new.mark_extend(Rubyvis::Layout::Hierarchy.defaults).
        spacing(1).
        order("ascending")
      end


      # TODO is it possible for spacing to operate in pixel space?
      # Right now it appears to be multiples of the smallest radius.

      ##
      # Specifies the sizing function. By default, a sizing function is disabled and
      # all nodes are given constant size. The sizing function is invoked for each
      # leaf node in the tree (passed to the constructor).
      #
      # <p>For example, if the tree data structure represents a file system, with
      # files as leaf nodes, and each file has a <tt>bytes</tt> attribute, you can
      # specify a size function as:
      #
      # <pre>    .size(function(d) d.bytes)</pre>
      #
      # As with other properties, a size function may specify additional arguments to
      # access the data associated with the layout and any enclosing panels.
      #
      # @param {function} f the new sizing function.
      # @returns {pv.Layout.Pack} this.
      def size(f)
        if f.is_a? Proc
          @radius=lambda {|*args| Math.sqrt(f.js_apply(self,args))}
        else
          f=Math.sqrt(f)
          @radius=lambda {f}
        end
        self
      end
      ## @private Compute the radii of the leaf nodes. #/

      def radii(nodes)
        stack=Mark.stack
        stack.unshift(nil)
        nodes.each {|c|
          if !c.first_child
            stack[0]=c
            c.radius = @radius.js_apply(self, stack)
          end
        }
        stack.shift
      end
      def pack_tree(n)
        nodes = []
        c=n.first_child
        while(c)
          c.radius=pack_tree(c) if c.first_child
          c.n=c._p=c
          nodes.push(c)
          c=c.next_sibling
        end

        # Sort.
        case @s.order
        when "ascending"
          nodes.sort {|a,b| a.radius<=>b.radius}
        when 'descending'
          nodes.sort {|a,b| b.radius<=>a.radius}
        when 'reverse'
          nodes.reverse
        end

        return pack_circle(nodes)
      end
      def bound(n)
        @x_min = [n.x - n.radius, @x_min].min
        @x_max = [n.x + n.radius, @x_max].max
        @y_min = [n.y - n.radius, @y_min].min
        @y_max = [n.y + n.radius, @y_max].max
      end
      def insert(a,b)
        c = a.n
        a.n = b
        b._p = a
        b.n = c
        c._p = b
      end
      def splice(a, b)
        a.n = b
        b._p = a
      end
      def intersects(a, b)
        dx = b.x - a.x
        dy = b.y - a.y
        dr = a.radius + b.radius
        (dr * dr - dx * dx - dy * dy) > 0.001 # within epsilon
      end

      ## @private #/
      def place(a, b, c)
        da = b.radius + c.radius
        db = a.radius + c.radius
        dx = b.x - a.x
        dy = b.y - a.y
        dc = Math.sqrt(dx * dx + dy * dy)
        cos = (db * db + dc * dc - da * da) / (2.0 * db * dc)
        theta = Math.acos(cos)
        x = cos * db
        h = Math.sin(theta) * db
        dx = dx/dc
        dy = dy/dc
        c.x = a.x + x * dx + h * dy
        c.y = a.y + x * dy - h * dx
      end

      # @private #/
      def transform(n, x, y, k)
        c=n.first_child
        while(c) do
          c.x += n.x
          c.y += n.y
          transform(c, x, y, k)
          c=c.next_sibling
        end
        n.x = x + k * n.x
        n.y = y + k * n.y
        n.radius *= k
        n.mid_angle=0 # Undefined on protovis
      end


      def pack_circle(nodes)
        @x_min = Infinity
        @x_max = -Infinity
        @y_min = Infinity
        @y_max = -Infinity
        a=b=c=j=k=nil


        # Create first node.
        a = nodes[0];
        a.x = -a.radius
        a.y = 0
        bound(a)

        # Create second node. #/
        if (nodes.size > 1)
          b = nodes[1]
          b.x = b.radius
          b.y = 0
          bound(b)

          # Create third node and build chain.
          if (nodes.size > 2)
            c = nodes[2]
            place(a, b, c)
            bound(c)
            insert(a, c)
            a._p = c
            insert(c, b)
            b = a.n

            # Now iterate through the rest.
            i=3
            while(i < nodes.size) do
              c=nodes[i]
              place(a, b, c)

              # Search for the closest intersection. #/
              isect = 0
              s1 = 1
              s2 = 1

              j=b.n
              while(j!=b) do
                if (intersects(j, c))
                  isect=1
                  break
                end
                j=j.n
                s1+=1
              end

              if isect==1
                k=a._p
                while(k!=j._p) do
                  if(intersects(k,c))
                    if(s2 < s1)
                      isect=-1
                      j=k
                    end
                    break
                  end
                  k=k._p
                  s2+=1
                end
              end


              # Update node chain. #/
              if (isect == 0)
                insert(a, c)
                b = c
                bound(c)
              elsif (isect > 0)
                splice(a, j)
                b = j
                i-=1
              elsif (isect < 0)
                splice(j, b)
                a = j
                i-=1
              end
              i+=1
            end


          end
        end

        # Re-center the circles and return the encompassing radius. #/
        cx = (@x_min + @x_max) / 2.0
        cy = (@y_min + @y_max) / 2.0
        cr = 0
        nodes.each do |n|
          n.x -= cx
          n.y -= cy
          cr = [cr, n.radius + Math.sqrt(n.x * n.x + n.y * n.y)].max
        end
        cr + @s.spacing
      end


      def build_implied(s)
        return nil if hierarchy_build_implied(s)
        @s=s
        nodes = s.nodes
        root = nodes[0]
        radii(nodes)

        # Recursively compute the layout. #/
        root.x = 0
        root.y = 0
        root.radius = pack_tree(root)

        w = self.width
        h = self.height
        k = 1.0 / [2.0 * root.radius / w, 2.0 * root.radius / h].max
        transform(root, w / 2.0, h / 2.0, k)
      end
    end
  end
end
