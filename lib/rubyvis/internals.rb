module Rubyvis
  # :section: /pv-internals.js
  @@id=0
  # Returns a locally-unique positive id.
  def self.id
    @@id+=1
  end
  # Return a proc wrapping specific constant
  def self.functor(f)
    (f.is_a? Proc) ? f : lambda {f}
  end
  ##
  # :section: /data/Arrays.js
  
  ##
  # A private variant of Array.map that supports the index property
  # 
  # :call-seq:
  #   self.map(Array)
  #   self.map(array,proc)
  #
  
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
  #
  # Concatenates the specified array with itself <i>n</i> times. For example,
  # +repeat([1, 2])+ returns [1, 2, 1, 2].
  #
  # * @param {array} a an array.
  # * @param {number} [n] the number of times to repeat; defaults to two.
  # * @returns {array} an array that repeats the specified array.
  #
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
    norm=Rubyvis.map(array,f)
    sum=Rubyvis.sum(norm)
    norm.map {|x| x.quo(sum)}
  end
  def self.o_index(i)
    OpenStruct.new :index=>i
  end
  def self.permute(array,indexes, f=nil)
    f=Rubyvis.identity if f.nil?
    indexes.map {|i| o=o_index(i); f.js_call(o, array[i])}
  end
  def self.numerate(keys, f=nil)
    f=Rubyvis.identity if f.nil?
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
  def self.natural_order()
    lambda {|a,b| a<=>b}
  end
  def self.reverse_order()
    lambda {|a,b| -(a<=>b)}
  end

  def self.search(array, value, f=nil)
    f = Rubyvis.identity if (f.nil?)
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
    i=Rubyvis.search(array,value,f)
    (i < 0 ) ? (-i-1) : i;
  end


  # :section: /data/Numbers.js

  def self.range(*arguments)
    start, stop, step=arguments
    if (arguments.size == 1)
      stop = start
      start = 0
    end
    step||= 1
    raise "range must be finite" if ((stop.to_f - start.to_f) / step.to_f).infinite?
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

  def self.sum(array, f=nil)
    if f.nil?
      array.inject(0) {|ac, v| ac+v}
    else
      i=0
      array.inject(0) {|ac,v|
        o=o_index(i)
        i+=1
        ac+f.js_call(o, v)
      }
    end
  end
  def self.max(array, f=nil)
    return array.size-1 if f==Rubyvis.index
    f ? Rubyvis.map(array, f).max : array.max
  end
  def self.max_index(array,f=nil)
    a2=Rubyvis.map(array,f)
    max=a2.max
    a2.index(max)
  end

  def self.min(array, f=nil)
    return array.size-1 if f==Rubyvis.index
    f ? Rubyvis.map(array, f).min : array.min
  end
  def self.min_index(array,f=nil)
    a2=Rubyvis.map(array,f)
    min=a2.min
    a2.index(min)
  end
  def self.mean(array, f=nil)
    Rubyvis.sum(array,f).quo(array.size)
  end
  def self.median(array,f=nil)
    return (array.length - 1).quo(2) if (f == Rubyvis.index)
    array = Rubyvis.map(array, f).sort
    return array[array.size.quo(2).floor] if (array.length % 2>0)
    i = array.size.quo(2);
    return (array[i - 1] + array[i]).quo(2);
  end
  # Sum of square, really
  def self.variance(array,f=nil)
    return 0 if array.size==1 or array.uniq.size==1
    ar=(f.nil?) ? array : Rubyvis.map(array,f)
    mean=Rubyvis.mean(ar)
    ar.inject(0) {|ac,v| ac+(v-mean)**2}
  end
  def self.deviation(array,f=nil)
    Math::sqrt(self.variance(array,f) / (array.size.to_f-1))
  end
  def self.log(x,b)
    Math::log(x).quo(Math::log(b))
  end
  def self.log_symmetric(x,b)
    (x == 0) ? 0 : ((x < 0) ? -Rubyvis.log(-x, b) : Rubyvis.log(x, b));
  end
  def self.log_adjusted(x,b)
    x if x.is_a? Float and !x.finite?
    negative=x<0
    x += (b - x) / b.to_f if (x < b)
    negative ? -Rubyvis.log(x, b) : Rubyvis.log(x, b);
  end
  def self.log_floor(x,b)
    (x>0)  ? b**(Rubyvis.log(x,b).floor) : b**(-(-Rubyvis.log(-x,b)).floor)
  end
  def self.log_ceil(x,b)
    (x > 0) ? b ** (Rubyvis.log(x, b)).ceil : -(b ** -(-Rubyvis.log(-x, b)).ceil);
  end
  def self.radians(degrees)
    (Math::PI/180.0)*degrees
  end
  def self.degrees(radians)
    ((180.0) / Math::PI)*radians
  end
  # :section: /data/Objects.js
  
  def self.keys(map)
    map.keys
  end
  
  # Returns a map constructed from the specified <tt>keys</tt>, using the
  # function <tt>f</tt> to compute the value for each key. The single argument to
  # the value function is the key. The callback is invoked only for indexes of
  # the array which have assigned values; it is not invoked for indexes which
  # have been deleted or which have never been assigned values.
  #
  # <p>For example, this expression creates a map from strings to string length:
  #
  # <pre>pv.dict(["one", "three", "seventeen"], function(s) s.length)</pre>
  #
  # The returned value is <tt>{one: 3, three: 5, seventeen: 9}</tt>. Accessor
  # functions can refer to <tt>this.index</tt>.
  #
  # * @param {array} keys an array.
  # * @param {function} f a value function.
  # * @returns a map from keys to values.

  
  def self.dict(keys, f)
    m = {}
    keys.size.times do |i|
      unless keys[i].nil?
        k=keys[i] 
        o=o_index(i)
        m[k]=f.js_call(o,k)
      end
    end
    m
  end
end
