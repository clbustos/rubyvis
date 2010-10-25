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
  class NestedArray
    attr_accessor :key, :values
    def initialize(opts)
      @key=opts[:key]
      @values=opts[:values]
    end
    def ==(var)
      key==var.key and values=var.values
    end
  end
  ##
  # Constructs a nest operator for the specified array. This constructor should
  # not be invoked directly; use {@link Rubyvis.nest} instead.
  #
  # @class Represents a {@link Nest} operator for the specified array. Nesting
  # allows elements in an array to be grouped into a hierarchical tree
  # structure. The levels in the tree are specified by <i>key</i> functions. The
  # leaf nodes of the tree can be sorted by value, while the internal nodes can
  # be sorted by key. Finally, the tree can be returned either has a
  # multidimensional array via {@link #entries}, or as a hierarchical map via
  # {@link #map}. The {@link #rollup} routine similarly returns a map, collapsing
  # the elements in each leaf node using a summary function.
  #
  # <p>For example, consider the following tabular data structure of Barley
  # yields, from various sites in Minnesota during 1931-2:
  #
  #   { yield: 27.00, variety: "Manchuria", year: 1931, site: "University Farm" },
  #   { yield: 48.87, variety: "Manchuria", year: 1931, site: "Waseca" },
  #   { yield: 27.43, variety: "Manchuria", year: 1931, site: "Morris" }
  #
  # To facilitate visualization, it may be useful to nest the elements first by
  # year, and then by variety, as follows:
  #
  # <pre>var nest = Rubyvis.nest(yields)
  #     .key(function(d) d.year)
  #     .key(function(d) d.variety)
  #     .entries();</pre>
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
  #
  # @param {array} array an array of elements to nest.
  #/
  class Nest
    attr_accessor :array, :keys, :order
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
          rollup_rollup(value)
        end
      }
      return map;
    end
    def rollup(f)
      rollup_rollup(self.map,f)
    end
  end
end
