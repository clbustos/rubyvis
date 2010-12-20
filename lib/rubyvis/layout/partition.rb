module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Partition
    def self.Partition
      Rubyvis::Layout::Partition
    end
    # Implemeents a hierarchical layout using the partition (or sunburst,
    # icicle) algorithm. This layout provides both node-link and space-filling
    # implementations of partition diagrams. In many ways it is similar to
    # {@link pv.Layout.Cluster}, except that leaf nodes are positioned based on
    # their distance from the root.
    #
    # <p>The partition layout support dynamic sizing for leaf nodes, if a
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
    # @see pv.Layout.Partition.Fill
    # @extends pv.Layout.Hierarchy
    
    class Partition < Hierarchy
      include NodeLink
      @properties=Hierarchy.properties.dup  
      # Constructs a new, empty partition layout. Layouts are not typically
      # constructed directly; instead, they are added to an existing panel via
      # {@link pv.Mark#add}.
      #      
      def initialize
        super
      end
      
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
      # @type string
      
      ##
      # :attr: orient
      # The orientation. The default orientation is "top", which means that the root
      # node is placed on the top edge, leaf nodes appear at the bottom, and internal
      # nodes are in-between. The following orientations are supported:<ul>
      #
      # <li>left - left-to-right.
      # <li>right - right-to-left.
      # <li>top - top-to-bottom.
      # <li>bottom - bottom-to-top.
      # <li>radial - radially, with the root at the center.</ul>
      #
      # @type string
      
      ##
      # :attr: inner_radius
      #
      # The inner radius; defaults to 0. This property applies only to radial
      # orientations, and can be used to compress the layout radially. Note that for
      # the node-link implementation, the root node is always at the center,
      # regardless of the value of this property; this property only affects internal
      # and leaf nodes. For the space-filling implementation, a non-zero value of
      # this property will result in the root node represented as a ring rather than
      # a circle.
      #
      # @type number
      
      ##
      # :attr: outer_radius
      #
      # The outer radius; defaults to fill the containing panel, based on the height
      # and width of the layout. If the layout has no height and width specified, it
      # will extend to fill the enclosing panel.
      #
      # @type number
      
      attr_accessor_dsl :order, :orient , :inner_radius, :outer_radius
      
      # Default properties for partition layouts. The default orientation is "top".
      def self.defaults
        Rubyvis::Layout::Partition.new.mark_extend(Rubyvis::Layout::Hierarchy.defaults).
          orient("top")
      end
      def _size(f)
        if @_size.nil?
          1
        else
          @_size.call(f)
        end
      end
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
      # @returns {pv.Layout.Partition} this.
      
      def size(f=nil,&block)
        f=block if f.nil?
        raise "You should pass a proc" if f.nil?
        @_size=f
        self
      end
      def build_implied(s)
        partition_build_implied(s)
      end
      def partition_build_implied(s)
        
        return false if hierarchy_build_implied(s)
        that = self
        root = s.nodes[0]

        stack = Rubyvis::Mark.stack
        max_depth = 0

        # Recursively compute the tree depth and node size. #/
        stack.unshift(nil)
        root.visit_after {|n,i| 
          max_depth=i if i>max_depth
          if n.first_child
            n.size = Rubyvis.sum(n.child_nodes, lambda {|v| v.size})
          else
            stack[0]=n
            n.size=that._size(stack[0])
          end
          }
          
        stack.shift
        # # Order #/
        case s.order
          when 'ascending'
            root.sort(lambda {|a,b| a.size<=>b.size})
          when 'descending'
            root.sort(lambda {|a,b| b.size<=>a.size})
        end
        # Compute the unit breadth and depth of each node. #/
        ds = 1 / max_depth.to_f
        root.min_breadth = 0
        root.breadth = 0.5
        root.max_breadth = 1
        root.visit_before {|n,i| 
          b = n.min_breadth
          ss = n.max_breadth - b
          c = n.first_child
          while(c) do
            c.min_breadth=b
            b+=(c.size/n.size.to_f)*ss
            
            c.max_breadth=b
            c.breadth=(b+c.min_breadth) / 2.0
            c=c.next_sibling
            
          end
        }
        root.visit_after {|n,i|
          n.min_depth=(i-1)*ds
          n.max_depth=n.depth=i*ds
        }
        
        node_link_build_implied(s)
        false
      end
      
      # A variant of partition layout that is space-filling. The meaning of
      # the exported mark prototypes changes slightly in the space-filling
      # implementation:<ul>
      #
      # <li><tt>node</tt> - for rendering nodes; typically a {@link pv.Bar} for
      # non-radial orientations, and a {@link pv.Wedge} for radial orientations.
      #
      # <p><li><tt>link</tt> - unsupported; undefined. Links are encoded implicitly
      # in the arrangement of the space-filling nodes.
      #
      # <p><li><tt>label</tt> - for rendering node labels; typically a
      # Rubyvis::Label.
      #
      # </ul>For more details on how to use this layout, see
      # {@link pv.Layout.Partition}.
      #
      # @extends pv.Layout.Partition

      
      class Fill < Partition
        include Hierarchy::Fill
        @properties=Partition.properties.dup  
        
        # Constructs a new, empty space-filling partition layout. Layouts are not
        # typically constructed directly; instead, they are added to an existing panel
        # via {@link pv.Mark#add}.
        def initialize
          super
          fill_constructor
        end
        def build_implied(s)
          return nil if partition_build_implied(s)
          fill_build_implied(s)
        end
        
        def self.defaults
          Rubyvis::Layout::Partition::Fill.new.mark_extend(Rubyvis::Layout::Partition.defaults)
        end
        
      end
    end
  end
end
