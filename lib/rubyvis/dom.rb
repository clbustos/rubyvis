module Rubyvis
  # Returns a Rubyvis::Dom operator for the given map. This is a convenience
  # factory method, equivalent to Rubyvis::Dom.new(map). To apply the operator
  # and retrieve the root node, call Rubyvis::Dom.root() to retrieve all nodes
  # flattened, use Rubyvis::Dom.nodes
  #
  # @see pv.Dom
  # @param map a map from which to construct a DOM.
  # @returns {pv.Dom} a DOM operator for the specified map.
  def self.dom(map) 
    Rubyvis::Dom.new(map)
  end

  # Constructs a DOM operator for the specified map. This constructor should not
  # be invoked directly; use {@link pv.dom} instead.
  #
  # @class Represets a DOM operator for the specified map. This allows easy
  # transformation of a hierarchical JavaScript object (such as a JSON map) to a
  # W3C Document Object Model hierarchy. For more information on which attributes
  # and methods from the specification are supported, see {@link pv.Dom.Node}.
  #
  # <p>Leaves in the map are determined using an associated <i>leaf</i> function;
  # see {@link #leaf}. By default, leaves are any value whose type is not
  # "object", such as numbers or strings.
  #
  # @param map a map from which to construct a DOM.
  class Dom
    def initialize(map)
      @_map=map
      @leaf=lambda {|n| !n.respond_to? :each }
    end
    # Sets or gets the leaf function for this DOM operator. The leaf function
    # identifies which values in the map are leaves, and which are internal nodes.
    # By default, objects are considered internal nodes, and primitives (such as
    # numbers and strings) are considered leaves.
    #
    # @param {function} f the new leaf function.
    # @returns the current leaf function, or <tt>this</tt>.    
    def leaf(f=nil)
      if !f.nil?
        @leaf=f
        self
      end
      @leaf
    end
    
    def root_recurse(map)
      n = Rubyvis::Dom::Node.new
      map.each {|k,v|
        n.append_child(@leaf.call(v) ? Rubyvis::Dom::Node.new(v) : root_recurse(v)).node_name = k
      }
      return n
    end
    
    # Applies the DOM operator, returning the root node.
    def root(node_name=nil)
      root=root_recurse(@_map)
      root.node_name=node_name
      root
    end
    
   # Applies the DOM operator, returning the array of all nodes in preorder
   # traversal.
   # @returns {array} the array of nodes in preorder traversal.
   def nodes
     self.root.nodes
   end
   
   def self.Node(value)
     Node.new(value)
   end
   # Represents a <tt>Node</tt> in the W3C Document Object Model.
    class Node
      # The node name. When generated from a map, the node name corresponds to the
      # key at the given level in the map. Note that the root node has no associated
      # key, and thus has an undefined node name (and no <tt>parentNode</tt>).
      attr_accessor :node_name
      
      # The node value. When generated from a map, node value corresponds to 
      # the leaf value for leaf nodes, and is undefined for internal nodes.
      attr_accessor :node_value
      
      # The array of child nodes. This array is empty for leaf nodes. An easy way to
      # check if child nodes exist is to query <tt>firstChild</tt>.    
      attr_accessor :child_nodes
      attr_accessor :parent_node
      # The first child, which is null for leaf nodes.
      
      attr_accessor :first_child
      attr_accessor :last_child
      attr_accessor :previous_sibling
      attr_accessor :next_sibling
      
      attr_accessor :index
      attr_accessor :link_degree
      attr_accessor :depth
      attr_accessor :dx
      attr_accessor :dy
      attr_accessor :x
      attr_accessor :y
      attr_accessor :size
      
      attr_accessor :min_breadth
      attr_accessor :max_breadth
      attr_accessor :breadth
      attr_accessor :min_depth
      attr_accessor :max_depth
      
      attr_accessor :mid_angle
      attr_accessor :angle
      attr_accessor :start_angle
      attr_accessor :outer_radius
      attr_accessor :inner_radius
      attr_accessor :radius      
      attr_accessor :_p
      attr_accessor :n

      ##
      # Created for Tree
      
      attr_accessor :ancestor, :prelim, :mod, :change, :shift, :number, :thread
      
      
      # Constructs a DOM node for the specified value. Instances of this class are
      # not typically created directly; instead they are generated from a JavaScript 
      # map using the {@link pv.Dom} operator.
      def initialize(value=nil)
        @node_value = value
        @child_nodes=[]
        @parent_node=nil
        @first_child=nil
        @last_child=nil
        @previous_sibling=nil
        @next_sibling=nil
        
      end
      # Removes the specified child node from this node.
      def remove_child(n)
        i=@child_nodes.index n
        raise "child not found" if i.nil?
        @child_nodes.delete_at i
        if n.previous_sibling
         n.previous_sibling.next_sibling=n.next_sibling 
        else
          @first_child=n.next_sibling
        end
        if n.next_sibling
         n.next_sibling.previous_sibling=n.previous_sibling 
        else
         @last_child=n.previous_sibling
        end
        n.next_sibling=nil
        n.previous_sibling=nil
        n.parent_node=nil
        n
      end
      
      # Appends the specified child node to this node. If the specified child is
      # already part of the DOM, the child is first removed before being added to
      # this node.
      def append_child(n)
        if n.parent_node
         n.parent_node.remove_child(n)
        end
        n.parent_node=self
        n.previous_sibling=last_child
        if self.last_child
          @last_child.next_sibling = n
        else
          @first_child=n
        end
        @last_child=n
        child_nodes.push(n)
        n
      end
      
      # Inserts the specified child <i>n</i> before the given reference child
      # <i>r</i> of this node. If <i>r</i> is null, this method is equivalent to
      # {@link #appendChild}. If <i>n</i> is already part of the DOM, it is first
      # removed before being inserted.
      #
      # @throws Error if <i>r</i> is non-null and not a child of this node.
      # @returns {pv.Dom.Node} the inserted child.
      def insert_before(n, r)
        return append_child(n) if !r
        i=@child_nodes.index r
        raise "child not found" if i.nil?
        n.parent_node.remove_child(n) if n.parent_node
        n.parent_node=self
        n.next_sibling=r
        n.previous_sibling = r.previous_sibling
        if r.previous_sibling
          r.previous_sibling.next_sibling=n
          r.previous_sibling=n
        else
          @last_child=n if r==@last_child
          @first_child=n
        end
        @child_nodes = @child_nodes[0,i] + [n] + @child_nodes[i, child_nodes.size-i]
        n
      end
      # Replaces the specified child <i>r</i> of this node with the node <i>n</i>. If
      # <i>n</i> is already part of the DOM, it is first removed before being added.
      
      def replace_child(n,r)
        i=child_nodes.index r
        raise "child not found" if i.nil?
        n.parent_node.remove_child(n) if n.parent_node
        n.parent_node=self
        n.next_sibling=r.next_sibling
        n.previous_sibling=r.previous_sibling
        if r.previous_sibling
          r.previous_sibling.next_sibling=n
        else
          @first_child=n
        end
        if r.next_sibling
          r.next_sibling.previous_sibling=n
        else
          @last_child=n
        end
        
        @child_nodes[i]=n
        r
      end
      
      def visit_visit(n,i,block,moment)
        block.call(n,i) if moment==:before
        c=n.first_child
        while c
          visit_visit(c,i+1, block,moment)
          c=c.next_sibling
        end
        block.call(n,i) if moment==:after
      end
      private :visit_visit
      # Yield block on each child
      # Replaces the javascript formula
      #   for (var c = o.first_child; c; c = c.nextSibling)
      def each_child
        c=@first_child
        while c
          yield c
          c=c.next_sibling
        end
      end
      # Visits each node in the tree in preorder traversal, applying the specified
      # proc <i>block</i>. The arguments to the function are:<ol>
      #
      # <li>The current node.
      # <li>The current depth, starting at 0 for the root node.</ol>
      
      def visit_before(f=nil,&block)
        block=f unless f.nil?
        raise "Should pass a Proc" if block.nil?
        visit_visit(self,0,block, :before)
      end
      # Visits each node in the tree in postorder traversal, applying the specified
      # function <i>f</i>. The arguments to the function are:<ol>
      #
      # <li>The current node.
      # <li>The current depth, starting at 0 for the root node.</ol>    
      def visit_after(f=nil,&block)
        block=f unless f.nil?
        raise "Should pass a Proc" if block.nil?
        visit_visit(self,0,block, :after)
      end
      
      
      # Sorts child nodes of this node, and all descendent nodes recursively, using
      # the specified comparator function <tt>f</tt>. The comparator function is
      # passed two nodes to compare.
      #
      # <p>Note: during the sort operation, the comparator function should not rely
      # on the tree being well-formed; the values of <tt>previousSibling</tt> and
      # <tt>nextSibling</tt> for the nodes being compared are not defined during the
      # sort operation.
      #
      # @param {function} f a comparator function.
      # @returns this.
      def sort(f_a=nil,&f)
        f=f_a unless f_a.nil?
        raise "Should pass a Proc" if f.nil?
        if @first_child
          @child_nodes.sort!(&f)
          _p=@first_child = child_nodes[0]
          _p.previous_sibling=nil
          (1...@child_nodes.size).each {|i|
            _p.sort(&f)
            c=@child_nodes[i]
            c.previous_sibling=_p
            _p=_p.next_sibling=c
          }
          @last_child=_p
          _p.next_sibling=nil
          _p.sort(f)
        end
        self
      end
      # Reverses all sibling nodes.
      def reverse
        child_nodes=[]
        visit_after {|n,dummy|
        while(n.last_child) do
          child_nodes.push(n.remove_child(n.last_child)) 
        end
        c=nil
        while(c=child_nodes.pop)
          n.insert_before(c,n.first_child)
        end
        }
        self
      end
      def nodes_flatten(node,array)
        array.push(node)
        node.child_nodes.each {|n|
        nodes_flatten(n,array)
        }
      end
      private :nodes_flatten
      def nodes
        array=[]
        nodes_flatten(self,array)
        array
      end
    # toggle missing
      def inspect
        childs=@child_nodes.map{|e| e.inspect}.join(",")
        "#<#{self.class} #{object_id.to_s(16)} (#{}), name: #{@node_name}, value: #{@node_value} child_nodes: [#{childs}]>"
      end
    end # End Node
  end # End Dom
  # Given a flat array of values, returns a simple DOM with each value wrapped by
  # a node that is a child of the root node.  
  def self.nodes(values)
    root=Rubyvis::Dom::Node.new
    values.each do |v,i|
      root.append_child(Rubyvis::Dom::Node.new(v))
    end
    root.nodes()
  end
end
