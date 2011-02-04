$:.unshift(File.dirname(__FILE__)+"/../lib")
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_group "Libraries", "lib"
  end
rescue LoadError
end
require 'rspec'
#require 'spec/autorun'
require 'rubyvis'
require 'pp'
require 'nokogiri'


$PROTOVIS_DIR=File.dirname(__FILE__)+"/../vendor/protovis/src"
module Rubyvis
  module GeneralSpec
    def fixture_svg_read(filename)
      File.read(File.dirname(__FILE__)+"/fixtures/#{filename}")
    end
  end
  module LayoutSpec
    include GeneralSpec
    def waves(n, m) 
    Rubyvis.range(n).map {|i| 
      Rubyvis.range(m).map {|j| 
        x = 20 * j / m.to_f - i / 3.0
        x > 0 ? 2 * x * Math.exp(-0.5 * x) : 0
      }
    }
    end

    
    
    
    def net_nodes
      [
      OpenStruct.new({:node_value=>'A', :group=>1}),
      OpenStruct.new({:node_value=>'B', :group=>1}),
      OpenStruct.new({:node_value=>'C', :group=>2}),
      OpenStruct.new({:node_value=>'D',:group=>2}),
      OpenStruct.new({:node_value=>'E',:group=>3}),
      OpenStruct.new({:node_value=>'F',:group=>3})
      
      ]
    end
    def net_links
      [
      OpenStruct.new({:source=>0,:target=>1, :value=>1}),
      OpenStruct.new({:source=>1,:target=>2, :value=>1}),
      OpenStruct.new({:source=>2,:target=>3, :value=>1}),
      OpenStruct.new({:source=>3,:target=>4, :value=>1}),
      OpenStruct.new({:source=>4,:target=>5, :value=>1}),
      OpenStruct.new({:source=>1,:target=>0, :value=>1}),
      OpenStruct.new({:source=>2,:target=>1, :value=>1}),
      OpenStruct.new({:source=>3,:target=>2, :value=>1}),
      OpenStruct.new({:source=>4,:target=>3, :value=>1}),
      OpenStruct.new({:source=>5,:target=>4, :value=>1}),
      ]
    end
    def hier_nodes
      Rubyvis.dom({:a=>1,:b=>{:ba=>2,:bb=>{:bba=>3}, :bc=>4}, :c=>5}).root("test").nodes
    end
    def hier_nodes_big
      subtree={:a=>1,:b=>2,:c=>3,:d=>4}

      Rubyvis.dom({:a=>subtree,:b=>subtree, :c=>subtree, :d=>subtree,:e=>subtree,:f=>subtree}).root("test").nodes()

    end
  end
  class JohnsonLoader
    begin
      require 'johnson'
      def self.available?
        true
      end
    rescue LoadError
      def self.available?
        false
      end
    end
    attr_accessor :runtime
    def initialize(*files)
      files=["/pv.js","/pv-internals.js", "/data/Arrays.js","/data/Numbers.js", "/data/Scale.js", "/data/QuantitativeScale.js", "/data/LinearScale.js","/color/Color.js","/color/Colors.js","/text/Format.js", "/text/DateFormat.js","/text/NumberFormat.js","/text/TimeFormat.js"]+files
      files.uniq!
      files=files.map {|v| $PROTOVIS_DIR+v}
      @runtime = Johnson.load(*files)
    end
  end
end
# Spec matcher 
RSpec::Matchers.define :have_svg_attributes do |exp|
  match do |obs|
    exp.each {|k,v|
      obs.attributes[k].should be_true
      obs.attributes[k].value.should==v
    }
  end
  failure_message_for_should do |obs|
    "\n#{exp} attributes expected, but xml doesn't contains them \n#{obs.to_s}"
  end
end

# Include
# * rect
# * circle
# * text
# Using attributes and content
Rspec::Matchers.define :have_same_svg_elements do |exp|
  def equal_float(a,b)
    a||=0
    b||=0
    (a.to_f-b.to_f).abs<0.0001
  end
  def equal_string_nil(a,b)
    a||="none"
    b||="none"
    a.to_s==b.to_s
  end
  def equal_string(a,b)
    a.to_s==b.to_s
  end
  def path_scan(path)
    path.scan(/([MmCcZzLlHhVvSsQqTtAa, ])(\d+(?:\.\d+)?)/).map {|v|
      v[0]="," if v[0]==" "
      v[1]=v[1].to_f
      v
    }
  end
  
  def equal_path(a,b)
    path_a=path_scan(a)
    path_b=path_scan(b)
    correct=true
    path_a.each_with_index do |v,i|
      if (v[0]!=path_b[i][0]) or (v[1]-path_b[i][1]).abs>0.001
        correct=false
        break
      end
      
    end
    correct
  end
  match do |obs|
    obs_xml=Nokogiri::XML(obs)
    exp_xml=Nokogiri::XML(exp)
    correct=true
    attrs={
      "circle"=>{'fill'=>:string_nil, 'fill-opacity'=>:float, 'cx'=>:float,'stroke'=>:string_nil, 'stroke-opacity'=>:string, 'cy'=>:float,'r'=>:float},
      "rect"=>{"x"=>:float,"y"=>:float,"width"=>:float,"height"=>:float, 'fill'=>:string_nil, 'fill-opacity'=>:float, 'stroke'=>:string_nil, 'stroke-opacity'=>:float},
      "text"=>{"x"=>:float,"dx"=>:float,"y"=>:float,"dy"=>:float},
      'path'=>{'d'=>:path, 'fill'=>:string_nil, 'fill-opacity'=>:float, 'stroke'=>:string_nil, 'stroke-opacity'=>:float, 'stroke-width'=>:float}
    }
    
    @error={:type=>"Undefined error"}
    attrs.each_pair do |key,attrs|
      exp_elements=exp_xml.xpath("//#{key}")
      obs_elements=obs_xml.xpath("//xmlns:#{key}")
      if exp_elements.size!=obs_elements.size
        @error={:type=>"Different number of #{key} elements",:exp=>exp_elements.size, :obs=>obs_elements.size}
        correct=false
        break
      end
      
      exp_elements.each_with_index {|exp_data,i|
        obs_data=obs_elements[i]  
        if obs_data.nil?
          @error={:type=>"Missing obs", :exp=>exp_data, :i=>i}
          correct=false
          break
        end
        if exp_data.content!=obs_data.content
          @error={:type=>"Content", :exp=>exp_data, :i=>i, :obs=>obs_data, :exp_attr=>exp_data.content, :obs_attr=>obs_data.content}
          correct=false
          break;
        end
        
        attrs.each do |attr,method|
          eq=send("equal_#{method}",obs_data[attr],exp_data[attr])
          if !eq
            puts "Uneql attr: #{method}->#{attr}"
            @error={:type=>"Incorrect data", :exp=>exp_data, :obs=>obs_data, :attr=>attr, :exp_attr=>exp_data[attr], :obs_attr=>obs_data[attr],:i=>i}
            correct=false
            break
          end
        end
        if !correct
          break
        end
      }
    end
    correct
  end
  failure_message_for_should do |obs|
    "#{@error[:type]}: #{@error[:exp].to_s} expected, but #{@error[:obs]} retrieved, on #{@error[:attr]} -> #{@error[:i]} : '#{@error[:exp_attr]}' <> '#{@error[:obs_attr]}'"
  end
  
end
Rspec::Matchers.define :have_same_position do |exp|
  match do |obs|
    correct=true
    attrs={
      "circle"=>['cx','cy','r'],
      "rect"=>["x","y","width","height"],
      "text"=>["x","dx","y","dy","transform"]
    }
    attrs[exp.name].each do |attr|
      if (obs[attr].to_f -  exp[attr].to_f).abs>0.0001
        correct=false
        break
      end
    end
    correct
  end
end


RSpec::Matchers.define :have_path_data_close_to do |exp|
  def path_scan(path)
      path.scan(/([MmCcZzLlHhVvSsQqTtAa, ])(\d+(?:\.\d+)?)/).map {|v|
      v[0]="," if v[0]==" "
      v[1]=v[1].to_f
      v
      }
  end
  match do |obs|
    correct=true
    obs_array=path_scan(obs.attributes["d"].value)
    
    exp_array=path_scan(exp)
    obs_array.each_with_index {|v,i|
      if (v[0]!=exp_array[i][0]) or (v[1]-exp_array[i][1]).abs>0.001
        correct=false
        break
      end
    }
    correct
  end
  failure_message_for_should do |obs|
    obs_array=path_scan(obs.attributes["d"].value)
    exp_array=path_scan(exp)
    "\n#{obs_array} path should be equal to \n#{exp_array}"
  end
end