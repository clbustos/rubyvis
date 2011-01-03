module Rubyvis
  # Returns a {@link pv.Flatten} operator for the specified map. This is a
  # convenience factory method, equivalent to <tt>new pv.Flatten(map)</tt>.  
  def self.flatten(map)
    Flatten.new(map)
  end
  # Represents a flatten operator for the specified array. Flattening
  # allows hierarchical maps to be flattened into an array. The levels in the
  # input tree are specified by <i>key</i> functions.
  #
  # <p>For example, consider the following hierarchical data structure of Barley
  # yields, from various sites in Minnesota during 1931-2:
  #
  # <pre>{ 1931: {
  #     Manchuria: {
  #       "University Farm": 27.00,
  #       "Waseca": 48.87,
  #       "Morris": 27.43,
  #       ... },
  #     Glabron: {
  #       "University Farm": 43.07,
  #       "Waseca": 55.20,
  #       ... } },
  #   1932: {
  #     ... } }</pre>
  #
  # To facilitate visualization, it may be useful to flatten the tree into a
  # tabular array:
  #
  # <pre>var array = pv.flatten(yields)
  #     .key("year")
  #     .key("variety")
  #     .key("site")
  #     .key("yield")
  #     .array();</pre>
  #
  # This returns an array of object elements. Each element in the array has
  # attributes corresponding to this flatten operator's keys:
  #
  # <pre>{ site: "University Farm", variety: "Manchuria", year: 1931, yield: 27 },
  # { site: "Waseca", variety: "Manchuria", year: 1931, yield: 48.87 },
  # { site: "Morris", variety: "Manchuria", year: 1931, yield: 27.43 },
  # { site: "University Farm", variety: "Glabron", year: 1931, yield: 43.07 },
  # { site: "Waseca", variety: "Glabron", year: 1931, yield: 55.2 }, ...</pre>
  #
  # <p>The flatten operator is roughly the inverse of the {@link pv.Nest} and
  # {@link pv.Tree} operators.
  #
  class Flatten
    def initialize(map)
      @map=map
      @keys=[]
      @leaf=nil
    end
    # Flattens using the specified key function. Multiple keys may be added to the
    # flatten; the tiers of the underlying tree must correspond to the specified
    # keys, in order. The order of the returned array is undefined; however, you
    # can easily sort it.
    #
    # @param {string} key the key name.
    # @param {function} [f] an optional value map function.
    # @returns {pv.Nest} this.
    
    def key(k, f=nil)
      @keys.push(OpenStruct.new({:name=>k, :value=>f}))
      @leaf=nil
      self
    end

    # Flattens using the specified leaf function. This is an alternative to
    # specifying an explicit set of keys; the tiers of the underlying tree 
    # will be determined dynamically by recursing on the values, and the resulting keys will be stored in the entries +:keys+ attribute. The leaf function must return true for leaves, and false for internal nodes.
    #
    # @param {function} f a leaf function.
    # @returns {pv.Nest} this.
    def leaf(f)
      @keys.clear
      @leaf=f
      self
    end
    def recurse(value,i)
      if @leaf.call(value)
        @entries.push({:keys=>@stack.dup, :value=>value})
      else
        value.each {|key,v|
          @stack.push(key)
          recurse(v, i+1)
          @stack.pop
        }
      end
    end
    def visit(value,i)
      if (i < @keys.size - 1)
        value.each {|key,v|
          @stack.push(key)
          visit(v,i+1)
          @stack.pop
        }
      else 
        @entries.push(@stack+[value])
      end
    end
    # Returns the flattened array. Each entry in the array is an object; each
    # object has attributes corresponding to this flatten operator's keys.
    #
    # @returns an array of elements from the flattened map.
    def array
      @entries=[]
      @stack=[]
      if @leaf
        recurse(@map,0)
        return @entries
      end
      visit(@map,0)
      @entries.map {|stack|
        m={}
        @keys.each_with_index {|k,i|
          v=stack[i]
          m[k.name]=k.value ? k.value.js_call(self,v) : v
        }
        m
      }
    end
    alias :to_a :array
  end
end
