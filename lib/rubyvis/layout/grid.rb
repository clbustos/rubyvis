module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Grid 
    def self.Grid
      Rubyvis::Layout::Grid
    end
    
    # Implements a grid layout with regularly-sized rows and columns. The
    # number of rows and columns are determined from their respective
    # properties. For example, the 2&times;3 array:
    #
    # <pre>1 2 3
    # 4 5 6</pre>
    #
    # can be represented using the <tt>rows</tt> property as:
    #
    # <pre>[[1, 2, 3], [4, 5, 6]]</pre>
    #
    # If your data is in column-major order, you can equivalently use the
    # <tt>columns</tt> property. If the <tt>rows</tt> property is an array, it
    # takes priority over the <tt>columns</tt> property. The data is implicitly
    # transposed, as if the {@link pv.transpose} operator were applied.
    #
    # <p>This layout exports a single <tt>cell</tt> mark prototype, which is
    # intended to be used with a bar, panel, layout, or subclass thereof. The data
    # property of the cell prototype is defined as the elements in the array. For
    # example, if the array is a two-dimensional array of values in the range
    # [0,1], a simple heatmap can be generated as:
    #
    # <pre>vis.add(pv.Layout.Grid)
    #     .rows(arrays)
    #   .cell.add(pv.Bar)
    #     .fillStyle(pv.ramp("white", "black"))</pre>
    #
    # The grid subdivides the full width and height of the parent panel into equal
    # rectangles. Note, however, that for large, interactive, or animated heatmaps,
    # you may see significantly better performance through dynamic {@link pv.Image}
    # generation.
    #
    # <p>For irregular grids using value-based spatial partitioning, see {@link
    # pv.Layout.Treemap}.

    
    
    class Grid < Layout
      attr_accessor :_grid
      attr_accessor :cell
      @properties=Layout.properties.dup
      def initialize
        super
        @cell=_cell
      end
      def _cell
        that=self
        m=Rubyvis::Mark.new().
          data(lambda {that.scene[that.index]._grid}).
          width(lambda {that.width/that.cols.to_f}).
          height(lambda {that.height/that.rows.to_f}).
          left(lambda {(that.width/that.cols.to_f)*(self.index % that.cols)}).
          top(lambda {(that.height/that.rows.to_f)*(self.index / that.cols).floor})
        m.parent=self
        m
      end
      private :_cell
      
      
      ##
      # :attr: rows
      # The number of rows. This property can also be specified as the data in
      # row-major order; in this case, the rows property is implicitly set to the
      # length of the array, and the cols property is set to the length of the first
      # element in the array.
      #
      
      ##
      # :attr: cols
      #
      # The number of columns. This property can also be specified as the data in
      # column-major order; in this case, the cols property is implicitly set to the
      # length of the array, and the rows property is set to the length of the first
      # element in the array.
      #

      attr_accessor_dsl :rows, :cols
      def self.defaults
        Rubyvis::Layout::Grid.new.mark_extend(Rubyvis::Layout.defaults).
          rows(1).
          cols(1)
      end
      def build_implied(s)
        layout_build_implied(s)
        r=s.rows
        c=s.cols
        r=Rubyvis.transpose(c) if c.is_a? Array
        if r.is_a? Array
          s._grid=Rubyvis.blend(r)
          s.rows=r.size
          s.cols=r[0] ? r[0].size : 0
        else
          s._grid=Rubyvis.repeat([s.data],r*c)
        end
      end
    end
  end
end
