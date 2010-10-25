module Rubyvis
  
  class Scale::Log < Rubyvis::Scale::Quantitative
    def initialize(*args)
      super(*args)
      @b=nil
      @_p=nil
      
      base(10)
    end
    def log(x)
      Math.log(x) / @_p.to_f
    end
    def pow(y)
      @b**y
    end
    def base(v=nil)
      if v
        @b=v
        @_p=Math.log(@b)
        transform(lambda {|x| log(x)}, lambda {|x| pow(x)})
        return self
      end
      return @b
    end
    def nice
      d=domain
      domain(Rubyvis.log_floor(d[0],@b), Rubyvis.log_ceil(d[1],@b))
    end
    def ticks
      d = domain
      n = d[0] < 0
      
     # puts "dom: #{d[0]} -> #{n}"
      
      i = (n ? -log(-d[0]) : log(d[0])).floor
      j = (n ? -log(-d[1]) : log(d[1])).ceil
      ticks = [];
      if n
        ticks.push(-pow(-i))
        (i..j).each {|ii|
          ((@b-1)...0).each {|k|
            ticks.push(-pow(-ii) * k)
          }
        }
      else
        (i...j).each {|ii|
          (1...@b).each {|k|
            ticks.push(pow(ii) * k)
          }
        }
        ticks.push(pow(j));
      end
      
      #for (i = 0; ticks[i] < d[0]; i++); // strip small values
      #for (j = ticks.length; ticks[j - 1] > d[1]; j--); // strip big values
      #return ticks.slice(i, j);
      ticks.find_all {|v| v>=d[0] and v<=d[1]}
    end
  end
end
