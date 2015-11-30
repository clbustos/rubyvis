require File.expand_path(File.dirname(__FILE__)+"/spec_helper.rb")
describe Rubyvis::Dom do
  it "should map correctly" do
    map={
      :a=>{:aa=>1,
           :ab=>{:aba=>2}
          },
      :b=>4,
      :c=>{:ca=>5}
    }
    dom_map=Rubyvis::Dom.new(map)       
    
    root=dom_map.root.sort {|a,b| a.node_name.to_s<=>b.node_name.to_s}
    expect(root.nodes).to be_instance_of Array
    expect(root.nodes.size).to eq 8
    ar=root.nodes.map do |n|
      [n.node_name, n.node_value]
    end
    expect(ar).to eq [[nil, nil], [:a, nil], [:aa, 1], [:ab, nil], [:aba, 2], [:b, 4], [:c, nil], [:ca, 5]]
  end
  it "should treemap example works right" do
    flare={:a=>{:aa=>1,:ab=>1,:ac=>1},:b=>{:ba=>1,:bb=>1},:c=>3}
    dom_map=Rubyvis::Dom.new(flare)
    nodes = dom_map.root("flare").nodes
    root = nodes[0]
    root.visit_after {|nn,i|
      if nn.first_child
        nn.size=Rubyvis.sum(nn.child_nodes, lambda {|v| v.size})
       else
         nn.size=nn.node_value.to_f
       end
    }
    root.sort(lambda {|a,b| 
        if a.size!=b.size
          a.size<=>b.size 
        else
          a.node_name.to_s<=>b.node_name.to_s
        end
          
    })
    ar=[]
    root.visit_before {|n,i|
      ar.push [n.node_name, n.size]
    }
    expect(ar).to eq [["flare", 8.0], [:b, 2.0], [:ba, 1.0], [:bb, 1.0], [:a, 3.0], [:aa, 1.0], [:ab, 1.0], [:ac, 1.0], [:c, 3.0]]
  end
  describe Rubyvis::Dom::Node do
    before do
      @n =Rubyvis::Dom::Node.new(:a)
      @n2=Rubyvis::Dom::Node.new(:b)
      @n3=Rubyvis::Dom::Node.new(:c)
      @n4=Rubyvis::Dom::Node.new(:d)
      @n5=Rubyvis::Dom::Node.new(:e)
      
    end
    subject {@n}
    it "should have node_value" do 
      expect(@n.node_value).to eq :a
    end
    it  {is_expected.to respond_to :parent_node}
    it  {is_expected.to respond_to :first_child}
    it  {is_expected.to respond_to :last_child}
    it  {is_expected.to respond_to :previous_sibling}
    it  {is_expected.to respond_to :next_sibling}
    it  {is_expected.to respond_to :node_name}
    it  {is_expected.to respond_to :child_nodes}
    it "should child_nodes be empty" do
      @n.child_nodes.size==0
    end
    it "method append_child" do
      expect(@n.append_child(@n2)).to eq @n2
      expect(@n.child_nodes).to eq [@n2]
      expect(@n2.parent_node).to eq @n
      expect(@n.first_child).to eq @n2
      expect(@n.last_child).to eq @n2
      
      @n.append_child(@n3)
      expect(@n.child_nodes).to eq [@n2,@n3]
      expect(@n3.parent_node).to eq @n
      expect(@n.first_child).to eq @n2
      expect(@n.last_child).to eq @n3
      expect(@n2.previous_sibling).to be_nil
      expect(@n2.next_sibling).to eq @n3
      expect(@n3.previous_sibling).to eq @n2
      expect(@n3.next_sibling).to be_nil
      
      @n.append_child(@n4)
      expect(@n.last_child).to eq @n4
      expect(@n2.next_sibling).to eq @n3
      expect(@n3.next_sibling).to eq @n4
      expect(@n4.next_sibling).to be_nil

      expect(@n4.previous_sibling).to eq @n3
      expect(@n3.previous_sibling).to eq @n2
      expect(@n2.previous_sibling).to be_nil
      
    end
    it "method remove_child" do
      @n.append_child(@n2)
      @n.append_child(@n3)
      @n.append_child(@n4)
      
      expect(@n.remove_child(@n3)).to eq @n3
      
      expect(@n3.next_sibling).to be_nil
      expect(@n3.previous_sibling).to be_nil
      expect(@n3.parent_node).to be_nil
      
      expect(@n2.next_sibling).to eq @n4
      expect(@n4.previous_sibling).to eq @n2
      
      @n.remove_child(@n4)
      expect(@n2.next_sibling).to be_nil
      expect(@n.first_child).to eq @n2
      expect(@n.last_child).to eq @n2
    end
    
    it "method insert_before" do
      @n.append_child(@n2)
      @n.append_child(@n4)
      @n.insert_before(@n3,@n4)
      expect(@n.child_nodes.size).to eq 3
      
      expect(@n.first_child).to eq @n2
      expect(@n.last_child).to eq @n4
      expect(@n2.next_sibling).to eq @n3
      expect(@n3.next_sibling).to eq @n4
      expect(@n4.next_sibling).to be_nil
     
      expect(@n2.previous_sibling).to be_nil
      expect(@n3.previous_sibling).to eq @n2
      expect(@n4.previous_sibling).to eq @n3
      
      
      
      expect(@n.child_nodes[0]).to eq @n2
      expect(@n.child_nodes[1]).to eq @n3
      expect(@n.child_nodes[2]).to eq @n4
      
    end
    it "method replace_child" do
      @n.append_child(@n2)
      @n.append_child(@n3)
      @n.replace_child(@n4,@n3)
      
      expect(@n.child_nodes.size).to eq 2
      
      expect(@n.child_nodes[0]).to eq @n2
      expect(@n.child_nodes[1]).to eq @n4

      expect(@n2.next_sibling).to eq @n4
      expect(@n4.next_sibling).to eq nil
     
      expect(@n2.previous_sibling).to be_nil
      expect(@n4.previous_sibling).to eq @n2

      
      expect(@n.first_child).to eq @n2
      expect(@n.last_child).to eq @n4
    end
    describe "visit methods" do
      before do
        @n.append_child(@n2)
        @n2.append_child(@n5)
        
        @n.append_child(@n3)
        @n3.append_child(@n4)
        @a=[]
      end
      
      it "method visit_before" do
        @n.visit_before {|n,d|
          @a.push([n.node_value,d])
        }
        expect(@a).to eq [[:a, 0], [:b, 1], [:e, 2], [:c, 1], [:d, 2]]
      end
      
      it "method visit_after" do
        @n.visit_after {|n,d|
          @a.push([n.node_value,d])
        }
        expect(@a).to eq [[:e, 2], [:b, 1], [:d, 2], [:c, 1], [:a, 0]]
      end
      it "method each_child" do
        @n.append_child(@n5)        
        @n.each_child {|d|
          @a.push(d.node_value)
        }
        expect(@a).to eq [:b, :c,:e]
      end
    end
    it "should sort correctly" do
      @n.append_child(@n5)
      @n.append_child(@n4)
      @n.append_child(@n3)
      @n.append_child(@n2)
      
      @n.sort {|a,b| a.node_value.to_s<=>b.node_value.to_s}
      
      expect(@n.child_nodes).to eq [@n2,@n3,@n4,@n5]
      
      expect(@n.first_child).to eq @n2
      expect(@n.last_child).to eq @n5
      
      expect(@n2.next_sibling).to eq @n3
      expect(@n3.next_sibling).to eq @n4
      expect(@n4.next_sibling).to eq @n5
      expect(@n5.next_sibling).to be_nil

      expect(@n2.previous_sibling).to be_nil
      expect(@n3.previous_sibling).to eq @n2
      expect(@n4.previous_sibling).to eq @n3
      expect(@n5.previous_sibling).to eq @n4
    end
    it "should reverse correctly" do
      @n.append_child(@n3)
      @n.append_child(@n5)
      @n.append_child(@n2)
      @n.append_child(@n4)
      @n.reverse
      expect(@n.child_nodes).to eq [@n4,@n2,@n5,@n3]
    end
    
  end
end