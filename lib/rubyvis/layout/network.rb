module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Network 
    def self.Network
      Rubyvis::Layout::Network
    end

    # Represents an abstract layout for network diagrams. This class
    # provides the basic structure for both node-link diagrams (such as
    # force-directed graph layout) and space-filling network diagrams (such as
    # sunbursts and treemaps). Note that "network" here is a general term that
    # includes hierarchical structures; a tree is represented using links from
    # child to parent.
    #
    # <p>Network layouts require the graph data structure to be defined using two
    # properties:<ul>
    #
    # <li><tt>nodes</tt> - an array of objects representing nodes. Objects in this
    # array must conform to the {@link pv.Layout.Network.Node} interface; which is
    # to say, be careful to avoid naming collisions with automatic attributes such
    # as <tt>index</tt> and <tt>linkDegree</tt>. If the nodes property is defined
    # as an array of primitives, such as numbers or strings, these primitives are
    # automatically wrapped in an object; the resulting object's <tt>nodeValue</tt>
    # attribute points to the original primitive value.
    #
    # <p><li><tt>links</tt> - an array of objects representing links. Objects in
    # this array must conform to the {@link pv.Layout.Network.Link} interface; at a
    # minimum, either <tt>source</tt> and <tt>target</tt> indexes or
    # <tt>sourceNode</tt> and <tt>targetNode</tt> references must be set. Note that
    # if the links property is defined after the nodes property, the links can be
    # defined in terms of <tt>this.nodes()</tt>.
    #
    # </ul>
    #
    # <p>Three standard mark prototypes are provided:<ul>
    #
    # <li><tt>node</tt> - for rendering nodes; typically a {@link pv.Dot}. The node
    # mark is added directly to the layout, with the data property defined via the
    # layout's <tt>nodes</tt> property. Properties such as <tt>strokeStyle</tt> and
    # <tt>fillStyle</tt> can be overridden to compute properties from node data
    # dynamically.
    #
    # <p><li><tt>link</tt> - for rendering links; typically a {@link pv.Line}. The
    # link mark is added to a child panel, whose data property is defined as
    # layout's <tt>links</tt> property. The link's data property is then a
    # two-element array of the source node and target node. Thus, poperties such as
    # <tt>strokeStyle</tt> and <tt>fillStyle</tt> can be overridden to compute
    # properties from either the node data (the first argument) or the link data
    # (the second argument; the parent panel data) dynamically.
    #
    # <p><li><tt>label</tt> - for rendering node labels; typically a
    # {@link pv.Label}. The label mark is added directly to the layout, with the
    # data property defined via the layout's <tt>nodes</tt> property. Properties
    # such as <tt>strokeStyle</tt> and <tt>fillStyle</tt> can be overridden to
    # compute properties from node data dynamically.
    #
    # </ul>Note that some network implementations may not support all three
    # standard mark prototypes; for example, space-filling hierarchical layouts
    # typically do not use a <tt>link</tt> prototype, as the parent-child links are
    # implied by the structure of the space-filling <tt>node</tt> marks.  Check the
    # specific network layout for implementation details.
    #
    # <p>Network layout properties, including <tt>nodes</tt> and <tt>links</tt>,
    # are typically cached rather than re-evaluated with every call to render. This
    # is a performance optimization, as network layout algorithms can be
    # expensive. If the network structure changes, call {@link #reset} to clear the
    # cache before rendering. Note that although the network layout properties are
    # cached, child mark properties, such as the marks used to render the nodes and
    # links, <i>are not</i>. Therefore, non-structural changes to the network
    # layout, such as changing the color of a mark on mouseover, do not need to
    # reset the layout.
    #
    # @see Rubyvis::Layout::Hierarchy
    # @see Rubyvis::Layout::Force
    # @see Rubyvis::Layout::Matrix
    # @see Rubyvis::Layout::Arc
    # @see Rubyvis::Layout::Rollup
    class Network < Rubyvis::Layout
      @properties=Layout.properties.dup
      attr_accessor :_id
      def initialize
        super
        @_id=Rubyvis.id()
      end
      # The node prototype. This prototype is intended to be used with a 
      # Dot mark in conjunction with the link prototype.      
      def node
        that=self
        Mark.new().
          data(lambda {that.nodes()}).
          stroke_style("#1f77b4").
          fill_style("#fff").
          left(lambda {|n| n.x }).
          top(lambda {|n| n.y }).parent = self
      end
      module LinkAdd
        attr_accessor :that
        def add(type)
          that=@that
          return that.add(Rubyvis::Panel).
          data(lambda { that.links() }).
          add(type).
          extend(self)
        end
      end
      
     # The link prototype, which renders edges between source nodes and target
     # nodes. This prototype is intended to be used with a Line mark in
     # conjunction with the node prototype.
      
      def link
        that=self
        l=Mark.new().
          extend(self.node).
          data(lambda {|_p| [_p.source_node, p.target_node] }).
          fill_style(nil).
          line_width(lambda {|d,_p| p.link_value * 1.5 }).
          stroke_style("rgba(0,0,0,.2)")
        l.extends(LinkAdd)
        l.that=self
        l
      end

      # The node label prototype, which renders the node name adjacent to the node.
      # This prototype is provided as an alternative to using the anchor on the
      # node mark; it is primarily intended to be used with radial node-link
      # layouts, since it provides a convenient mechanism to set the text angle.
      # NOTE FOR PROTOVIS USERS: The original name of method was +label+
      # but it was replaced to not conflict with Mark.label() 
      def node_label
        that=self
        Mark.new.extend(self.node).
          text_margin(7).
          text_baseline("middle").
          text(lambda {|n| n.node_name ? n.node_name : n.node_value }).
          text_angle(lambda {|n| 
            a = n.mid_angle
            Rubyvis::Wedge.upright(a) ? a : (a + Math::PI)
          }).
          text_align(lambda {|n| 
            Rubyvis::Wedge.upright(n.mid_angle) ? "left" : "right"
          }).parent = self
      end
      ##
      # :class: Node
      # Represents a node in a network layout. There is no explicit
      # constructor; this class merely serves to document the attributes that are
      # used on nodes in network layouts. (Note that hierarchical nodes place
      # additional requirements on node representation, vis Rubyvis::Dom::Node
      
      attr_accessor_dsl [:nodes, lambda {|v|
        out=[]
        v.each_with_index {|d,i|
          d=OpenStruct.new({:node_value=>d}) unless d.respond_to? :node_value
          d.index=i
          out.push(d)
        }
        out
      }]
      attr_accessor_dsl [:links, lambda {|v|
        out=[]
        v.map {|d|
          if !d.link_value.is_a? Numeric
            d.link_value = !d.value.is_a?(Numeric) ? 1 : d.value
          end
          d
        }
      }]

      # Resets the cache, such that changes to layout property definitions will be
      # visible on subsequent render. Unlike normal marks (and normal layouts),
      # properties associated with network layouts are not automatically re-evaluated
      # on render; the properties are cached, and any expensive layout algorithms are
      # only run after the layout is explicitly reset.
      #
      # (@returns Rubyvis::Layout::Network) self
      def reset
        self._id=Rubyvis.id()
        self
      end
      # @private Skip evaluating properties if cached. */
      
      def build_properties(s, properties)
        s_id=s._id
        s_id||=0
        if (s_id < self._id)
          layout_build_properties(s,properties)
        end
      end
      
      def build_implied(s)
        network_build_implied(s)
      end
      def network_build_implied(s)
        layout_build_implied(s)
        return true if (s._id >= self._id) 
        s._id= self._id
        s.nodes.each do |d|
          d.link_degree=0
        end
        s.links.each do |d|
          v=d.link_value
          if !d.source_node
            d.source_node=s.nodes[d.source]
          end
          d.source_node.link_degree+=v
          if !d.target_node
            d.target_node=s.nodes[d.target]
          end
          d.target_node.link_degree+=v
          
        end
      end
    end
  end
end
