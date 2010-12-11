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
    root.nodes.should be_instance_of Array
    root.nodes.size.should eq 8
    ar=root.nodes.map do |n|
      [n.node_name, n.node_value]
    end
    ar.should eq [[nil, nil], [:a, nil], [:aa, 1], [:ab, nil], [:aba, 2], [:b, 4], [:c, nil], [:ca, 5]]
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
    ar.should eq [["flare", 8.0], [:b, 2.0], [:ba, 1.0], [:bb, 1.0], [:a, 3.0], [:aa, 1.0], [:ab, 1.0], [:ac, 1.0], [:c, 3.0]]
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
      @n.node_value.should eq :a
    end
    it  {should respond_to :parent_node}
    it  {should respond_to :first_child}
    it  {should respond_to :last_child}
    it  {should respond_to :previous_sibling}
    it  {should respond_to :next_sibling}
    it  {should respond_to :node_name}
    it  {should respond_to :child_nodes}
    it "should child_nodes be empty" do
      @n.child_nodes.size==0
    end
    it "method append_child" do
      @n.append_child(@n2).should eq @n2
      @n.child_nodes.should eq [@n2]
      @n2.parent_node.should eq @n
      @n.first_child.should eq @n2
      @n.last_child.should eq @n2
      
      @n.append_child(@n3)
      @n.child_nodes.should eq [@n2,@n3]
      @n3.parent_node.should eq @n
      @n.first_child.should eq @n2
      @n.last_child.should eq @n3
      @n2.previous_sibling.should be_nil
      @n2.next_sibling.should eq @n3
      @n3.previous_sibling.should eq @n2
      @n3.next_sibling.should be_nil
      
      @n.append_child(@n4)
      @n.last_child.should eq @n4
      @n2.next_sibling.should eq @n3
      @n3.next_sibling.should eq @n4
      @n4.next_sibling.should be_nil

      @n4.previous_sibling.should eq @n3
      @n3.previous_sibling.should eq @n2
      @n2.previous_sibling.should be_nil
      
    end
    it "method remove_child" do
      @n.append_child(@n2)
      @n.append_child(@n3)
      @n.append_child(@n4)
      
      @n.remove_child(@n3).should eq @n3
      
      @n3.next_sibling.should be_nil
      @n3.previous_sibling.should be_nil
      @n3.parent_node.should be_nil
      
      @n2.next_sibling.should eq @n4
      @n4.previous_sibling.should eq @n2
      
      @n.remove_child(@n4)
      @n2.next_sibling.should be_nil
      @n.first_child.should eq @n2
      @n.last_child.should eq @n2
    end
    
    it "method insert_before" do
      @n.append_child(@n2)
      @n.append_child(@n4)
      @n.insert_before(@n3,@n4)
      @n.child_nodes.size.should eq 3
      
      @n.first_child.should eq @n2
      @n.last_child.should eq @n4
      @n2.next_sibling.should eq @n3
      @n3.next_sibling.should eq @n4
      @n4.next_sibling.should be_nil
     
      @n2.previous_sibling.should be_nil
      @n3.previous_sibling.should eq @n2
      @n4.previous_sibling.should eq @n3
      
      
      
      @n.child_nodes[0].should eq @n2
      @n.child_nodes[1].should eq @n3
      @n.child_nodes[2].should eq @n4
      
    end
    it "method replace_child" do
      @n.append_child(@n2)
      @n.append_child(@n3)
      @n.replace_child(@n4,@n3)
      
      @n.child_nodes.size.should eq 2
      
      @n.child_nodes[0].should eq @n2
      @n.child_nodes[1].should eq @n4

      @n2.next_sibling.should eq @n4
      @n4.next_sibling.should eq nil
     
      @n2.previous_sibling.should be_nil
      @n4.previous_sibling.should eq @n2

      
      @n.first_child.should eq @n2
      @n.last_child.should eq @n4
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
        @a.should eq [[:a, 0], [:b, 1], [:e, 2], [:c, 1], [:d, 2]]
      end
      
      it "method visit_after" do
        @n.visit_after {|n,d|
          @a.push([n.node_value,d])
        }
        @a.should eq [[:e, 2], [:b, 1], [:d, 2], [:c, 1], [:a, 0]]
      end
      it "method each_child" do
        @n.append_child(@n5)        
        @n.each_child {|d|
          @a.push(d.node_value)
        }
        @a.should eq [:b, :c,:e]
      end
    end
    it "should sort correctly" do
      @n.append_child(@n5)
      @n.append_child(@n4)
      @n.append_child(@n3)
      @n.append_child(@n2)
      
      @n.sort {|a,b| a.node_value.to_s<=>b.node_value.to_s}
      
      @n.child_nodes.should eq [@n2,@n3,@n4,@n5]
      
      @n.first_child.should eq @n2
      @n.last_child.should eq @n5
      
      @n2.next_sibling.should eq @n3
      @n3.next_sibling.should eq @n4
      @n4.next_sibling.should eq @n5
      @n5.next_sibling.should be_nil

      @n2.previous_sibling.should be_nil
      @n3.previous_sibling.should eq @n2
      @n4.previous_sibling.should eq @n3
      @n5.previous_sibling.should eq @n4
    end
    it "should reverse correctly" do
      @n.append_child(@n3)
      @n.append_child(@n5)
      @n.append_child(@n2)
      @n.append_child(@n4)
      @n.reverse
      @n.child_nodes.should eq [@n4,@n2,@n5,@n3]
    end
    
  end
end