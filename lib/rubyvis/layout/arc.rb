module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Arc
    def self.Arc
      Rubyvis::Layout::Arc
    end
    
    # Implements a layout for arc diagrams. An arc diagram is a network
    # visualization with a one-dimensional layout of nodes, using circular arcs to
    # render links between nodes. For undirected networks, arcs are rendering on a
    # single side; this makes arc diagrams useful as annotations to other
    # two-dimensional network layouts, such as rollup, matrix or table layouts. For
    # directed networks, links in opposite directions can be rendered on opposite
    # sides using <tt>directed(true)</tt>.
    #
    # <p>Arc layouts are particularly sensitive to node ordering; for best results,
    # order the nodes such that related nodes are close to each other. A poor
    # (e.g., random) order may result in large arcs with crossovers that impede
    # visual processing. A future improvement to this layout may include automatic reordering using, e.g., spectral graph layout or simulated annealing.
    #
    # This visualization technique is related to that developed by  M. Wattenberg, {Arc Diagrams: Visualizing Structure in Strings}[http://www.research.ibm.com/visual/papers/arc-diagrams.pdf] in IEEE InfoVis, 2002.
    # However, this implementation is limited to simple node-link networks, as
    # opposed to structures with hierarchical self-similarity (such as strings).
    # As with other network layouts, three mark prototypes are provided:<ul>
    #
    # <li><tt>node</tt> - for rendering nodes; typically a Rubyvis::Dot
    # <li><tt>link</tt> - for rendering links; typically a Rubyvis::Line
    # <li><tt>node_label</tt> - for rendering node labels; typically a Rubyvis::Label
    #
    # </ul>
    # For more details on how this layout is structured and can be customized,
    # see Rubyvis::Layout::Network
    
    class Arc < Network
      @properties=Network.properties.dup
      
      attr_accessor :_interpolate # :nodoc:
      attr_accessor :_directed    # :nodoc:
      attr_accessor :_reverse     # :nodoc:
      def initialize
        super
        @_interpolate=nil # cached interpolate
        @_directed=nil # cached directed
        @_reverse=nil # cached reverse
        @_sort=nil
        that=self
        @link.data(lambda {|_p|
            s=_p.source_node;t=_p.target_node
            that._reverse != (that._directed or (s.breadth < t.breadth)) ? [s, t] : [t, s]
        }).interpolate(lambda{ that._interpolate})
      end
      
      def build_implied(s) # :nodoc:
        return true if network_build_implied(s)
        # Cached
        
        nodes = s.nodes
        orient = s.orient
        sort = @_sort
        index = Rubyvis.range(nodes.size)
        w = s.width
        h = s.height
        r = [w,h].min / 2.0 
        # /* Sort the nodes. */
        if (sort)
          index.sort! {|a,b| sort.call(nodes[a],nodes[b])}
        end
        
        
        
        #/** @private Returns the mid-angle, given the breadth. */
        mid_angle=lambda do |b| 
          case orient 
            when "top"
              -Math::PI / 2.0
            when "bottom"
              Math::PI / 2.0
            when "left"
              Math::PI
            when "right"
              0
            when "radial"
              (b - 0.25) * 2.0 * Math::PI
          end
        end
        
        # /** @private Returns the x-position, given the breadth. */
        x= lambda do |b|
          case orient 
            when "top"
              b * w
            when "bottom"
             b * w
            when "left"
            0;
            when "right"
            w;
            when "radial"
              w / 2.0 + r * Math.cos(mid_angle.call(b))
          end
        end
        
        # /** @private Returns the y-position, given the breadth. */
        y=lambda do |b| 
          case orient 
          when "top"
            0;
          when "bottom"
            h;
          when "left"
            b* h
          when "right"
            b * h
          when "radial"
            h / 2.0 + r * Math.sin(mid_angle.call(b))
          end
        end
        
        #/* Populate the x, y and mid-angle attributes. */
        nodes.each_with_index do |nod, i|
          n=nodes[index[i]]
          n.breadth=(i+0.5) / nodes.size
          b=n.breadth
          n.x=x[b]
          n.y=y[b]
          n.mid_angle=mid_angle[b]
        end        
        
        @_directed = s.directed
        @_interpolate = s.orient == "radial" ? "linear" : "polar"
        @_reverse = s.orient == "right" or s.orient == "top"
        
      end
      
      ##
      # :attr: orient
      # The orientation. The default orientation is "bottom", which means that nodes  will be positioned from bottom-to-top in the order they are specified in the
      # <tt>nodes</tt> property. The following orientations are supported:<ul>
      #
      # <li>left - left-to-right.
      # <li>right - right-to-left.
      # <li>top - top-to-bottom.
      # <li>bottom - bottom-to-top.
      # <li>radial - radially, starting at 12 o'clock and proceeding clockwise.</ul>
      
      ##
      # :attr: directed
      # Whether this arc digram is directed (bidirectional); only applies to
      # non-radial orientations. By default, arc digrams are undirected, such that
      # all arcs appear on one side. If the arc digram is directed, then forward
      # links are drawn on the conventional side (the same as as undirected
      # links--right, left, bottom and top for left, right, top and bottom,
      # respectively), while reverse links are drawn on the opposite side.
      
      attr_accessor_dsl :orient, :directed
      # Default properties for arc layouts. By default, the orientation is "bottom".
      def self.defaults
        Arc.new.mark_extend(Network.defaults).
          orient("bottom")
      end
      
      # Specifies an optional sort function. The sort function follows the same
      # comparator contract required by Rubyvis::Dom::Node.sort(). Specifying a sort
      # function provides an alternative to sort the nodes as they are specified by
      # the <tt>nodes</tt> property; the main advantage of doing this is that the
      # comparator function can access implicit fields populated by the network
      # layout, such as the <tt>link_degree</tt>.
      #
      # <p>Note that arc diagrams are particularly sensitive to order. This is
      # referred to as the seriation problem, and many different techniques exist to
      # find good node orders that emphasize clusters, such as spectral layout and
      # simulated annealing.
      def sort(f=nil,&block)
        f||=block
        @_sort=f
        self
      end
      
      
    end
  end
end

