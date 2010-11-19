module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Hierarchy
    def self.Hierarchy
      Rubyvis::Layout::Hierarchy
    end
    # Represents an abstract layout for hierarchy diagrams. This class is a
    # specialization of Rubyvis::Layout::Network, providing the basic structure
    # for both hierarchical node-link diagrams (such as Reingold-Tilford trees) and
    # space-filling hierarchy diagrams (such as sunbursts and treemaps).
    #
    # <p>Unlike general network layouts, the +links+ property need not be
    # defined explicitly. Instead, the links are computed implicitly from the
    # +parent_node+ attribute of the node objects, as defined by the
    # +nodes+ property. This implementation is also available as
    # +Hierarchy.links, for reuse with non-hierarchical layouts; for example, to
    # render a tree using force-directed layout.
    #
    # <p>Correspondingly, the +nodes+ property is represented as a union of
    # Rubyvis::Layout::Network::Node} and Rubyvis::Dom::Node. To construct a node
    # hierarchy from a simple JSON map, use the Rubyvis::Dom operator; this
    # operator also provides an easy way to sort nodes before passing them to the
    # layout.
    #
    # <p>For more details on how to use this layout, see
    # Rubyvis::Layout::Network
    #
    # @see Rubyvis::Layout::Cluster
    # @see Rubyvis::Layout::Partition
    # @see Rubyvis::Layout::Tree
    # @see Rubyvis::Layout::Treemap
    # @see Rubyvis::Layout::Indent
    # @see Rubyvis::Layout::Pack
    class Hierarchy < Network
      @properties=Network.properties.dup
      def initialize
        super
        @link.stroke_style("#ccc")
      end
      def build_implied(s)
        hierarchy_build_implied(s)
      end
      # @private Compute the implied links. (Links are null by default.) */
      def hierarchy_build_implied(s)
        s.links=self.links() if !s.links
        network_build_implied(s)
      end

      # The implied links; computes links using the <tt>parent_node</tt> attribute.
      def links
        l=self.nodes().find_all {|n| n.parent_node}
        l.map {|n|
          
          Network::Link.new({
              :source_node=>n,
              :target_node=>n.parent_node,
              :link_value=>1
        })}
      end
    end
    
    module NodeLink
      attr_accessor :_ir, :_or, :_orient, :_w, :_h
      def node_link_build_implied(s)
        nodes = s.nodes
        @_orient= s.orient
        horizontal= case @_orient
          when /^(top|bottom)$/
            true
          else
            false
          end
        @_w = s.width
        @_h = s.height
        
        # /* Compute default inner and outer radius. */
        if (@_orient == "radial") 
          @_ir = s.inner_radius
          @_or = s.outer_radius
          @_ir||=0
          @_or||=[@_w,@_h].min / 2.0
        end
        nodes.each_with_index{|n,i|
          n.mid_angle = (@_orient == "radial") ? mid_angle(n) : (horizontal ? Math::PI / 2.0 : 0)
          n.x = node_link_x(n)
          n.y = node_link_y(n)
          n.mid_angle+=Math::PI if (n.first_child)
        }
        false
      end
      def radius(n)
        n.parent_node ? (n.depth * (@_or-@_ir)+@_ir) : 0
      end
      def mid_angle(n)
        n.parent_node ? ((n.breadth - 0.25) * 2 * Math::PI ) : 0
      end
      def node_link_x(n)
        case @_orient
          when "left"
            n.depth*@_w
          when "right"
            @_w-n.depth*@_w
          when "top"
            n.breadth*@_w
          when "bottom"
            @_w-n.breath*@_w
          when "radial"
            @_w/2.0+radius(n)*Math.cos(n.mid_angle)
        end
      end
      def node_link_y(n)
        case @_orient
          when "left"
            n.breadth*@_h
          when "right"
            @_h-n.depth*@_h
          when "top"
            n.depth*@_h            
          when "bottom"
            @_h-n.breath*@_h
          when "radial"
            @_h / 2.0 + radius(n) * Math.sin(n.mid_angle)
        end # end case
      end # end method
      private :node_link_y, :node_link_x, :mid_angle, :radius
    end # end class
    
    module Fill
      attr_accessor :ir, :_or, :_orient, :_w, :_h
      def fill_constructor
        @node.stroke_style("#fff").
          fill_style("#ccc").
          width(lambda {|n| n.dx}).
          height(lambda {|n| n.dy}).
          inner_radius(lambda {|n| n.inner_radius}).
          outer_radius(lambda {|n| n.outer_radius}).
          start_angle(lambda {|n| n.start_angle}).
          angle(lambda {|n| n.angle})
        
          @node_label.
            text_align("center").
            left(lambda {|n| n.x+ (n.dx / 2.0) }).
            top(lambda {|n| n.y+(n.dy / 2.0)})
          @link=nil
        
      end
      
      def fill_build_implied(s)
        nodes = s.nodes
        @_orient= s.orient
        @_orient=~/^(top|bottom)$/
        horizontal = !$1.nil?
        @_w = s.width
        @_h = s.height
        @_depth = -nodes[0].min_depth
        if @_orient == "radial"
          @_ir = s.inner_radius
          @_or = s.outer_radius
          @_ir||=0
          @_depth = @_depth * 2 if @_ir!=0
          @_or||=[@_w,@_h].min / 2.0
        end
        nodes.each_with_index {|n,i|
          n.x = fill_x(n)
          n.y = fill_y(n)
          if @_orient == "radial"
            n.inner_radius = inner_radius(n);
            n.outer_radius = outer_radius(n);
            n.start_angle = start_angle(n);
            n.angle = angle(n);
            n.mid_angle = n.start_angle + n.angle / 2.0
          else 
            n.mid_angle = horizontal ? -Math::PI / 2.0 : 0
          end
          n.dx = dx(n)
          n.dy = dy(n)
        }
        false
      end
      
      def fill_scale(d, depth)
        (d + depth) / (1 + depth).to_f
      end
      def fill_x(n)
        case @_orient
          when "left"
            fill_scale(n.min_depth,@_depth)*@_w
          when "right"
            (1-fill_scale(n.max_depth,@_depth))*@_w
          when "top"
            n.min_breadth*@_w
          when "bottom"
            (1-n.max_breath)*@_w
          when "radial"
            @_w / 2.0
        end
      end
      def fill_y(n)
        case @_orient
          when "left"
            n.min_breadth*@_h
          when "right"
            (1-n.max_breadth)*@_h
          when "top"
            fill_scale(n.min_depth, @_depth) * @_h            
          when "bottom"
            (1-fill_scale(n.max_depth, @_depth)) * @_h
          when "radial"
            @_h / 2.0
        end # end case
      end # end method
      
      def dx(n)
        if @_orient=='left' or @_orient=='right'
          (n.max_depth - n.min_depth) / (1.0 + @_depth) * @_w
        elsif @_orient=='top' or @_orient=='bottom'
          (n.max_breadth - n.min_breadth) * @_w
        elsif @_orient=='radial'
          n.parent_node ? (n.inner_radius + n.outer_radius) * Math.cos(n.mid_angle) : 0
        end          
      end
      
      def dy(n)
        if @_orient=='left' or @_orient=='right'
          (n.max_breadth - n.min_breadth) * @_h
        elsif @_orient=='top' or @_orient=='bottom'
          (n.max_depth - n.min_depth) / (1.0 + @_depth) * @_h
        elsif orient=='radial'
          n.parent_node ? (n.inner_radius + n.outer_radius) * Math.sin(n.mid_angle) : 0
        end        
      end
      
      def inner_radius(n)
        [0, fill_scale(n.min_depth, @_depth/2.0)].max * (@_or - @_ir) + @_ir
      end
      
      def outer_radius(n)
        fill_scale(n.max_depth, @_depth / 2.0) * (@_or - @_ir) + @_ir
      end
      
      def start_angle(n)
        (n.parent_node ? n.min_breadth - 0.25 : 0) * 2 * Math::PI
      end
      def angle(n)
        (n.parent_node ? n.max_breadth - n.min_breadth : 1 ) * 2 * Math::PI
      end
    end
  end
end
