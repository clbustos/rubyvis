module Rubyvis
  class Layout
    # Alias for Rubyvis::Layout::Tree 
    def self.Tree
      Rubyvis::Layout::Tree
    end
    # Implements a node-link tree diagram using the Reingold-Tilford "tidy"
    # tree layout algorithm. The specific algorithm used by this layout is based on
    # <a href="http://citeseer.ist.psu.edu/buchheim02improving.html">"Improving
    # Walker's Algorithm to Run in Linear Time"</A> by C. Buchheim, M. J&uuml;nger
    # &amp; S. Leipert, Graph Drawing 2002. This layout supports both cartesian and
    # radial orientations orientations for node-link diagrams.
    #
    # <p>The tree layout supports a "group" property, which if true causes siblings
    # to be positioned closer together than unrelated nodes at the same depth. The
    # layout can be configured using the <tt>depth</tt> and <tt>breadth</tt>
    # properties, which control the increments in pixel space between nodes in both
    # dimensions, similar to the indent layout.
    #
    # <p>For more details on how to use this layout, see
    # Rubyvis::Layout::Hierarchy
    class Tree < Hierarchy
      @properties=Hierarchy.properties.dup
      def initialize
        super
      end
      
      ##
      # :attr: breadth
      # The offset between siblings nodes; defaults to 15.
            
      ##
      # :attr: depth
      # The offset between parent and child nodes; defaults to 60.
      #
      
      ##
      # :attr: orient
      # The orientation. The default orientation is "top", which means that the root
      # node is placed on the top edge, leaf nodes appear at the bottom, and internal
      # nodes are in-between. The following orientations are supported:<ul>
      #
      # <li>left - left-to-right.
      # <li>right - right-to-left.
      # <li>top - top-to-bottom.
      # <li>bottom - bottom-to-top.
      # <li>radial - radially, with the root at the center.</ul>
      #
      
      ##
      # :group:
      # The sibling grouping, i.e., whether differentiating space is placed between
      # sibling groups. The default is 1 (or true), causing sibling leaves to be
      # separated by one breadth offset. Setting this to false (or 0) causes
      # non-siblings to be adjacent.
      
      attr_accessor_dsl :group, :breadth, :depth, :orient
      
      # Default properties for tree layouts. The default orientation is "top",
      # the default group parameter is 1, and the default breadth and depth
      # offsets are 15 and 60 respectively.
      def self.defaults
        Rubyvis::Layout::Tree.new.mark_extend(Rubyvis::Layout::Hierarchy.defaults).
        group(1).
        breadth(15).
        depth(60).
        orient("top")
      end
      
      def first_walk(v)
        l,r,a=nil,nil,nil
        if (!v.first_child)
          l= v.previous_sibling
          v.prelim = l.prelim + distance(v.depth, true)  if l
        else    
          l = v.first_child
          r = v.last_child
          a = l # default ancestor
          v.each_child {|c| 
            first_walk(c)
            a = apportion(c, a)
          }
          execute_shifts(v)
          midpoint = 0.5 * (l.prelim + r.prelim)
          l = v.previous_sibling
          if l
            v.prelim = l.prelim + distance(v.depth, true)
            v.mod = v.prelim - midpoint
          else
            v.prelim = midpoint
          end
        end
      end
      def second_walk(v,m,depth)
        v.breadth = v.prelim + m
        m += v.mod
        v.each_child {|c|
          second_walk(c, m, depth)
        }
      end
      def apportion(v,a)
        w = v.previous_sibling
        if w
          vip = v
          vop = v
          vim = w
          vom = v.parent_node.first_child
          sip = vip.mod
          sop = vop.mod
          sim = vim.mod
          som = vom.mod
          nr = next_right(vim)
          nl = next_left(vip)
          while (nr and nl) do
            vim = nr
            vip = nl
            vom = next_left(vom)
            vop = next_right(vop)
            vop.ancestor = v
            shift = (vim.prelim + sim) - (vip.prelim + sip) + distance(vim.depth, false)
            if (shift > 0)
              move_subtree(ancestor(vim, v, a), v, shift)
              sip += shift
              sop += shift
            end
            sim += vim.mod
            sip += vip.mod
            som += vom.mod
            sop += vop.mod
            nr = next_right(vim)
            nl = next_left(vip)
          end
          
          if (nr and !next_right(vop))
            vop.thread = nr
            vop.mod += sim - sop
          end
          if (nl and !next_left(vom))
            vom.thread = nl
            vom.mod += sip - som
            a = v
          end
        end
        a
      end
      
      def next_left(v)
        v.first_child ? v.first_child : v.thread
      end
      def next_right(v)
        v.last_child ? v.last_child : v.thread
      end
      
      def move_subtree(wm, wp, shift) 
        subtrees = wp.number - wm.number
        wp.change -= shift / subtrees.to_f
        wp.shift += shift
        wm.change += shift / subtrees.to_f
        wp.prelim += shift
        wp.mod += shift
      end
      
      def execute_shifts(v) 
        shift = 0
        change = 0
        c=v.last_child
        while c        
          c.prelim += shift
          c.mod += shift
          change += c.change
          shift += c.shift + change
          c = c.previous_sibling          
        end
      end
      def ancestor(vim, v, a) 
        (vim.ancestor.parent_node == v.parent_node) ? vim.ancestor : a
      end

      def distance(depth, siblings) 
        (siblings ? 1 : (@_group + 1)).to_f / ((@_orient == "radial") ? depth : 1)
      end

      
      def mid_angle(n)
        (@_orient == "radial") ? n.breadth.to_f / depth : 0;
      end
      
      #/** @private */
      def x(n)
        case @_orient
          when "left"
            n.depth;
          when "right"
            @_w - n.depth;
          when "top"
            n.breadth + @_w / 2.0
          when "bottom"
            n.breadth + @_w / 2.0
          when "radial"
            @_w / 2.0 + n.depth * Math.cos(mid_angle(n))
        end
      end
      
      #/** @private */
      def y(n)
        case @_orient
          when "left"
            n.breadth + @_h / 2.0
          when "right"
            n.breadth + @_h / 2.0
          when "top"
            n.depth;
          when "bottom"
            @_h - n.depth
          when "radial"
            @_h / 2.0 + n.depth * Math.sin(mid_angle(n))
        end
      end

      
      
      def build_implied(s)
        return nil if hierarchy_build_implied(s)        
        @_nodes = s.nodes
        @_orient = s.orient
        @_depth = s.depth
        @_breadth = s.breadth
        @_group = s.group
        @_w = s.width
        @_h = s.height
        root=@_nodes[0]
        root.visit_after {|v,i|
          v.ancestor = v
          v.prelim = 0
          v.mod = 0
          v.change = 0
          v.shift = 0
          v.number = v.previous_sibling ? (v.previous_sibling.number + 1) : 0
          v.depth = i
        }
        #/* Compute the layout using Buchheim et al.'s algorithm. */
        first_walk(root)
        second_walk(root, -root.prelim, 0)
        
        root.visit_after {|v,i|
          v.breadth *= breadth
          v.depth *= depth
          v.mid_angle = mid_angle(v)
          v.x = x(v)
          v.y = y(v)
          v.mid_angle += Math::PI if (v.first_child)
          v.breadth=nil
          v.depth=nil
          v.ancestor=nil
          v.prelim=nil
          v.mod=nil
          v.change=nil
          v.shift=nil
          v.number=nil
          v.thread=nil
        }
        
        
      end
    end
  end
end
