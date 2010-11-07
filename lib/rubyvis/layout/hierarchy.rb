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
        self.link.stroke_style("#ccc")
      end
      
      # @private Compute the implied links. (Links are null by default.) */
      def build_implied(s)
        s.links=self.links() if !s.links
        network_build_implied(s)
      end

      # The implied links; computes links using the <tt>parent_node</tt> attribute.
      def links
        n=self.nodes().find_all {|n| n.parent_node}
        n.map {|n|
          OpenStruct.new({
              :source_node=>n,
              :target_node=>n.parent_node,
              :link_value=>1
        })}
      end
      def node_link
        NodeLink.new(self)
      end
      def fill
        Fill.new(self)
      end
    end
    
    class NodeLink
      attr_accessor :ir, :_or, :orient, :w, :h
      def initialize(obj)
        @obj=obj
      end
      def build_implied(s)
        nodes = s.nodes
        orient= s.orient
        orient=~/^(top|bottom)$/
        
        horizontal = $1
        w = s.width
        h = s.height
        # /* Compute default inner and outer radius. */
        if (orient == "radial") 
          ir = s.inner_radius
          _or = s.outer_radius
          ir||=0
          _or||=[w,h].min / 2.0
        end
        nodes.length.times {|i|
          n = nodes[i]
          n.mid_angle = (orient == "radial") ? mid_angle(n)
        : (horizontal ? Math::PI / 2.0 : 0)
          n.x = x(n)
          n.y = y(n)
          n.mid_angle+=Math::PI if (n.first_child)
        }      
      end
      def radius(n)
        n.parent_node ? (n.depth * (_or-ir)+ir) : 0
      end
      def min_angle(n)
        n.parent_node ? ((n.breadth - 0.25) * 2 * Math::PI ) : 0
      end
      def x(n)
        case orient
          when "left"
            n.depth*w
          when "right"
            w-n.depth*w
          when "top"
            n.breadth*w
          when "bottom"
            w-n.breath*w
          when "radial"
            w/2.0+radius(n)*Math.cos(n.mid_angle)
        end
      end
      def y(n)
        case orient
          when "left"
            n.breadth*h
          when "right"
            h-n.depth*h
          when "top"
            n.depth*h            
          when "bottom"
            h-n.breath*h
          when "radial"
            h / 2.0 + radius(n) * Math.sin(n.mid_angle)
        end # end case
      end # end method
    end # end class
    
    class Fill
      attr_accessor :ir, :_or, :orient, :w, :h
      def initialize(obj)
        @obj=obj
      end
      def constructor
        self.node.
        stroke_style("#fff").
        fill_style("#ccc").
        width(lambda {|n| n.dx}).
        height(lambda {|n| n.dy}).
        inner_radius(lambda {|n| n.inner_radius}).
        outer_radius(lambda {|n| n.outer_radius}).
        start_angle(lambda {|n| n.start_angle}).
        angle(lambda {return n.angle})
      self.node_label.
        text_align("center").
        left(lambda {|n| n.x+ (n.dx / 2.0) })
        top(lambda {|n| n.y+(n.dy / 0.2)})
        # delete this.link
      end
      def build_implied(s)
        nodes = s.nodes
        orient= s.orient
        orient=~/^(top|bottom)$/
        horizontal = $1
        w = s.width
        h = s.height
        depth = -nodes[0].min_depth
        if (orient == "radial") 
          ir = s.inner_radius
          _or = s.outer_radius
          ir||=0
          depth = depth * 2 if ir!=0
          _or||=[w,h].min / 2.0
        end
        nodes.each_with_index {|n,i|
          n.x = x(n)
          n.y = y(n)
          if (orient == "radial") 
            n.inner_radius = inner_radius(n);
            n.outer_radius = outer_radius(n);
            n.start_angle = start_angle(n);
            n.angle = angle(n);
            n.mid_Angle = n.start_angle + n.angle / 2.0;
          else 
            n.mid_angle = horizontal ? -Math::PI / 2.0 : 0;
          end
          n.dx = dx(n)
          n.dy = dy(n)
        }
      end
      
      def scale(d, depth)
        (d+depth) / (1.0+depth)
      end
      def x(n)
        case orient
          when "left"
            scale(n.min_depth,depth)*w
          when "right"
            (1-scale(n.max_depth,depth))*w
          when "top"
            n.min_breadth*w
          when "bottom"
            (1-n.max_breath)*w
          when "radial"
            w / 2.0
        end
      end
      def y(n)
        case orient
          when "left"
            n.min_breadth*h
          when "right"
            (1-n.max_breadth)*h
          when "top"
            scale(n.min_depth, depth) * h            
          when "bottom"
            (1-scale(n.max_depth, depth)) * h
          when "radial"
            h / 2.0
        end # end case
      end # end method
      def dx(n)
        if orient=='left' or orient=='right'
          (n.max_depth - n.min_depth) / (1.0 + depth) * w;
        elsif orient=='top' or orient=='bottom'
          (n.max_breadth - n.min_breadth) * w
        elsif orient=='radial'
          n.parent_node ? (n.inner_radius + n.outer_radius) * Math.cos(n.mid_angle) : 0
        end          
      end
      def dy(n)
        if orient=='left' or orient=='right'
          (n.max_breadth - n.min_breadth) * h;
        elsif orient=='top' or orient=='bottom'
          (n.max_depth - n.min_depth) / (1.0 + depth) * h;
        elsif orient=='radial'
          n.parent_node ? (n.inner_radius + n.outer_radius) * Math.sin(n.mid_angle) : 0
        end        
      end
      def inner_radius(n)
        [0, scale(n.min_depth, depth/2.0)].max * (_or - _ir) + ir
      end
      def outer_radius(n)
        scale(n.max_depth, depth / 2.0) * (_or - ir) + ir
      end
      def start_angle(n)
        (n.parent_node ? n.min_breadth - 0.25 : 0) * 2 * Math::PI
      end
      def angle(n)
        (n.parent_node ? n.max_breadt - n.min_breadth : 1 ) * 2 * Math::PI
      end
    end
  end
end
