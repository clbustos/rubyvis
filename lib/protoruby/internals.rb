module Protoruby
  # :section: /pv-internals.js
  @@id=0
  def self.id
    @@id+=1
  end
  def self.functor(f)
    (f.is_a? Proc) ? f : lambda {f}
  end
  # :section: /data/Arrays.js
  
  def self.map(array, f=nil)
    if f
      array.size.times.map {|i|
        o=o_index(i)
        f.js_call(o, array[i])
      }
    else
      array.dup
    end
  end
  def self.repeat(array, n=2)
    array*n
  end
  def self.cross(a,b)
    array = [];
    a.each {|x|
      b.each {|y|
        array.push([x,y])
      }
    }
    array
  end
  def self.blend(arrays)
    # I love Ruby expresivness
    arrays.inject([]) {|ac,v| ac+v}
  end
  def self.transpose(matrix)
    out=[]
    matrix.size.times do |i|
      matrix[i].size.times do |j|
        out[j]||=Array.new
        out[j][i]=matrix[i][j]
      end
    end
    out
  end
  def self.normalize(array,f=nil)
    norm=Protoruby.map(array,f)
    sum=pv.sum(norm)
    norm.map {|x| x.quo(sum)}
  end
  def self.o_index(i)
    o=OpenStruct.new :index=>i
  end
  def self.permute(array,indexes, f=nil)
    f=Protoruby.identity if f.nil?
    indexes.map {|i| o=o_index(i); f.js_call(o, array[i])}
  end
  def self.numerate(keys, f=nil)
    f=Protoruby.identity if f.nil?
    m = {}
    keys.each_with_index {|x,i|
      o=o_index(i)
      m[f.js_call(o,x)]=i
    }
    m
  end
  def self.uniq(array, f=nil  )
    self.map(array,f).uniq
  end
  def self.natural_order(a,b)
    a<=>b
  end
  def self.reverse_order(a,b)
    -(a<=>b)
  end
  
  def self.search(array, value, f=nil)
    f = Protoruby.identity if (f.nil?) 
    low = 0
    high = array.size - 1;
    while (low <= high)
      mid = (low + high) >> 1
      midValue = f.call(array[mid]);
      if (midValue < value)
        low = mid + 1;
      elsif (midValue > value)
        high = mid - 1;
      else
        return mid;
      end
    end
    return -low - 1;
  end
  def self.search_index(array,value,f=nil)
    i=Protoruby.search(array,value,f)
    (i < 0 ) ? (-i-1) : i;
  end
  
  
  # :section: /data/Numbers.js
  
    def self.range(*arguments)
    start, stop, step=arguments
    if (arguments.size == 1)
      stop = start;
      start = 0;
    end
    step||= 1
    raise "range must be finite" if ((stop - start) / step.to_f).infinite?
    array = []
    i = 0
    stop = stop- (stop - start) * 1e-10 #// floating point precision!
    j = start + step * i
    if (step < 0)
      while (j > stop) 
        array.push(j)
        i+=1
        j = start + step * i
      end
     else 
      while (j < stop)
        array.push(j)
        i+=1
        j = start + step * i
      end
    end
    array
  end
  def self.random(*arguments)
    start,stop,step=arguments
    if (arguments.size == 1) 
      stop = start;
      start = 0;
    end
    step||= 1;
    return step ? ((rand() * (stop - start).quo(step)).floor * step + start) : (rand() * (stop - start) + start);
  end
  
  def self.sum(array,f=nil)
    if f.nil?
      array.inject(0) {|ac,v| ac+v}
    else
      i=0
      array.inject(0) {|ac,v|
        o=o_index(i);i+=1;
        ac+f.js_call(o,v);
      }
    end
  end
  def self.max(array, f=nil)
    return array.size-1 if f==Protoruby.index
    f ? Protoruby.map(array, f).max : array.max
  end
  def self.max_index(array,f=nil)
    a2=Protoruby.map(array,f)
    max=a2.max
    a2.index(max)
  end

  def self.min(array, f=nil)
    return array.size-1 if f==Protoruby.index
    f ? Protoruby.map(array, f).min : array.min
  end
  def self.min_index(array,f=nil)
    a2=Protoruby.map(array,f)
    min=a2.min
    a2.index(min)
  end
  def self.mean(array, f=nil)
    Protoruby.sum(array,f).quo(array.size)
  end
  def self.median(array,f=nil)
    return (array.length - 1).quo(2) if (f == pv.index) 
    array = Protoruby.map(array, f).sort{|a,b| Protoruby.natural_order(a,b)}
    return array[array.size.quo(2).floor] if (array.length % 2>0) 
    i = array.size.quo(2);
    
    return (array[i - 1] + array[i]).quo(2);
    
    
  end
  def self.log(x,b)
    Math::log(x).quo(Math::log(b))
  end
  def self.logFloor(x,b)
    (x>0)  ? b**(pv.log(x,b).floor) : b**(-(-pv.log(-x,b)).floor)
  end
  
  
  
  
  
  
  
end
