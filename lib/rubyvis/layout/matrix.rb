module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Matrix
    def self.Matrix
      Rubyvis::Layout::Matrix
    end

    # Implements a network visualization using a matrix view. This is, in
    # effect, a visualization of the graph's <i>adjacency matrix</i>: the cell at
    # row <i>i</i>, column <i>j</i>, corresponds to the link from node <i>i</i> to
    # node <i>j</i>. The fill color of each cell is binary by default, and
    # corresponds to whether a link exists between the two nodes. If the underlying
    # graph has links with variable values, the <tt>fillStyle</tt> property can be
    # substited to use an appropriate color function, such as {@link pv.ramp}.
    #
    # <p>For undirected networks, the matrix is symmetric around the diagonal. For
    # directed networks, links in opposite directions can be rendered on opposite
    # sides of the diagonal using <tt>directed(true)</tt>. The graph is assumed to
    # be undirected by default.
    #
    # <p>The mark prototypes for this network layout are slightly different than
    # other implementations:<ul>
    #
    # <li><tt>node</tt> - unsupported; undefined. No mark is needed to visualize
    # nodes directly, as the nodes are implicit in the location (rows and columns)
    # of the links.
    #
    # <p><li><tt>link</tt> - for rendering links; typically a {@link pv.Bar}. The
    # link mark is added directly to the layout, with the data property defined as
    # all possible pairs of nodes. Each pair is represented as a
    # {@link pv.Network.Layout.Link}, though the <tt>linkValue</tt> attribute may
    # be 0 if no link exists in the graph.
    #
    # <p><li><tt>label</tt> - for rendering node labels; typically a
    # {@link pv.Label}. The label mark is added directly to the layout, with the
    # data property defined via the layout's <tt>nodes</tt> property; note,
    # however, that the nodes are duplicated so as to provide a label across the
    # top and down the side. Properties such as <tt>strokeStyle</tt> and
    # <tt>fillStyle</tt> can be overridden to compute properties from node data
    # dynamically.
    #
    # </ul>For more details on how to use this layout, see
    # {@link pv.Layout.Network}.
    class Matrix < Network
      @properties=Network.properties.dup
      attr_accessor :_n, :_dx, :_dy, :_labels, :_pairs
      def build_implied_post(s)
        @_n = s.nodes.size
        @_dx = s.width.to_f / @_n
        @_dy = s.height.to_f / @_n
        @_labels = s._matrix.labels
        @_pairs = s._matrix.pairs
      end
      # Deletes special add from network
      def _link # :nodoc:
        #that=self
        l=Mark.new().
        mark_extend(@node).
        data(lambda {|d| [d.source_node, d.target_node] }).
        fill_style(nil).
        line_width(lambda {|d,_p| _p.link_value * 1.5 }).
        stroke_style("rgba(0,0,0,.2)")
        l
      end

      def initialize
        super
        @_n=nil, # cached matrix size
        @_dx=nil, # cached cell width
        @_dy=nil, # cached cell height
        @_labels=nil, # cached labels (array of strings)
        @_pairs=nil, # cached pairs (array of links)
        that=self
        #/* Links are all pairs of nodes. */
        @link.data(lambda  {that._pairs}).
          left(lambda { that._dx * (self.index % that._n) }).
          top(lambda  { that._dy * (self.index / that._n.to_f).floor }).
          width(lambda  { that._dx }).
          height(lambda  { that._dy }).
          line_width(1.5).
          stroke_style("#fff").
        fill_style(lambda {|l| l.link_value!=0 ? "#555" : "#eee" })

        @link.parent = self
        #/* No special add for links! */

        # delete this.link.add;

        #/* Labels are duplicated for top & left. */
        @node_label.
        data(lambda  { that._labels }).
        left(lambda  { (self.index & 1)!=0 ? that._dx * ((self.index >> 1) + 0.5) : 0 }).
        top(lambda  { (self.index & 1)!=0 ? 0 : that._dy * ((self.index >> 1) + 0.5) }).
        text_margin(4).text_align(lambda  { (self.index & 1)!=0 ? "left" : "right"; }).
        text_angle(lambda  { (self.index & 1)!=0 ? -Math::PI / 2.0 : 0; });
        @node=nil
      end
      def self.defaults
        Matrix.new.mark_extend(Network.defaults).
        directed(true)
      end
      ##
      # :attr: directed
      #
      # Whether this matrix visualization is directed (bidirectional). By default,
      # the graph is assumed to be undirected, such that the visualization is
      # symmetric across the matrix diagonal. If the network is directed, then
      # forward links are drawn above the diagonal, while reverse links are drawn
      # below.
      #
      # @type boolean
      # @name pv.Layout.Matrix.prototype.directed
      #/

      attr_accessor_dsl :directed


      # Specifies an optional sort function. The sort function follows the same
      # comparator contract required by {@link pv.Dom.Node#sort}. Specifying a sort
      # function provides an alternative to sort the nodes as they are specified by
      # the <tt>nodes</tt> property; the main advantage of doing this is that the
      # comparator function can access implicit fields populated by the network
      # layout, such as the <tt>linkDegree</tt>.
      #
      # <p>Note that matrix visualizations are particularly sensitive to order. This
      # is referred to as the seriation problem, and many different techniques exist
      # to find good node orders that emphasize clusters, such as spectral layout and
      # simulated annealing.
      #
      # @param {function} f comparator function for nodes.
      # @returns {pv.Layout.Matrix} this.
      #/
      def sort(f=nil,&block)
        f||=block
        @sort=f
        self
      end
      def build_implied(s) # :nodoc:
        return nil if network_build_implied(s)
        nodes = s.nodes
        links = s.links
        sort = @sort

        n = nodes.size
        index = Rubyvis.range(n)
        labels = []
        pairs = []
        map = {}

        s._matrix = OpenStruct.new({:labels=> labels, :pairs=> pairs})

        #/* Sort the nodes. */
        if sort
          index.sort! {|a,b| sort.call(nodes[a],nodes[b])}
        end
        #/* Create pairs. */
        n.times {|i|
          n.times {|j|
            a = index[i]
            b = index[j]
            _p = OpenStruct.new({
              :row=> i,
              :col=> j,
              :source_node=> nodes[a],
              :target_node=> nodes[b],
            :link_value=> 0})
            map["#{a}.#{b}"] = _p
            pairs.push(map["#{a}.#{b}"])
          }
        }
        #/* Create labels. */
        n.times {|i|
          a = index[i]
          labels.push(nodes[a], nodes[a])
        }
        #/* Accumulate link values. */
        links.each_with_index {|l,i|
          source = l.source_node.index
          target = l.target_node.index
          value = l.link_value
          map["#{source}.#{target}"].link_value += value
          map["#{target}.#{source}"].link_value += value if (!s.directed)
        }
        build_implied_post(s)
      end
    end
  end
end
