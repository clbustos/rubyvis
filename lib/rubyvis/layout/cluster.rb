module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Cluster
    def self.Cluster
      Rubyvis::Layout::Cluster
    end

    # Implements a hierarchical layout using the cluster (or dendrogram)
    # algorithm. This layout provides both node-link and space-filling
    # implementations of cluster diagrams. In many ways it is similar to
    # {@link pv.Layout.Partition}, except that leaf nodes are positioned at maximum
    # depth, and the depth of internal nodes is based on their distance from their
    # deepest descendant, rather than their distance from the root.
    #
    # <p>The cluster layout supports a "group" property, which if true causes
    # siblings to be positioned closer together than unrelated nodes at the same
    # depth. Unlike the partition layout, this layout does not support dynamic
    # sizing for leaf nodes; all leaf nodes are the same size.
    #
    # <p>For more details on how to use this layout, see
    # Rubyvis::Layout::Hierarchy.
    #
    # @see pv.Layout.Cluster.Fill
    # @extends pv.Layout.Hierarchy
    class Cluster < Hierarchy
      include NodeLink
      attr_accessor :interpolate
       @properties=Hierarchy.properties.dup 
        # Constructs a new, empty cluster layout. Layouts are not typically
        # constructed directly; instead, they are added to an existing panel via
        # {@link pv.Mark#add}.
        attr_accessor :interpolate
        
      def initialize
        super
        @interpolate=nil
        that=self
        ## @private Cache layout state to optimize properties. #/
        @link.interpolate {that.interpolate}
      end
      ##
      # :attr: group
      # The group parameter; defaults to 0, disabling grouping of siblings. If this
      # parameter is set to a positive number (or true, which is equivalent to 1),
      # then additional space will be allotted between sibling groups. In other
      # words, siblings (nodes that share the same parent) will be positioned more
      # closely than nodes at the same depth that do not share a parent.
      #
      # @type number
      
      ##
      # :attr:orient 
      #
      # The orientation. The default orientation is "top", which means that the root
      # node is placed on the top edge, leaf nodes appear on the bottom edge, and
      # internal nodes are in-between. The following orientations are supported:<ul>
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
      # The outer radius; defaults to fill the containing panel, based on the height
      # and width of the layout. If the layout has no height and width specified, it
      # will extend to fill the enclosing panel.
      #
      # @type number
      
      attr_accessor_dsl :group, :orient, :inner_radius, :outer_radius


      
      # Defaults for cluster layouts. The default group parameter is 0 and the
      # default orientation is "top".
      #
      # @type pv.Layout.Cluster
      def self.defaults
        Cluster.new.mark_extend(Hierarchy.defaults).
          group(0).
          orient("top")
      end
      def build_implied(s)
        cluster_build_implied(s)
      end
      def cluster_build_implied(s)
        @interpolate=case s.orient
          when /^(top|bottom)$/
            'step-before'
          when /^(left|right)$/
            'step-after'
          else
            'linear'
        end
        return nil if hierarchy_build_implied(s)
        root = s.nodes[0]
        group = s.group
        breadth =nil
        depth = nil 
        leaf_count = 0
        leaf_index = 0.5 - group / 2.0

        # Count the leaf nodes and compute the depth of descendants. #/
        par = nil
        root.visit_after {|n,i|
          #puts "#{n.node_value} #{i}"
          if (n.first_child) 
            n.depth = 1 + Rubyvis.max(n.child_nodes, lambda {|nn| nn.depth })
          else
            if (group!=0 and (par != n.parent_node)) 
              par = n.parent_node
              leaf_count += group
            end
            leaf_count+=1
            n.depth = 0
          end
        }
        breadth = 1.0 / leaf_count
        depth = 1.0 / root.depth

        # Compute the unit breadth and depth of each node. #/
        par = nil
        root.visit_after  {|n,i|
          if (n.first_child) 
              n.breadth = Rubyvis.mean(n.child_nodes, lambda {|nn| nn.breadth })
           else 
            if (group!=0 and (par != n.parent_node)) 
            par = n.parent_node
            leaf_index += group
            end
            n.breadth = breadth * leaf_index
            leaf_index+=1
          end
          n.depth = 1 - n.depth * depth
        }

        # Compute breadth and depth ranges for space-filling layouts. #/
        root.visit_after {|n,i|
          n.min_breadth = n.first_child ? n.first_child.min_breadth : (n.breadth - breadth / 2.0)
          n.max_breadth = n.first_child ? n.last_child.max_breadth : (n.breadth + breadth / 2.0)
        }
        root.visit_before {|n,i|
          n.min_depth = n.parent_node ? n.parent_node.max_depth : 0
          n.max_depth = n.parent_node ? (n.depth + root.depth) : (n.min_depth + 2 * root.depth)
        }
        root.min_depth = -depth
        node_link_build_implied(s)
        false
      end
      # Constructs a new, empty space-filling cluster layout. Layouts are not
      # typically constructed directly; instead, they are added to an existing panel
      # via {@link pv.Mark#add}.
      #
      # @class A variant of cluster layout that is space-filling. The meaning of the
      # exported mark prototypes changes slightly in the space-filling
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
      # {@link pv.Layout.Cluster}.
      #
      # @extends pv.Layout.Cluster
      class Fill < Cluster
        include Hierarchy::Fill
        @properties=Cluster.properties.dup  
        def initialize
          super
          fill_constructor
        end
        def build_implied(s)
          return nil if cluster_build_implied(s)
          fill_build_implied(s)
        end
      end
      
    end
  end
end
