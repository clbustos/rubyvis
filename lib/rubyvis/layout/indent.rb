module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Indent 
    def self.Indent
      Rubyvis::Layout::Indent
    end
    # Implements a hierarchical layout using the indent algorithm. This
    # layout implements a node-link diagram where the nodes are presented in
    # preorder traversal, and nodes are indented based on their depth from the
    # root. This technique is used ubiquitously by operating systems to represent
    # file directories; although it requires much vertical space, indented trees
    # allow efficient <i>interactive</i> exploration of trees to find a specific
    # node. In addition they allow rapid scanning of node labels, and multivariate
    # data such as file sizes can be displayed adjacent to the hierarchy.
    #
    # <p>The indent layout can be configured using the <tt>depth</tt> and
    # <tt>breadth</tt> properties, which control the increments in pixel space for
    # each indent and row in the layout. This layout does not support multiple
    # orientations; the root node is rendered in the top-left, while
    # <tt>breadth</tt> is a vertical offset from the top, and <tt>depth</tt> is a
    # horizontal offset from the left.
    #
    # <p>For more details on how to use this layout, see
    # Rubyvis::Layout::Hierarchy
    class Indent < Hierarchy
      @properties=Hierarchy.properties.dup 
      # Constructs a new, empty indent layout. Layouts are not typically constructed
      # directly; instead, they are added to an existing panel via
      # Rubyvis::Mark.add
      def initialize
        super
        @link.interpolate("step-after")
      end
      
      ##
      # :attr: depth
      # The horizontal offset between different levels of the tree; defaults to 15.
      #
      
      ##
      # :attr: breadth
      # The vertical offset between nodes; defaults to 15.
      #
      
      attr_accessor_dsl :depth, :breadth
      
      # Default properties for indent layouts. By default the depth and breadth
      # offsets are 15 pixels.
      def self.defaults
        Rubyvis::Layout::Indent.new.mark_extend(Rubyvis::Layout::Hierarchy.defaults).
          depth(15).
          breadth(15)
      end
      
      def position(n, breadth, depth)
        n.x = @ax + depth * @dspace
        depth+=1
        n.y = @ay + breadth * @bspace
        breadth+=1
        n.mid_angle = 0
        c=n.first_child
        while c
          breadth=position(c,breadth,depth)
          c=c.next_sibling
        end
        breadth;
      end
      private :position
      def build_implied(s)
        return nil if hierarchy_build_implied(s)
        nodes = s.nodes
        @bspace = s.breadth
        @dspace = s.depth
        @ax = 0
        @ay = 0
        position(nodes[0], 1, 1)
      end
      
    end
  end
end
