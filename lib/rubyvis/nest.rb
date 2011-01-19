module Rubyvis
  ##
  # Returns a Nest operator for the specified array. This is a
  # convenience factory method, equivalent to <tt>Nest.new(array)</tt>.
  #
  # @see Rubyvis::Nest
  # @param {array} array an array of elements to nest.
  # @returns {Nest} a nest operator for the specified array.
  ##
  def self.nest(array)
    Nest.new(array)
  end
  # :stopdoc:
  class NestedArray
    attr_accessor :key, :values
    def initialize(opts)
      @key=opts[:key]
      @values=opts[:values]
    end
    def ==(var)
      key==var.key and values==var.values
    end
  end
  # :startdoc: 
  
  # Represents a Nest operator for the specified array. Nesting
  # allows elements in an array to be grouped into a hierarchical tree
  # structure. The levels in the tree are specified by <i>key</i> functions. The
  # leaf nodes of the tree can be sorted by value, while the internal nodes can
  # be sorted by key. Finally, the tree can be returned either has a
  # multidimensional array via Nest.entries, or as a hierarchical map via
  # Nest.map. The Nest.rollup routine similarly returns a map, collapsing
  # the elements in each leaf node using a summary function.
  #
  # For example, consider the following tabular data structure of Barley
  # yields, from various sites in Minnesota during 1931-2:
  #
  #   { yield: 27.00, variety: "Manchuria", year: 1931, site: "University Farm" },
  #   { yield: 48.87, variety: "Manchuria", year: 1931, site: "Waseca" },
  #   { yield: 27.43, variety: "Manchuria", year: 1931, site: "Morris" }
  #
  # To facilitate visualization, it may be useful to nest the elements first by
  # year, and then by variety, as follows:
  #
  #     var nest = Rubyvis.nest(yields)
  #     .key(lambda {|d|  d.year})
  #     .key(lambda {|d| d.variety})
  #     .entries();
  #
  # This returns a nested array. Each element of the outer array is a key-values
  # pair, listing the values for each distinct key:
  #
  # <pre>{ key: 1931, values: [
  #   { key: "Manchuria", values: [
  #       { yield: 27.00, variety: "Manchuria", year: 1931, site: "University Farm" },
  #       { yield: 48.87, variety: "Manchuria", year: 1931, site: "Waseca" },
  #       { yield: 27.43, variety: "Manchuria", year: 1931, site: "Morris" },
  #       ...
  #     ] },
  #   { key: "Glabron", values: [
  #       { yield: 43.07, variety: "Glabron", year: 1931, site: "University Farm" },
  #       { yield: 55.20, variety: "Glabron", year: 1931, site: "Waseca" },
  #       ...
  #     ] },
  #   ] },
  # { key: 1932, values: ... }</pre>
  #
  # Further details, including sorting and rollup, is provided below on the
  # corresponding methods.
  class Nest
    attr_accessor :array, :keys, :order
    ##
    # Constructs a nest operator for the specified array. This constructor should
    # not be invoked directly; use Rubyvis.nest instead.
    
    def initialize(array)
      @array=array
      @keys=[]
      @order=nil
    end
    def key(k)
      @keys.push(k)
      return self
    end
    def sort_keys(order=nil)
      keys[keys.size-1].order = order.nil? ? Rubyvis.natural_order : order
      return self
    end
    def sort_values(order=nil)
      @order = order.nil? ? Rubyvis.natural_order : order
      return self
    end
    
    # Returns a hierarchical map of values. Each key adds one level to the
    # hierarchy. With only a single key, the returned map will have a key for each
    # distinct value of the key function; the correspond value with be an array of
    # elements with that key value. If a second key is added, this will be a nested
    # map. For example:
    #
    # <pre>Rubyvis.nest(yields)
    #     .key(function(d) d.variety)
    #     .key(function(d) d.site)
    #     .map()</pre>
    #
    # returns a map <tt>m</tt> such that <tt>m[variety][site]</tt> is an array, a subset of
    # <tt>yields</tt>, with each element having the given variety and site.
    #
    # @returns a hierarchical map of values    
    def map
      #i=0
      map={} 
      values=[]
      @array.each_with_index {|x,j|
        m=map
        (@keys.size-1).times {|i|
          k=@keys[i].call(x)
          m[k]={} if (!m[k])
          m=m[k]
        }
        k=@keys.last.call(x)
        if(!m[k])
          a=[]
          values.push(a)
          m[k]=a
        end
        m[k].push(x)
      }
      if(self.order)
        values.each_with_index {|v,vi|
          values[vi].sort!(&self.order)
        }
      end
      map
    end
    
    # Returns a hierarchical nested array. This method is similar to
    # {@link pv.entries}, but works recursively on the entire hierarchy. Rather
    # than returning a map like {@link #map}, this method returns a nested
    # array. Each element of the array has a <tt>key</tt> and <tt>values</tt>
    # field. For leaf nodes, the <tt>values</tt> array will be a subset of the
    # underlying elements array; for non-leaf nodes, the <tt>values</tt> array will
    # contain more key-values pairs.
    #
    # <p>For an example usage, see the {@link Nest} constructor.
    #
    # @returns a hierarchical nested array.
    
    def entries()
      entries_sort(entries_entries(map),0)
    end
    def entries_entries(map)
      array=[]
      map.each_pair {|k,v|
        array.push(NestedArray.new({:key=>k, :values=>(v.is_a? Array) ? v: entries_entries(v)}))
      }
      array
    end
    def entries_sort(array,i)
      o=keys[i].order
      if o
        array.sort! {|a,b| o.call(a.key, b.key)}
      end
      i+=1
      if (i<keys.size)
        array.each {|v|
          entries_sort(v, i)
        }
      end
      array
      
    end
    def rollup_rollup(map,f)
      map.each_pair {|key,value|
        if value.is_a? Array
          map[key]=f.call(value)
        else
          rollup_rollup(value,f)
        end
      }
      return map;
    end
    
    # Returns a rollup map. The behavior of this method is the same as
    # {@link #map}, except that the leaf values are replaced with the return value
    # of the specified rollup function <tt>f</tt>. For example,
    #
    # <pre>pv.nest(yields)
    #      .key(function(d) d.site)
    #      .rollup(function(v) pv.median(v, function(d) d.yield))</pre>
    #
    # first groups yield data by site, and then returns a map from site to median
    # yield for the given site.
    #
    # @see #map
    # @param {function} f a rollup function.
    # @returns a hierarchical map, with the leaf values computed by <tt>f</tt>.

    
    def rollup(f)
      rollup_rollup(self.map, f)
    end
  end
end
